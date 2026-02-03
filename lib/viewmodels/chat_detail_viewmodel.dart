import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../services/api_client.dart';
import '../services/api_endpoints.dart';
import '../services/auth_service.dart';
import '../services/cache_service.dart';

/// ViewModel for Group Chat detail screen
class ChatDetailViewModel extends ChangeNotifier {
  final String groupId; // reusing chatId field name as groupId
  String? groupName;    // will be set from response or navigation args
  List<MessageModel> _messages = [];
  List<Map<String, dynamic>> _participants = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasLoadedMessages = false;
  final TextEditingController messageController = TextEditingController();

  List<MessageModel> get messages => _messages;
  List<Map<String, dynamic>> get participants => _participants;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ChatDetailViewModel(this.groupId);

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  /// Load group messages from the new endpoint
  /// [forceRefresh] - force API call even if we have cache
  Future<void> loadGroupMessages({bool forceRefresh = false}) async {
    // Try cache first (fast UI)
    if (!forceRefresh && _messages.isEmpty) {
      final cached = await CacheService.loadChatMessages(groupId);
      if (cached != null && cached.isNotEmpty) {
        try {
          final currentUserId = await AuthService.getEmployeeId();
          _messages = cached.map((json) {
            return MessageModel.fromJson(json, currentUserId: currentUserId);
          }).toList();

          _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          _hasLoadedMessages = true;
          notifyListeners();

          // background refresh anyway
          _refreshInBackground();
          return;
        } catch (e) {
          debugPrint('Cache parse failed: $e');
        }
      }
    }

    // Show loading if no cache or force refresh
    if (!forceRefresh && _hasLoadedMessages && _messages.isNotEmpty) {
      _refreshInBackground();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        _errorMessage = 'Please login again';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await ApiClient.get(
        ApiEndpoints.getGroupChatMessages(groupId),
        queryParameters: {'per_page': '50'}, // or 100 — match your backend
        token: token,
      );

      _isLoading = false;
      _hasLoadedMessages = true;

      if (response.isSuccess) {
        // Extract group name
        final groupData = response.getField<Map<String, dynamic>>('group');
        groupName = groupData?['name']?.toString() ?? 'Group Chat';

        // Get messages
        final messagesList = response.getList<Map<String, dynamic>>('messages') ?? [];

        final currentUserId = await AuthService.getEmployeeId() ?? '';

        _messages = messagesList.map((json) {
          return MessageModel.fromJson(json, currentUserId: currentUserId);
        }).toList();

        _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        // Cache them
        await CacheService.saveChatMessages(groupId, messagesList);

        // Optional: participants if your response has them later
        // For now we skip since your sample doesn't include participants

        _errorMessage = null;
      } else {
        _errorMessage = response.message.isNotEmpty
            ? response.message
            : 'Failed to load messages';
        _messages = [];
      }
    } catch (e) {
      _errorMessage = 'Something went wrong while loading messages';
      _messages = [];
      debugPrint('Load group messages error: $e');
    }

    notifyListeners();
  }

  /// Silent background refresh
  Future<void> _refreshInBackground() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return;

      final response = await ApiClient.get(
        ApiEndpoints.getGroupChatMessages(groupId),
        queryParameters: {'per_page': '50'},
        token: token,
      );

      if (response.isSuccess) {
        final messagesList = response.getList<Map<String, dynamic>>('messages') ?? [];
        final currentUserId = await AuthService.getEmployeeId() ?? '';

        final updated = messagesList.map((json) {
          return MessageModel.fromJson(json, currentUserId: currentUserId);
        }).toList();

        updated.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        _messages = updated;
        await CacheService.saveChatMessages(groupId, messagesList);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Background refresh failed: $e');
    }
  }

