import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../models/chat_model.dart';
import '../services/api_client.dart';
import '../services/api_endpoints.dart';
import '../services/auth_service.dart';
import '../services/cache_service.dart';

/// ViewModel for Chat detail screen
class ChatDetailViewModel extends ChangeNotifier {
  final String chatId;
  ChatModel? _chat;
  List<MessageModel> _messages = [];
  List<Map<String, dynamic>> _participants = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasLoadedMessages = false;
  final TextEditingController messageController = TextEditingController();

  ChatModel? get chat => _chat;
  List<MessageModel> get messages => _messages;
  List<Map<String, dynamic>> get participants => _participants;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ChatDetailViewModel(this.chatId);

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  /// Load chat details and messages from API
  /// 
  /// [forceRefresh] - If true, always fetch from API. If false and data exists, show cached data and refresh in background.
  Future<void> loadChatDetails(ChatModel chat, {bool forceRefresh = false}) async {
    _chat = chat;
    
    // Try to load from disk cache first (if not forcing refresh)
    if (!forceRefresh && _messages.isEmpty) {
      final cachedMessages = await CacheService.loadChatMessages(chatId);
      if (cachedMessages != null && cachedMessages.isNotEmpty) {
        try {
          // Get current user ID to determine if message is sent by me
          final currentUserId = await AuthService.getEmployeeId();
          
          // Convert cached messages to MessageModel list
          _messages = cachedMessages.map((messageJson) {
            return MessageModel.fromJson(
              messageJson,
              currentUserId: currentUserId,
            );
          }).toList();
          
          // Sort by timestamp (oldest first for chat display)
          _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          
          _hasLoadedMessages = true;
          _errorMessage = null;
          notifyListeners();
          // Continue to refresh in background
        } catch (e) {
          debugPrint('Failed to parse cached messages: $e');
        }
      }
    }
    
    // If we have cached data (in-memory or disk) and not forcing refresh, refresh in background
    if (!forceRefresh && _hasLoadedMessages && _messages.isNotEmpty) {
      // Show cached data immediately (already in state)
      // Refresh in background without blocking UI
      _refreshMessagesInBackground();
      return;
    }
    
    // First time loading or force refresh - show loading indicator
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get authentication token
      final token = await AuthService.getToken();
      
      if (token == null || token.isEmpty) {
        _errorMessage = 'Authentication required. Please login again.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Call getGroupChatMessages API endpoint
      final response = await ApiClient.get(
        ApiEndpoints.getGroupChatMessages(chatId),
        queryParameters: {'per_page': '100'},
        token: token,
      );

      _isLoading = false;
      _hasLoadedMessages = true;

      if (response.isSuccess) {
        // Parse participants from group_chat
        final groupChatData = response.getField<Map<String, dynamic>>('group_chat');
        if (groupChatData != null) {
          final participantsList = groupChatData['participants'] as List<dynamic>?;
          if (participantsList != null) {
            _participants = participantsList
                .map((p) => Map<String, dynamic>.from(p as Map))
                .toList();
          }
        }
        
        // Parse messages array from response
        // Try different possible keys: 'messages', 'data', or direct array
        List<Map<String, dynamic>>? messagesList = 
            response.getList<Map<String, dynamic>>('messages') ??
            response.getList<Map<String, dynamic>>('data');
        
        if (messagesList != null && messagesList.isNotEmpty) {
          // Get current user ID to determine if message is sent by me
          final currentUserId = await AuthService.getEmployeeId();
          
          // Convert API messages to MessageModel list
          _messages = messagesList.map((messageJson) {
            return MessageModel.fromJson(
              messageJson,
              currentUserId: currentUserId,
            );
          }).toList();
          
          // Sort by timestamp (oldest first for chat display)
          _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          
          // Save to cache
          await CacheService.saveChatMessages(chatId, messagesList);
          
          _errorMessage = null;
        } else {
          // No messages found
          _messages = [];
          _errorMessage = null;
          // Save empty list to cache
          await CacheService.saveChatMessages(chatId, []);
        }
      } else {
        _errorMessage = response.message.isNotEmpty
            ? response.message
            : 'Failed to load messages. Please try again.';
        _messages = [];
      }
      
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load messages. Please try again.';
      _messages = [];
      notifyListeners();
      debugPrint('Failed to load messages: $e');
    }
  }

