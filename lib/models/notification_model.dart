/// Model class for Notification data
class NotificationModel {
  final String id;
  final String type; // job_assigned, hours_changed, chat_message, job_complete
  final String title;
  final String message;
  final Map<String, dynamic>? data; // Type-specific data
  final DateTime timestamp;
  final bool isRead;
  
  // Extracted from data field for convenience
  final int? scheduleJobId;
  final String? jobTitle;
  final String? fromDate;
  final String? endDate;
  final double? hoursWorked;
  final String? notes;
  final String? chatGroupId;
  final String? chatGroupName;
  final String? chatMessageId;
  final String? senderId;
  final String? senderName;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.data,
    required this.timestamp,
    this.isRead = false,
    this.scheduleJobId,
    this.jobTitle,
    this.fromDate,
    this.endDate,
    this.hoursWorked,
    this.notes,
    this.chatGroupId,
    this.chatGroupName,
    this.chatMessageId,
    this.senderId,
    this.senderName,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final type = json['type']?.toString() ?? '';
    final title = json['title']?.toString() ?? '';
    final message = json['message']?.toString() ?? '';
    final data = json['data'] is Map<String, dynamic> 
        ? Map<String, dynamic>.from(json['data'] as Map)
        : null;
    
    // Parse timestamp from created_at
    DateTime timestamp = DateTime.now();
    if (json['created_at'] != null) {
      try {
        final dateStr = json['created_at'].toString();
        timestamp = DateTime.parse(dateStr);
        if (timestamp.isUtc) {
          timestamp = timestamp.toLocal();
        }
      } catch (e) {
        // Fallback to now if parsing fails
      }
    }
    
    // Check if notification is read: read_at is null = unread, read_at has value = read
    final readAt = json['read_at'];
    final isRead = readAt != null && 
                   readAt.toString().isNotEmpty && 
                   readAt.toString().toLowerCase() != 'null';
    
    // Extract type-specific data from data field
    int? scheduleJobId;
    String? jobTitle;
    String? fromDate;
    String? endDate;
    double? hoursWorked;
    String? notes;
    String? chatGroupId;
    String? chatGroupName;
    String? chatMessageId;
    String? senderId;
    String? senderName;
    
    if (data != null) {
      scheduleJobId = data['schedule_job_id'] is int 
          ? data['schedule_job_id'] 
          : (data['schedule_job_id'] != null 
              ? int.tryParse(data['schedule_job_id'].toString()) 
              : null);
      
      jobTitle = data['job_title']?.toString();
      fromDate = data['from_date']?.toString();
      endDate = data['end_date']?.toString();
      
      if (data['hours_worked'] != null) {
        hoursWorked = data['hours_worked'] is double 
            ? data['hours_worked'] 
            : (data['hours_worked'] is int 
                ? (data['hours_worked'] as int).toDouble() 
                : double.tryParse(data['hours_worked'].toString()));
      }
      
      notes = data['notes']?.toString();
      chatGroupId = data['chat_group_id']?.toString();
      chatGroupName = data['chat_group_name']?.toString();
      chatMessageId = data['chat_message_id']?.toString();
      senderId = data['sender_id']?.toString();
      senderName = data['sender_name']?.toString();
    }
    
    return NotificationModel(
      id: id,
      type: type,
      title: title,
      message: message,
      data: data,
      timestamp: timestamp,
      isRead: isRead,
      scheduleJobId: scheduleJobId,
      jobTitle: jobTitle,
      fromDate: fromDate,
      endDate: endDate,
      hoursWorked: hoursWorked,
      notes: notes,
      chatGroupId: chatGroupId,
      chatGroupName: chatGroupName,
      chatMessageId: chatMessageId,
      senderId: senderId,
      senderName: senderName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'data': data,
      'created_at': timestamp.toIso8601String(),
      'read_at': isRead ? timestamp.toIso8601String() : null,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? type,
    String? title,
    String? message,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    bool? isRead,
    int? scheduleJobId,
    String? jobTitle,
    String? fromDate,
    String? endDate,
    double? hoursWorked,
    String? notes,
    String? chatGroupId,
    String? chatGroupName,
    String? chatMessageId,
    String? senderId,
    String? senderName,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      scheduleJobId: scheduleJobId ?? this.scheduleJobId,
      jobTitle: jobTitle ?? this.jobTitle,
      fromDate: fromDate ?? this.fromDate,
      endDate: endDate ?? this.endDate,
      hoursWorked: hoursWorked ?? this.hoursWorked,
      notes: notes ?? this.notes,
      chatGroupId: chatGroupId ?? this.chatGroupId,
      chatGroupName: chatGroupName ?? this.chatGroupName,
      chatMessageId: chatMessageId ?? this.chatMessageId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
    );
  }
  
  /// Get job ID for navigation (from schedule_job_id)
  String? get jobId => scheduleJobId?.toString();
}

