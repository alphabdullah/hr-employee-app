import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/api_client.dart';
import '../services/api_endpoints.dart';
import '../services/auth_service.dart';

/// ViewModel for Notifications screen
class NotificationViewModel extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasLoaded = false;
  Timer? _pollingTimer;
  bool _isPollingActive = false;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Start polling for new notifications (checks every 3 seconds)
  void startPolling() {
    if (_isPollingActive) return;
    
    _isPollingActive = true;
    debugPrint('[Notifications] Starting polling for new notifications');
    
    // Poll immediately
    checkForNewNotifications();
    
    // Then poll every 3 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      checkForNewNotifications();
    });
  }

  /// Stop polling for new notifications
  void stopPolling() {
    if (!_isPollingActive) return;
    
    _isPollingActive = false;
    _pollingTimer?.cancel();
    _pollingTimer = null;
    debugPrint('[Notifications] Stopped polling for new notifications');
  }

  /// Check for new notifications silently (without showing loading indicator)
  Future<void> checkForNewNotifications() async {
    // Don't check if already loading or user not logged in
    if (_isLoading) return;
    
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        stopPolling();
        return;
      }

      final response = await ApiClient.get(
        ApiEndpoints.getNotifications,
        token: token,
        queryParameters: {'per_page': '15'},
      );

      if (response.isSuccess) {
        final parsed = _parseNotifications(response.data);
        
        // Check if there are new notifications (compare by ID)
        final currentIds = _notifications.map((n) => n.id).toSet();
        final newIds = parsed.map((n) => n.id).toSet();
        final hasNewNotifications = newIds.difference(currentIds).isNotEmpty;
        
        if (hasNewNotifications) {
          debugPrint('[Notifications] New notifications detected!');
        }
        
        // Update notifications list
        _notifications = parsed;
        _hasLoaded = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[Notifications] Error checking for new notifications: $e');
      // Silently fail - don't show error for background checks
    }
  }

  /// Load notifications
  Future<void> loadNotifications({bool forceRefresh = false}) async {
    if (_isLoading && !forceRefresh) return;
    if (!forceRefresh && _hasLoaded) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        _errorMessage = 'Authentication required. Please login again.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      debugPrint('[Notifications API] Starting load notifications request');
      debugPrint('[Notifications API] Endpoint: ${ApiEndpoints.getNotifications}');
      
      final response = await ApiClient.get(
        ApiEndpoints.getNotifications,
        token: token,
        queryParameters: {'per_page': '15'},
      );

      debugPrint('[Notifications API] Response received');
      debugPrint('[Notifications API] Success: ${response.isSuccess}');
      debugPrint('[Notifications API] Status Code: ${response.statusCode}');
      debugPrint('[Notifications API] Message: ${response.message}');
      debugPrint('[Notifications API] Response Data: ${response.data}');

      if (!response.isSuccess) {
        _errorMessage = response.message;
      } else {
        final parsed = _parseNotifications(response.data);
        debugPrint('[Notifications API] Parsed ${parsed.length} notifications');
        _notifications = parsed;
        _errorMessage = null;
        _hasLoaded = true;
      }
    } catch (e) {
      debugPrint('[Notifications API] Exception: $e');
      _errorMessage = 'Failed to load notifications. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1 || _notifications[index].isRead) return;

    // Optimistically update UI
    _notifications[index] = _notifications[index].copyWith(isRead: true);
    notifyListeners();

    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        debugPrint('[Notifications API] No token available for mark as read');
        return;
      }

      debugPrint('[Notifications API] Marking notification $notificationId as read');
      final response = await ApiClient.post(
        ApiEndpoints.markNotificationRead(notificationId),
        token: token,
      );
      
      debugPrint('[Notifications API] Mark as read response: ${response.isSuccess} - ${response.message}');
      
      if (!response.isSuccess) {
        // Revert optimistic update on error
        _notifications[index] = _notifications[index].copyWith(isRead: false);
        notifyListeners();
        debugPrint('[Notifications API] Failed to mark notification as read: ${response.message}');
      }
    } catch (e) {
      debugPrint('[Notifications API] Exception marking notification as read: $e');
      // Revert optimistic update on error
      _notifications[index] = _notifications[index].copyWith(isRead: false);
      notifyListeners();
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    if (_notifications.isEmpty) return;

    // Store original state for rollback
    final originalNotifications = List<NotificationModel>.from(_notifications);
    
    // Optimistically update UI
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();

    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        debugPrint('[Notifications API] No token available for mark all as read');
        // Revert on error
        _notifications = originalNotifications;
        notifyListeners();
        return;
      }

      debugPrint('[Notifications API] Marking all notifications as read');
      final response = await ApiClient.post(
        ApiEndpoints.markAllNotificationsRead,
        token: token,
      );
      
      debugPrint('[Notifications API] Mark all as read response: ${response.isSuccess} - ${response.message}');
      
      if (!response.isSuccess) {
        // Revert optimistic update on error
        _notifications = originalNotifications;
        notifyListeners();
        debugPrint('[Notifications API] Failed to mark all notifications as read: ${response.message}');
      }
    } catch (e) {
      debugPrint('[Notifications API] Exception marking all notifications as read: $e');
      // Revert optimistic update on error
      _notifications = originalNotifications;
      notifyListeners();
    }
  }

  /// Delete notification
  void deleteNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }

  List<NotificationModel> _parseNotifications(Map<String, dynamic> data) {
    List<dynamic>? rawList;

    // New API structure: { "notifications": [...], "pagination": {...} }
    if (data.containsKey('notifications') && data['notifications'] is List) {
      rawList = data['notifications'] as List<dynamic>?;
      debugPrint('[Notifications API] Found notifications in "notifications" key');
    }
    // Fallback: Try "data" key (for backward compatibility)
    else if (data.containsKey('data')) {
      final nestedData = data['data'];
      if (nestedData is List) {
        rawList = nestedData;
        debugPrint('[Notifications API] Found notifications in "data" key (direct list)');
      } 
      // Nested pagination structure
      else if (nestedData is Map && nestedData.containsKey('data') && nestedData['data'] is List) {
        rawList = nestedData['data'] as List<dynamic>?;
        debugPrint('[Notifications API] Found notifications in "data.data" key');
      }
    }

    if (rawList == null || rawList.isEmpty) {
      debugPrint('[Notifications API] No notifications found in response');
      return [];
    }

    try {
      final notifications = rawList
          .whereType<Map<String, dynamic>>()
          .map((json) {
            try {
              return NotificationModel.fromJson(json);
            } catch (e) {
              debugPrint('[Notifications API] Failed to parse notification: $e');
              debugPrint('[Notifications API] Notification JSON: $json');
              return null;
            }
          })
          .whereType<NotificationModel>()
          .toList();
      
      debugPrint('[Notifications API] Successfully parsed ${notifications.length} notifications');
      return notifications;
    } catch (e) {
      debugPrint('[Notifications API] Error parsing notifications list: $e');
      return [];
    }
  }
}

