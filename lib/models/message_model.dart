import 'package:flutter/foundation.dart';

/// Model class for Chat Message
class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String? senderProfileImage;
  final String message;
  final DateTime timestamp;
  final bool isSentByMe;
  final MessageType type;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    this.senderProfileImage,
    required this.message,
    required this.timestamp,
    required this.isSentByMe,
    this.type = MessageType.text,
  });

  factory MessageModel.fromJson(
    Map<String, dynamic> json, {
    String? currentUserId,
  }) {
    // Parse sender information (can be nested in sender, employee, or direct)
    final senderData = json['sender'] as Map<String, dynamic>?;
    final employeeData = json['employee'] as Map<String, dynamic>?;
    // Use employee data if available, otherwise fall back to sender data
    final userData = employeeData ?? senderData;
    
    // Try multiple possible field names for sender ID
    final senderId = userData?['id']?.toString() ?? 
                   userData?['employee_id']?.toString() ?? 
                   userData?['employeeId']?.toString() ??
                   json['sender_id']?.toString() ?? 
                   json['senderId']?.toString() ??
                   json['employee_id']?.toString() ??
                   json['employeeId']?.toString() ??
                   '';
    final senderName = userData?['full_name']?.toString() ?? 
                      userData?['name']?.toString() ?? 
                      userData?['fullName']?.toString() ?? 
                      json['sender_name']?.toString() ?? 
                      json['senderName']?.toString() ?? 
                      'Unknown';
    
    // Parse sender profile image
    final profileImage = userData?['profile_image'];
    final String? senderProfileImage;
    if (profileImage == null || profileImage == 'null' || profileImage.toString().isEmpty) {
      senderProfileImage = null;
    } else {
      senderProfileImage = profileImage.toString();
    }
    
    // Parse message content
    final message = json['message']?.toString() ?? '';
    
    // Parse timestamp (prioritize sent_at, then created_at, then timestamp)
    DateTime timestamp = DateTime.now();
    if (json['sent_at'] != null) {
      try {
        timestamp = DateTime.parse(json['sent_at']);
      } catch (e) {
        // Keep default
      }
    } else if (json['created_at'] != null) {
      try {
        timestamp = DateTime.parse(json['created_at']);
      } catch (e) {
        // Keep default
      }
    } else if (json['timestamp'] != null) {
      try {
        timestamp = DateTime.parse(json['timestamp']);
      } catch (e) {
        // Keep default
      }
    }
    
    // Determine if message is sent by current user
    // Compare IDs as strings (handle both string and numeric IDs)
    bool isSentByMe = false;
    if (currentUserId != null && senderId.isNotEmpty) {
      // Normalize both IDs by trimming and converting to string
      final normalizedSenderId = senderId.trim();
      final normalizedCurrentUserId = currentUserId.trim();
      
      // Try direct string comparison first
      if (normalizedSenderId == normalizedCurrentUserId) {
        isSentByMe = true;
      } else {
        // Try numeric comparison (in case one is "1" and other is 1, or different formats)
        try {
          final senderIdNum = int.parse(normalizedSenderId);
          final currentUserIdNum = int.parse(normalizedCurrentUserId);
          isSentByMe = senderIdNum == currentUserIdNum;
        } catch (e) {
          // If parsing fails, try case-insensitive string comparison as fallback
          isSentByMe = normalizedSenderId.toLowerCase() == normalizedCurrentUserId.toLowerCase();
        }
      }
      
      // Debug logging for troubleshooting (only log mismatches to avoid spam)
      if (!isSentByMe && normalizedSenderId.isNotEmpty && normalizedCurrentUserId.isNotEmpty) {
        debugPrint('Message sender ID mismatch - Sender: "$normalizedSenderId", Current User: "$normalizedCurrentUserId"');
      }
    }
    
    // Parse chat ID (can be nested in group_chat or direct)
    final groupChatData = json['group_chat'] as Map<String, dynamic>?;
    final chatId = groupChatData?['id']?.toString() ?? 
                  json['group_chat_id']?.toString() ?? 
                  json['chatId']?.toString() ?? 
                  '';
    
    return MessageModel(
      id: json['id']?.toString() ?? '',
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      senderProfileImage: senderProfileImage,
      message: message,
      timestamp: timestamp,
      isSentByMe: isSentByMe,
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
        orElse: () => MessageType.text,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isSentByMe': isSentByMe,
      'type': type.toString().split('.').last,
    };
  }

  MessageModel copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? senderName,
    String? senderProfileImage,
    String? message,
    DateTime? timestamp,
    bool? isSentByMe,
    MessageType? type,
  }) {
    return MessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderProfileImage: senderProfileImage ?? this.senderProfileImage,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isSentByMe: isSentByMe ?? this.isSentByMe,
      type: type ?? this.type,
    );
  }
}

enum MessageType {
  text,
  image,
  file,
}

