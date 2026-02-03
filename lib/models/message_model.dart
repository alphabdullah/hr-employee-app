// import 'package:flutter/foundation.dart';

// /// Model class for Chat Message
// class MessageModel {
//   final String id;
//   final String chatId;
//   final String senderId;
//   final String senderName;
//   final String? senderProfileImage;
//   final String message;
//   final DateTime timestamp;
//   final bool isSentByMe;
//   final MessageType type;

//   MessageModel({
//     required this.id,
//     required this.chatId,
//     required this.senderId,
//     required this.senderName,
//     this.senderProfileImage,
//     required this.message,
//     required this.timestamp,
//     required this.isSentByMe,
//     this.type = MessageType.text,
//   });

//   factory MessageModel.fromJson(
//     Map<String, dynamic> json, {
//     String? currentUserId,
//   }) {
//     // Parse sender information (can be nested in sender, employee, or direct)
//     final senderData = json['sender'] as Map<String, dynamic>?;
//     final employeeData = json['employee'] as Map<String, dynamic>?;
//     // Use employee data if available, otherwise fall back to sender data
//     final userData = employeeData ?? senderData;
    
//     // Try multiple possible field names for sender ID
//     final senderId = userData?['id']?.toString() ?? 
//                    userData?['employee_id']?.toString() ?? 
//                    userData?['employeeId']?.toString() ??
//                    json['sender_id']?.toString() ?? 
//                    json['senderId']?.toString() ??
//                    json['employee_id']?.toString() ??
//                    json['employeeId']?.toString() ??
//                    '';
//     final senderName = userData?['full_name']?.toString() ?? 
//                       userData?['name']?.toString() ?? 
//                       userData?['fullName']?.toString() ?? 
//                       json['sender_name']?.toString() ?? 
//                       json['senderName']?.toString() ?? 
//                       'Unknown';
    
//     // Parse sender profile image
//     final profileImage = userData?['profile_image'];
//     final String? senderProfileImage;
//     if (profileImage == null || profileImage == 'null' || profileImage.toString().isEmpty) {
//       senderProfileImage = null;
//     } else {
//       senderProfileImage = profileImage.toString();
//     }
    
//     // Parse message content
//     final message = json['message']?.toString() ?? '';
    
//     // Parse timestamp (prioritize sent_at, then created_at, then timestamp)
//     DateTime timestamp = DateTime.now();
//     if (json['sent_at'] != null) {
//       try {
//         timestamp = DateTime.parse(json['sent_at']);
//       } catch (e) {
//         // Keep default
//       }
//     } else if (json['created_at'] != null) {
//       try {
//         timestamp = DateTime.parse(json['created_at']);
//       } catch (e) {
//         // Keep default
//       }
//     } else if (json['timestamp'] != null) {
//       try {
//         timestamp = DateTime.parse(json['timestamp']);
//       } catch (e) {
//         // Keep default
//       }
//     }
    
//     // Determine if message is sent by current user
//     // Compare IDs as strings (handle both string and numeric IDs)
//     bool isSentByMe = false;
//     if (currentUserId != null && senderId.isNotEmpty) {
//       // Normalize both IDs by trimming and converting to string
//       final normalizedSenderId = senderId.trim();
//       final normalizedCurrentUserId = currentUserId.trim();
      
//       // Try direct string comparison first
//       if (normalizedSenderId == normalizedCurrentUserId) {
//         isSentByMe = true;
//       } else {
//         // Try numeric comparison (in case one is "1" and other is 1, or different formats)
//         try {
//           final senderIdNum = int.parse(normalizedSenderId);
//           final currentUserIdNum = int.parse(normalizedCurrentUserId);
//           isSentByMe = senderIdNum == currentUserIdNum;
//         } catch (e) {
//           // If parsing fails, try case-insensitive string comparison as fallback
//           isSentByMe = normalizedSenderId.toLowerCase() == normalizedCurrentUserId.toLowerCase();
//         }
//       }
      
//       // Debug logging for troubleshooting (only log mismatches to avoid spam)
//       if (!isSentByMe && normalizedSenderId.isNotEmpty && normalizedCurrentUserId.isNotEmpty) {
//         debugPrint('Message sender ID mismatch - Sender: "$normalizedSenderId", Current User: "$normalizedCurrentUserId"');
//       }
//     }
    
