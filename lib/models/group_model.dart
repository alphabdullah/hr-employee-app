// lib/models/group_model.dart  (new file or add to existing models)

class GroupModel {
  final String id;
  final String name;
  final String region;
  final int membersCount;
  final DateTime? lastMessageAt;
  final String? lastMessagePreview;

  GroupModel({
    required this.id,
    required this.name,
    required this.region,
    required this.membersCount,
    this.lastMessageAt,
    this.lastMessagePreview,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unnamed Group',
      region: json['region']?.toString() ?? '',
      membersCount: json['members_count'] ?? 0,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.tryParse(json['last_message_at'])
          : null,
      lastMessagePreview: json['last_message_preview']?.toString(),
    );
  }

  // Optional: if you want to show it in same list as ChatModel later
  String get displayName => name;
  String get subtitle => '$membersCount members${region.isNotEmpty ? ' • $region' : ''}';
}