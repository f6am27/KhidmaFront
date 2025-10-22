import 'message_model.dart';
// lib/data/models/conversation_model.dart

class ConversationModel {
  final int id;
  final UserProfileModel otherParticipant;
  final MessageModel? lastMessage;
  final int unreadCount;
  final int totalMessages;
  final String timeAgo;
  final DateTime createdAt;
  final DateTime? lastMessageAt;

  ConversationModel({
    required this.id,
    required this.otherParticipant,
    this.lastMessage,
    required this.unreadCount,
    required this.totalMessages,
    required this.timeAgo,
    required this.createdAt,
    this.lastMessageAt,
  });

  // من JSON (من الباك إند)
  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'],
      otherParticipant: UserProfileModel.fromJson(json['other_participant']),
      lastMessage: json['last_message'] != null
          ? MessageModel.fromJson({
              'id': 0,
              'content': json['last_message']['content'],
              'sender': {
                'id': 0,
                'full_name': json['last_message']['sender_name'],
                'role': '',
                'profile_image_url': null,
                'is_online': false,
              },
              'is_from_me': json['last_message']['is_from_me'],
              'is_read': false,
              'created_at': json['last_message']['created_at'],
              'read_at': null,
              'time_ago': '',
            })
          : null,
      unreadCount: json['unread_count'] ?? 0,
      totalMessages: json['total_messages'] ?? 0,
      timeAgo: json['time_ago'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'])
          : null,
    );
  }

  // إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'other_participant': otherParticipant.toJson(),
      'last_message': lastMessage?.toJson(),
      'unread_count': unreadCount,
      'total_messages': totalMessages,
      'time_ago': timeAgo,
      'created_at': createdAt.toIso8601String(),
      'last_message_at': lastMessageAt?.toIso8601String(),
    };
  }

  // نسخة معدلة من الكائن
  ConversationModel copyWith({
    int? id,
    UserProfileModel? otherParticipant,
    MessageModel? lastMessage,
    int? unreadCount,
    int? totalMessages,
    String? timeAgo,
    DateTime? createdAt,
    DateTime? lastMessageAt,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      otherParticipant: otherParticipant ?? this.otherParticipant,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      totalMessages: totalMessages ?? this.totalMessages,
      timeAgo: timeAgo ?? this.timeAgo,
      createdAt: createdAt ?? this.createdAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
    );
  }
}

// نموذج معلومات المستخدم في المحادثة
class UserProfileModel {
  final int? id; // ✅ أضف ?
  final String fullName;
  final String role;
  final String? profileImageUrl;
  final bool isOnline;

  UserProfileModel({
    this.id, // ✅ أزل required
    required this.fullName,
    required this.role,
    this.profileImageUrl,
    required this.isOnline,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'],
      fullName: json['full_name'] ?? 'Unknown',
      role: json['role'] ?? '',
      profileImageUrl: json['profile_image_url'],
      isOnline: json['is_online'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'role': role,
      'profile_image_url': profileImageUrl,
      'is_online': isOnline,
    };
  }
}