Future<void> sendMessage() async {
  final text = messageController.text.trim();
  if (text.isEmpty) return;

  final token = await AuthService.getToken();
  if (token == null || token.isEmpty) {
    _errorMessage = 'Please login again';
    notifyListeners();
    return;
  }

  // Create optimistic message
  final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
  final now = DateTime.now();
  final currentUserId = await AuthService.getEmployeeId() ?? '';

  final optimistic = MessageModel(
    id: tempId,
    chatId: groupId,
    senderId: currentUserId,
    senderName: 'You',
    message: text,
    timestamp: now,
    isSentByMe: true,
    type: MessageType.text,
  );

  // Add to list + notify UI immediately
  _messages.add(optimistic);
  messageController.clear();
  notifyListeners();

  try {
    final response = await ApiClient.post(
      '/api/me/groups/$groupId/messages',
      body: {'body': text},  // change to {'message': text} if backend wants that
      token: token,
    );

    if (response.isSuccess) {
      // Try to extract the real created message
      Map<String, dynamic>? serverMsg;

      // Adjust based on your real response shape
      if (response.data['id'] != null) {
        serverMsg = response.data;
      } else if (response.data['message'] is Map) {
        serverMsg = response.data['message'];
      } else if (response.data['data'] is Map) {
        serverMsg = response.data['data'];
      }

      if (serverMsg != null) {
        final realMessage = MessageModel.fromJson(serverMsg);

        // Replace temp with real
        final index = _messages.indexWhere((m) => m.id == tempId);
        if (index != -1) {
          _messages[index] = realMessage;
        } else {
          _messages.add(realMessage);
        }

        // Sort again (just in case timestamp differs slightly)
        _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      }

      // Optional background full sync
      _refreshInBackground();
      _errorMessage = null;
    } else {
      // Remove optimistic on failure
      _messages.removeWhere((m) => m.id == tempId);
      _errorMessage = response.message.isNotEmpty ? response.message : 'Failed to send';
    }
  } catch (e) {
    // Remove optimistic on network error
    _messages.removeWhere((m) => m.id == tempId);
    _errorMessage = 'Network error – try again';
    debugPrint('Send error: $e');
  }

  // VERY IMPORTANT: notify UI after everything
  notifyListeners();
}
  /// Send message with optimistic update
  // Future<void> sendMessage() async {
  //   final text = messageController.text.trim();
  //   if (text.isEmpty) return;

  //   final token = await AuthService.getToken();
  //   if (token == null || token.isEmpty) {
  //     _errorMessage = 'Authentication required';
  //     notifyListeners();
  //     return;
  //   }

  //   // Optimistic message
  //   final tempId = DateTime.now().millisecondsSinceEpoch.toString();
  //   final now = DateTime.now();
  //   final currentUserId = await AuthService.getEmployeeId() ?? '';

  //   final optimistic = MessageModel(
  //     id: tempId,
  //     chatId: groupId,
  //     senderId: currentUserId,
  //     senderName: 'Me',
  //     message: text,
  //     timestamp: now,
  //     isSentByMe: true,
  //     type: MessageType.text,
  //   );

  //   _messages.add(optimistic);
  //   messageController.clear();
  //   notifyListeners();

  //   try {
  //     // Adjust body field name if your backend expects something else (e.g. 'message' vs 'body')
  //     final response = await ApiClient.post(
  //       ApiEndpoints.sendGroupChatMessage(groupId),   // ← your send endpoint (guessed)
  //       body: {'body': text},                 // change to {'message': text} if needed
  //       token: token,
  //     );

  //     if (response.isSuccess) {
  //       // Try to get the real message from response
  //       Map<String, dynamic>? serverJson;

  //       if (response.data.containsKey('id') && response.data.containsKey('body')) {
  //         serverJson = response.data;
  //       } else if (response.data['message'] is Map) {
  //         serverJson = response.data['message'];
  //       } else if (response.data['data'] is Map) {
  //         serverJson = response.data['data'];
  //       }

  //       if (serverJson != null) {
  //         final realMsg = MessageModel.fromJson(serverJson, currentUserId: currentUserId);

  //         _messages.removeWhere((m) => m.id == tempId);
  //         _messages.add(realMsg);
  //         _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

  //         // background sync
  //         await _refreshInBackground();
  //       } else {
  //         // if no message returned — keep optimistic and refresh
  //         await _refreshInBackground();
  //       }

  //       _errorMessage = null;
  //     } else {
  //       _messages.removeWhere((m) => m.id == tempId);
  //       _errorMessage = response.message.isNotEmpty
  //           ? response.message
  //           : 'Failed to send message';
  //     }
  //   } catch (e) {
  //     _messages.removeWhere((m) => m.id == tempId);
  //     _errorMessage = 'Network error while sending';
  //     debugPrint('Send failed: $e');
  //   }

  //   notifyListeners();
  // }



}

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import '../models/message_model.dart';
// import '../models/chat_model.dart';
// import '../services/api_client.dart';
// import '../services/api_endpoints.dart';
// import '../services/auth_service.dart';
// import '../services/cache_service.dart';

// /// ViewModel for Chat detail screen
// class ChatDetailViewModel extends ChangeNotifier {
//   final String chatId;
//   ChatModel? _chat;
//   List<MessageModel> _messages = [];
//   List<Map<String, dynamic>> _participants = [];
//   bool _isLoading = false;
//   String? _errorMessage;
//   bool _hasLoadedMessages = false;
//   final TextEditingController messageController = TextEditingController();

//   ChatModel? get chat => _chat;
//   List<MessageModel> get messages => _messages;
//   List<Map<String, dynamic>> get participants => _participants;
//   bool get isLoading => _isLoading;
//   String? get errorMessage => _errorMessage;

