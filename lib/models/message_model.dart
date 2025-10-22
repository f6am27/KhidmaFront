// lib/data/models/message_model.dart

class MessageModel {
  final int id;
  final String content;
  final UserProfileModel sender;
  final bool isFromMe;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;
  final String timeAgo;

  MessageModel({
    required this.id,
    required this.content,
    required this.sender,
    required this.isFromMe,
    required this.isRead,
    required this.createdAt,
    this.readAt,
    required this.timeAgo,
  });

  // من JSON (من الباك إند)
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      content: json['content'] ?? '',
      sender: UserProfileModel.fromJson(json['sender']),
      isFromMe: json['is_from_me'] ?? false,
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      timeAgo: json['time_ago'] ?? '',
    );
  }

  // إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'sender': sender.toJson(),
      'is_from_me': isFromMe,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
      'time_ago': timeAgo,
    };
  }

  // نسخة معدلة من الكائن
  MessageModel copyWith({
    int? id,
    String? content,
    UserProfileModel? sender,
    bool? isFromMe,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
    String? timeAgo,
  }) {
    return MessageModel(
      id: id ?? this.id,
      content: content ?? this.content,
      sender: sender ?? this.sender,
      isFromMe: isFromMe ?? this.isFromMe,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      timeAgo: timeAgo ?? this.timeAgo,
    );
  }
}

// نموذج معلومات المستخدم (مشترك مع conversation_model)
class UserProfileModel {
  final int id;
  final String fullName;
  final String role;
  final String? profileImageUrl;
  final bool isOnline;

  UserProfileModel({
    required this.id,
    required this.fullName,
    required this.role,
    this.profileImageUrl,
    required this.isOnline,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'],
      fullName: json['full_name'] ?? '',
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
