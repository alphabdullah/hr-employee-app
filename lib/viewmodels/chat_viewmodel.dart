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