//   ChatDetailViewModel(this.chatId);

//   @override
//   void dispose() {
//     messageController.dispose();
//     super.dispose();
//   }

//   /// Load chat details and messages from API
//   /// 
//   /// [forceRefresh] - If true, always fetch from API. If false and data exists, show cached data and refresh in background.
//   Future<void> loadChatDetails(ChatModel chat, {bool forceRefresh = false}) async {
//     _chat = chat;
    
//     // Try to load from disk cache first (if not forcing refresh)
//     if (!forceRefresh && _messages.isEmpty) {
//       final cachedMessages = await CacheService.loadChatMessages(chatId);
//       if (cachedMessages != null && cachedMessages.isNotEmpty) {
//         try {
//           // Get current user ID to determine if message is sent by me
//           final currentUserId = await AuthService.getEmployeeId();
          
//           // Convert cached messages to MessageModel list
//           _messages = cachedMessages.map((messageJson) {
//             return MessageModel.fromJson(
//               messageJson,
//               currentUserId: currentUserId,
//             );
//           }).toList();
          
//           // Sort by timestamp (oldest first for chat display)
//           _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          
//           _hasLoadedMessages = true;
//           _errorMessage = null;
//           notifyListeners();
//           // Continue to refresh in background
//         } catch (e) {
//           debugPrint('Failed to parse cached messages: $e');
//         }
//       }
//     }
    
//     // If we have cached data (in-memory or disk) and not forcing refresh, refresh in background
//     if (!forceRefresh && _hasLoadedMessages && _messages.isNotEmpty) {
//       // Show cached data immediately (already in state)
//       // Refresh in background without blocking UI
//       _refreshMessagesInBackground();
//       return;
//     }
    
//     // First time loading or force refresh - show loading indicator
//     _isLoading = true;
//     _errorMessage = null;
//     notifyListeners();

//     try {
//       // Get authentication token
//       final token = await AuthService.getToken();
      
//       if (token == null || token.isEmpty) {
//         _errorMessage = 'Authentication required. Please login again.';
//         _isLoading = false;
//         notifyListeners();
//         return;
//       }

//       // Call getGroupChatMessages API endpoint
//       final response = await ApiClient.get(
//         ApiEndpoints.getGroupChatMessages(chatId),
//         queryParameters: {'per_page': '100'},
//         token: token,
//       );

//       _isLoading = false;
//       _hasLoadedMessages = true;

//       if (response.isSuccess) {
//         // Parse participants from group_chat
//         final groupChatData = response.getField<Map<String, dynamic>>('group_chat');
//         if (groupChatData != null) {
//           final participantsList = groupChatData['participants'] as List<dynamic>?;
//           if (participantsList != null) {
//             _participants = participantsList
//                 .map((p) => Map<String, dynamic>.from(p as Map))
//                 .toList();
//           }
//         }
        
//         // Parse messages array from response
//         // Try different possible keys: 'messages', 'data', or direct array
//         List<Map<String, dynamic>>? messagesList = 
//             response.getList<Map<String, dynamic>>('messages') ??
//             response.getList<Map<String, dynamic>>('data');
        
//         if (messagesList != null && messagesList.isNotEmpty) {
//           // Get current user ID to determine if message is sent by me
//           final currentUserId = await AuthService.getEmployeeId();
          
//           // Convert API messages to MessageModel list
//           _messages = messagesList.map((messageJson) {
//             return MessageModel.fromJson(
//               messageJson,
//               currentUserId: currentUserId,
//             );
//           }).toList();
          
//           // Sort by timestamp (oldest first for chat display)
//           _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          
//           // Save to cache
//           await CacheService.saveChatMessages(chatId, messagesList);
          
//           _errorMessage = null;
//         } else {
//           // No messages found
//           _messages = [];
//           _errorMessage = null;
//           // Save empty list to cache
//           await CacheService.saveChatMessages(chatId, []);
//         }
//       } else {
//         _errorMessage = response.message.isNotEmpty
//             ? response.message
//             : 'Failed to load messages. Please try again.';
//         _messages = [];
//       }
      
//       notifyListeners();
//     } catch (e) {
//       _isLoading = false;
//       _errorMessage = 'Failed to load messages. Please try again.';
//       _messages = [];
//       notifyListeners();
//       debugPrint('Failed to load messages: $e');
//     }
//   }

//   /// Refresh messages in background without showing loading indicator
//   Future<void> _refreshMessagesInBackground() async {
//     try {
//       // Get authentication token
//       final token = await AuthService.getToken();
      
//       if (token == null || token.isEmpty) {
//         return;
//       }

