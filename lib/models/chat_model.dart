// /// Model class for Chat list item (Group Chat linked to Job)
// class ChatModel {
//   final String id;
//   final String jobId; // ID of the job this chat is for
//   final String jobTitle; // Title of the job (used as chat name)
//   final DateTime lastMessageTime;
//   final String lastMessage;
//   final String? avatarUrl;
//   final String? jobImage;
//   final int unreadCount;
//   final int memberCount; // Number of members in the group chat

//   ChatModel({
//     required this.id,
//     required this.jobId,
//     required this.jobTitle,
//     required this.lastMessage,
//     required this.lastMessageTime,
//     this.avatarUrl,
//     this.jobImage,
//     this.unreadCount = 0,
//     this.memberCount = 0,
//   });

//   // For backward compatibility, name property returns jobTitle
//   String get name => jobTitle;

//   factory ChatModel.fromJson(Map<String, dynamic> json) {
//     // Parse job information (can be nested or direct)
//     final jobData = json['job'] as Map<String, dynamic>?;
//     final jobId = jobData?['id']?.toString() ?? 
//                  json['job_id']?.toString() ?? 
//                  json['jobId']?.toString() ?? '';
//     final jobTitle = jobData?['job_title']?.toString() ?? 
//                     jobData?['jobTitle']?.toString() ?? 
//                     json['job_title']?.toString() ?? 
//                     json['jobTitle']?.toString() ?? 
//                     json['name']?.toString() ?? 
//                     '';
    
//     // Parse last message (can be nested in latest_message or direct)
//     final latestMessage = json['latest_message'] as Map<String, dynamic>?;
//     final lastMessage = latestMessage?['message']?.toString() ?? 
//                        json['last_message']?.toString() ?? 
//                        json['lastMessage']?.toString() ?? 
//                        '';
    
//     // Parse last message time
//     DateTime lastMessageTime = DateTime.now();
//     if (latestMessage?['created_at'] != null) {
//       try {
//         lastMessageTime = DateTime.parse(latestMessage!['created_at']);
//       } catch (e) {
//         // Keep default
//       }
//     } else if (json['last_message_time'] != null) {
//       try {
//         lastMessageTime = DateTime.parse(json['last_message_time']);
//       } catch (e) {
//         // Keep default
//       }
//     } else if (json['lastMessageTime'] != null) {
//       try {
//         lastMessageTime = DateTime.parse(json['lastMessageTime']);
//       } catch (e) {
//         // Keep default
//       }
//     }
    
//     // Parse member count
//     final memberCount = json['member_count'] ?? 
//                        json['memberCount'] ?? 
//                        json['members_count'] ?? 
//                        0;
    
//     // Parse unread count (if available)
//     final unreadCount = json['unread_count'] ?? 
//                        json['unreadCount'] ?? 
//                        0;
    
//     return ChatModel(
//       id: json['id']?.toString() ?? '',
//       jobId: jobId,
//       jobTitle: jobTitle,
//       lastMessage: lastMessage,
//       lastMessageTime: lastMessageTime,
//       avatarUrl: json['avatar_url'] ?? json['avatarUrl'],
//       jobImage: jobData?['job_image']?.toString() ??
//           jobData?['jobImage']?.toString(),
//       unreadCount: unreadCount is int ? unreadCount : 0,
//       memberCount: memberCount is int ? memberCount : 0,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'jobId': jobId,
//       'jobTitle': jobTitle,
//       'lastMessage': lastMessage,
//       'lastMessageTime': lastMessageTime.toIso8601String(),
//       'avatarUrl': avatarUrl,
//       'jobImage': jobImage,
//       'unreadCount': unreadCount,
//       'memberCount': memberCount,
//     };
//   }

//   ChatModel copyWith({
//     String? id,
//     String? jobId,
//     String? jobTitle,
//     String? lastMessage,
//     DateTime? lastMessageTime,
//     String? avatarUrl,
//     int? unreadCount,
//     int? memberCount,
//   }) {
//     return ChatModel(
//       id: id ?? this.id,
//       jobId: jobId ?? this.jobId,
//       jobTitle: jobTitle ?? this.jobTitle,
//       lastMessage: lastMessage ?? this.lastMessage,
//       lastMessageTime: lastMessageTime ?? this.lastMessageTime,
//       avatarUrl: avatarUrl ?? this.avatarUrl,
//       jobImage: jobImage ?? this.jobImage,
//       unreadCount: unreadCount ?? this.unreadCount,
//       memberCount: memberCount ?? this.memberCount,
//     );
//   }
// }

