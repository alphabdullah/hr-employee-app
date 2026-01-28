/// Model class for Notification data
class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? type; // e.g., 'job', 'message', 'system'
  final String? jobId; // Job ID from meta for navigation

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.type,
    this.jobId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    
    // Extract message
    final message = json['message']?.toString() ?? '';
    
    // Extract title from meta.job_title if available, otherwise use message or type
    String title = '';
    if (json['meta'] != null && json['meta'] is Map) {
      final meta = json['meta'] as Map<String, dynamic>;
      title = meta['job_title']?.toString() ?? meta['message']?.toString() ?? '';
    }
    if (title.isEmpty) {
      title = message.isNotEmpty ? message : (json['type']?.toString() ?? 'Notification');
    }
    
    // Parse timestamp from created_at
    DateTime timestamp = DateTime.now();
    if (json['created_at'] != null) {
      try {
        timestamp = DateTime.parse(json['created_at'].toString()).toLocal();
      } catch (e) {
        // Fallback to now if parsing fails
      }
    }
    
    // Check if notification is read: read_at is null = unread, read_at has value = read
    final readAt = json['read_at'];
    final isRead = readAt != null && 
                   readAt.toString().isNotEmpty && 
                   readAt.toString().toLowerCase() != 'null';
    
    // Extract type
    final type = json['type']?.toString();
    
    // Extract job_id from meta if available
    String? jobId;
    if (json['meta'] != null && json['meta'] is Map) {
      final meta = json['meta'] as Map<String, dynamic>;
      jobId = meta['job_id']?.toString();
    }
    
    return NotificationModel(
      id: id,
      title: title,
      message: message,
      timestamp: timestamp,
      isRead: isRead,
      type: type,
      jobId: jobId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'type': type,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    String? type,
    String? jobId,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      jobId: jobId ?? this.jobId,
    );
  }
}