//       // Call getGroupChatMessages API endpoint silently
//       final response = await ApiClient.get(
//         ApiEndpoints.getGroupChatMessages(chatId),
//         queryParameters: {'per_page': '100'},
//         token: token,
//       );

//       if (response.isSuccess) {
//         // Parse participants from group_chat
//         final groupChatData = response.getField<Map<String, dynamic>>('group_chat');
//         if (groupChatData != null) {
//           final participantsList = groupChatData['participants'] as List<dynamic>?;
//           if (participantsList != null) {
//             _participants = participantsList
//                 .map((p) => Map<String, dynamic>.from(p as Map))
//                 .toList();
//           }
//         }
        
//         // Parse messages array from response
//         List<Map<String, dynamic>>? messagesList = 
//             response.getList<Map<String, dynamic>>('messages') ??
//             response.getList<Map<String, dynamic>>('data');
        
//         if (messagesList != null) {
//           // Get current user ID to determine if message is sent by me
//           final currentUserId = await AuthService.getEmployeeId();
          
//           // Convert API messages to MessageModel list
//           final updatedMessages = messagesList.map((messageJson) {
//             return MessageModel.fromJson(
//               messageJson,
//               currentUserId: currentUserId,
//             );
//           }).toList();
          
//           // Sort by timestamp (oldest first for chat display)
//           updatedMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          
//           // Update messages list
//           _messages = updatedMessages;
          
//           // Save to cache
//           await CacheService.saveChatMessages(chatId, messagesList);
          
//           _errorMessage = null;
//           notifyListeners();
//         }
//       }
//     } catch (e) {
//       debugPrint('Background messages refresh failed: $e');
//     }
//   }

//   /// Send a new message via API
//   Future<void> sendMessage() async {
//     final messageText = messageController.text.trim();
//     if (messageText.isEmpty) return;

//     // Get authentication token
//     final token = await AuthService.getToken();
    
//     if (token == null || token.isEmpty) {
//       _errorMessage = 'Authentication required. Please login again.';
//       notifyListeners();
//       return;
//     }

//     // Create optimistic message (will be replaced with server response)
//     final tempMessageId = DateTime.now().millisecondsSinceEpoch.toString();
//     final currentUserId = await AuthService.getEmployeeId();
    
//     final optimisticMessage = MessageModel(
//       id: tempMessageId,
//       chatId: chatId,
//       senderId: currentUserId ?? '',
//       senderName: 'Me',
//       message: messageText,
//       timestamp: DateTime.now(),
//       isSentByMe: true,
//     );

//     // Add message to list optimistically
//     _messages.add(optimisticMessage);
//     messageController.clear();
//     notifyListeners();

//     try {
//       // Call sendGroupChatMessage API endpoint
//       final response = await ApiClient.post(
//         ApiEndpoints.sendGroupChatMessage(chatId),
//         body: {'message': messageText},
//         token: token,
//       );

//       if (response.isSuccess) {
//         // Replace optimistic message with server response
//         try {
//           // The API might return the message directly or nested in 'data' or 'message' key
//           Map<String, dynamic> messageData;
          
//           // Check if message is directly in response.data
//           if (response.data.containsKey('id') && response.data.containsKey('message')) {
//             messageData = response.data;
//           } else if (response.data.containsKey('data')) {
//             messageData = response.data['data'];
//           } else if (response.data.containsKey('message')) {
//             messageData = response.data['message'];
//           } else {
//             // Use response.data directly
//             messageData = response.data;
//           }
          
//           final serverMessage = MessageModel.fromJson(
//             messageData,
//             currentUserId: currentUserId,
//           );
          
//           // Remove optimistic message and add server message
//           _messages.removeWhere((msg) => msg.id == tempMessageId);
//           _messages.add(serverMessage);
//           // Re-sort by timestamp
//           _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          
//           // Reload messages to get latest from server and update cache
//           await _refreshMessagesInBackground();
//         } catch (e) {
//           debugPrint('Failed to parse server message: $e');
//           // Keep optimistic message if parsing fails
//           // Still reload messages to sync with server
//           await _refreshMessagesInBackground();
//         }
        
//         _errorMessage = null;
//         notifyListeners();
//       } else {
//         // Remove optimistic message on error
//         _messages.removeWhere((msg) => msg.id == tempMessageId);
//         _errorMessage = response.message.isNotEmpty
//             ? response.message
//             : 'Failed to send message. Please try again.';
//         notifyListeners();
//       }
//     } catch (e) {
//       // Remove optimistic message on error
//       _messages.removeWhere((msg) => msg.id == tempMessageId);
//       _errorMessage = 'Failed to send message. Please try again.';
//       notifyListeners();
//       debugPrint('Failed to send message: $e');
//     }
//   }
// }