  /// Refresh messages in background without showing loading indicator
  Future<void> _refreshMessagesInBackground() async {
    try {
      // Get authentication token
      final token = await AuthService.getToken();
      
      if (token == null || token.isEmpty) {
        return;
      }

      // Call getGroupChatMessages API endpoint silently
      final response = await ApiClient.get(
        ApiEndpoints.getGroupChatMessages(chatId),
        queryParameters: {'per_page': '100'},
        token: token,
      );

      if (response.isSuccess) {
        // Parse participants from group_chat
        final groupChatData = response.getField<Map<String, dynamic>>('group_chat');
        if (groupChatData != null) {
          final participantsList = groupChatData['participants'] as List<dynamic>?;
          if (participantsList != null) {
            _participants = participantsList
                .map((p) => Map<String, dynamic>.from(p as Map))
                .toList();
          }
        }
        
        // Parse messages array from response
        List<Map<String, dynamic>>? messagesList = 
            response.getList<Map<String, dynamic>>('messages') ??
            response.getList<Map<String, dynamic>>('data');
        
        if (messagesList != null) {
          // Get current user ID to determine if message is sent by me
          final currentUserId = await AuthService.getEmployeeId();
          
          // Convert API messages to MessageModel list
          final updatedMessages = messagesList.map((messageJson) {
            return MessageModel.fromJson(
              messageJson,
              currentUserId: currentUserId,
            );
          }).toList();
          
          // Sort by timestamp (oldest first for chat display)
          updatedMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          
          // Update messages list
          _messages = updatedMessages;
          
          // Save to cache
          await CacheService.saveChatMessages(chatId, messagesList);
          
          _errorMessage = null;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Background messages refresh failed: $e');
    }
  }

  /// Send a new message via API
  Future<void> sendMessage() async {
    final messageText = messageController.text.trim();
    if (messageText.isEmpty) return;

    // Get authentication token
    final token = await AuthService.getToken();
    
    if (token == null || token.isEmpty) {
      _errorMessage = 'Authentication required. Please login again.';
      notifyListeners();
      return;
    }

    // Create optimistic message (will be replaced with server response)
    final tempMessageId = DateTime.now().millisecondsSinceEpoch.toString();
    final currentUserId = await AuthService.getEmployeeId();
    
    final optimisticMessage = MessageModel(
      id: tempMessageId,
      chatId: chatId,
      senderId: currentUserId ?? '',
      senderName: 'Me',
      message: messageText,
      timestamp: DateTime.now(),
      isSentByMe: true,
    );

    // Add message to list optimistically
    _messages.add(optimisticMessage);
    messageController.clear();
    notifyListeners();

    try {
      // Call sendGroupChatMessage API endpoint
      final response = await ApiClient.post(
        ApiEndpoints.sendGroupChatMessage(chatId),
        body: {'message': messageText},
        token: token,
      );

      if (response.isSuccess) {
        // Replace optimistic message with server response
        try {
          // The API might return the message directly or nested in 'data' or 'message' key
          Map<String, dynamic> messageData;
          
          // Check if message is directly in response.data
          if (response.data.containsKey('id') && response.data.containsKey('message')) {
            messageData = response.data;
          } else if (response.data.containsKey('data')) {
            messageData = response.data['data'];
          } else if (response.data.containsKey('message')) {
            messageData = response.data['message'];
          } else {
            // Use response.data directly
            messageData = response.data;
          }
          
          final serverMessage = MessageModel.fromJson(
            messageData,
            currentUserId: currentUserId,
          );
          
          // Remove optimistic message and add server message
          _messages.removeWhere((msg) => msg.id == tempMessageId);
          _messages.add(serverMessage);
          // Re-sort by timestamp
          _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          
          // Reload messages to get latest from server and update cache
          await _refreshMessagesInBackground();
        } catch (e) {
          debugPrint('Failed to parse server message: $e');
          // Keep optimistic message if parsing fails
          // Still reload messages to sync with server
          await _refreshMessagesInBackground();
        }
        
        _errorMessage = null;
        notifyListeners();
      } else {
        // Remove optimistic message on error
        _messages.removeWhere((msg) => msg.id == tempMessageId);
        _errorMessage = response.message.isNotEmpty
            ? response.message
            : 'Failed to send message. Please try again.';
        notifyListeners();
      }
    } catch (e) {
      // Remove optimistic message on error
      _messages.removeWhere((msg) => msg.id == tempMessageId);
      _errorMessage = 'Failed to send message. Please try again.';
      notifyListeners();
      debugPrint('Failed to send message: $e');
    }
  }
}