//     // Parse chat ID (can be nested in group_chat or direct)
//     final groupChatData = json['group_chat'] as Map<String, dynamic>?;
//     final chatId = groupChatData?['id']?.toString() ?? 
//                   json['group_chat_id']?.toString() ?? 
//                   json['chatId']?.toString() ?? 
//                   '';
    
//     return MessageModel(
//       id: json['id']?.toString() ?? '',
//       chatId: chatId,
//       senderId: senderId,
//       senderName: senderName,
//       senderProfileImage: senderProfileImage,
//       message: message,
//       timestamp: timestamp,
//       isSentByMe: isSentByMe,
//       type: MessageType.values.firstWhere(
//         (e) => e.toString() == 'MessageType.${json['type']}',
//         orElse: () => MessageType.text,
//       ),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'chatId': chatId,
//       'senderId': senderId,
//       'senderName': senderName,
//       'message': message,
//       'timestamp': timestamp.toIso8601String(),
//       'isSentByMe': isSentByMe,
//       'type': type.toString().split('.').last,
//     };
//   }

//   MessageModel copyWith({
//     String? id,
//     String? chatId,
//     String? senderId,
//     String? senderName,
//     String? senderProfileImage,
//     String? message,
//     DateTime? timestamp,
//     bool? isSentByMe,
//     MessageType? type,
//   }) {
//     return MessageModel(
//       id: id ?? this.id,
//       chatId: chatId ?? this.chatId,
//       senderId: senderId ?? this.senderId,
//       senderName: senderName ?? this.senderName,
//       senderProfileImage: senderProfileImage ?? this.senderProfileImage,
//       message: message ?? this.message,
//       timestamp: timestamp ?? this.timestamp,
//       isSentByMe: isSentByMe ?? this.isSentByMe,
//       type: type ?? this.type,
//     );
//   }
// }

// enum MessageType {
//   text,
//   image,
//   file,
// }

import 'package:flutter/foundation.dart';

/// Model class for Chat / Group Message
class MessageModel {
  final String id;
  final String chatId; // we'll reuse this field even for groups
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
    String? currentUserId, // still useful as fallback
  }) {
    // ───────────────────────────────────────────────
    // Priority: use 'is_me' field if it exists (new group API style)
    // Fallback: compare user_id with currentUserId (old style)
    // ───────────────────────────────────────────────
    bool isSentByMe = false;

    if (json.containsKey('is_me')) {
      isSentByMe = json['is_me'] == true;
    } else if (currentUserId != null && currentUserId.isNotEmpty) {
      final senderIdStr = json['user_id']?.toString() ?? '';
      final normalizedSender = senderIdStr.trim();
      final normalizedCurrent = currentUserId.trim();

      // Direct string match
      if (normalizedSender == normalizedCurrent) {
        isSentByMe = true;
      } else {
        // Numeric fallback
        try {
          final senderNum = int.parse(normalizedSender);
          final currentNum = int.parse(normalizedCurrent);
          isSentByMe = senderNum == currentNum;
        } catch (_) {
          // case-insensitive fallback
          isSentByMe = normalizedSender.toLowerCase() == normalizedCurrent.toLowerCase();
        }
      }

      // Optional debug (only when mismatch)
      if (!isSentByMe && normalizedSender.isNotEmpty && normalizedCurrent.isNotEmpty) {
        debugPrint(
          'Message sender mismatch → user_id: "$normalizedSender", current: "$normalizedCurrent"',
        );
      }
    }

    return MessageModel(
      id: json['id']?.toString() ?? '',
      chatId: '', // group endpoint doesn't return chatId → leave empty or pass from outside if needed
      senderId: json['user_id']?.toString() ?? '',
      senderName: json['user_name']?.toString() ?? 'Unknown',
      senderProfileImage: null, // not present in current response — can add later
      message: json['body']?.toString() ?? '', // ← changed from 'message' to 'body'
      timestamp: _parseTimestamp(json),
      isSentByMe: isSentByMe,
      type: MessageType.text, // for now — can extend later
    );
  }

  // Helper to handle different timestamp formats
  static DateTime _parseTimestamp(Map<String, dynamic> json) {
    final candidates = [
      json['created_at'],
      json['sent_at'],
      json['timestamp'],
    ];

    for (final candidate in candidates) {
      if (candidate != null && candidate.toString().isNotEmpty) {
        try {
          return DateTime.parse(candidate.toString());
        } catch (_) {
          // continue to next
        }
      }
    }

    return DateTime.now();
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