import 'package:flutter/foundation.dart';
import '../services/api_client.dart';
import '../services/api_endpoints.dart';
import '../services/auth_service.dart';
import '../models/group_model.dart';

/// ViewModel for Chat list screen
class ChatViewModel extends ChangeNotifier {
  List<GroupModel> _groups = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  List<GroupModel> get groups => _groups;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;


Future<void> loadGroups() async {        // ← renamed method
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
        ApiEndpoints.getMyGroups,
        token: token,
      );

      _isLoading = false;

      if (response.isSuccess) {
        final groupsList = response.getList<Map<String, dynamic>>('groups') ?? [];

        _groups = groupsList.map((json) => GroupModel.fromJson(json)).toList();

        // Sort by last message (most recent first), fallback to name
        _groups.sort((a, b) {
          final timeA = a.lastMessageAt ?? DateTime(2000);
          final timeB = b.lastMessageAt ?? DateTime(2000);
          return timeB.compareTo(timeA);
        });

        _errorMessage = null;
      } else {
        _errorMessage = response.message.isNotEmpty
            ? response.message
            : 'Failed to load groups';
        _groups = [];
      }

      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Something went wrong';
      _groups = [];
      notifyListeners();
      debugPrint('Load groups error: $e');
    }
  }

  // Optional: if you want to update last message preview when sending
  void updateGroupLastMessage(String groupId, String preview) {
    final index = _groups.indexWhere((g) => g.id == groupId);
    if (index != -1) {
      final group = _groups[index];
      _groups[index] = GroupModel(
        id: group.id,
        name: group.name,
        region: group.region,
        membersCount: group.membersCount,
        lastMessageAt: DateTime.now(),
        lastMessagePreview: preview,
      );
      // Move to top
      final moved = _groups.removeAt(index);
      _groups.insert(0, moved);
      notifyListeners();
    }
  }
}
//   /// Load chat list from API
//   Future<void> loadChats() async {
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

//       // Call getMyGroupChats API endpoint
//       final response = await ApiClient.get(
//         ApiEndpoints.getMyGroupChats,
//         queryParameters: {'per_page': '100'},
//         token: token,
//       );

//       _isLoading = false;

//       if (response.isSuccess) {
//         // Parse group chats array from response
//         // Try different possible keys: 'group_chats', 'chats', 'data', or direct array
//         List<Map<String, dynamic>>? chatsList = 
//             response.getList<Map<String, dynamic>>('group_chats') ??
//             response.getList<Map<String, dynamic>>('chats') ??
//             response.getList<Map<String, dynamic>>('data');
        
//         if (chatsList != null && chatsList.isNotEmpty) {
//           // Convert API chats to ChatModel list
//           _chats = chatsList.map((chatJson) {
//             return ChatModel.fromJson(chatJson);
//           }).toList();
          
//           // Sort by last message time (most recent first)
//           _chats.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
          
//           _errorMessage = null;
//         } else {
//           // No chats found
//           _chats = [];
//           _errorMessage = null;
//         }
//       } else {
//         _errorMessage = response.message.isNotEmpty
//             ? response.message
//             : 'Failed to load chats. Please try again.';
//         _chats = [];
//       }
      
//       notifyListeners();
//     } catch (e) {
//       _isLoading = false;
//       _errorMessage = 'Failed to load chats. Please try again.';
//       _chats = [];
//       notifyListeners();
//       debugPrint('Failed to load chats: $e');
//     }
//   }

//   /// Get chat by ID
//   ChatModel? getChatById(String id) {
//     try {
//       return _chats.firstWhere((chat) => chat.id == id);
//     } catch (e) {
//       return null;
//     }
//   }

//   /// Update chat last message
//   void updateChatLastMessage(String chatId, String message) {
//     final index = _chats.indexWhere((chat) => chat.id == chatId);
//     if (index != -1) {
//       _chats[index] = _chats[index].copyWith(
//         lastMessage: message,
//         lastMessageTime: DateTime.now(),
//       );
//       // Move to top
//       final chat = _chats.removeAt(index);
//       _chats.insert(0, chat);
//       notifyListeners();
//     }
//   }
// }

