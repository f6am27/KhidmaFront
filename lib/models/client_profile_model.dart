// lib/models/client_profile_model.dart
class ClientProfile {
  final int id;
  final String phone;
  final String? firstName;
  final String? lastName;
  final String? gender;
  final String? address;
  final String? emergencyContact;
  final String? profileImageUrl;
  final int totalTasksPublished;
  final int totalTasksCompleted;
  final double totalAmountSpent;
  final bool notificationsEnabled;
  final bool isVerified;
  final String memberSince;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isOnline;
  final DateTime? lastSeen;

  ClientProfile({
    required this.id,
    required this.phone,
    this.firstName,
    this.lastName,
    this.gender,
    this.address,
    this.emergencyContact,
    this.profileImageUrl,
    required this.totalTasksPublished,
    required this.totalTasksCompleted,
    required this.totalAmountSpent,
    required this.notificationsEnabled,
    required this.isVerified,
    required this.memberSince,
    required this.createdAt,
    required this.updatedAt,
    required this.isOnline,
    this.lastSeen,
  });

  // Computed properties
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName'.trim();
    }
    return firstName ?? phone;
  }

  double get successRate {
    if (totalTasksPublished == 0) return 0.0;
    return (totalTasksCompleted / totalTasksPublished) * 100;
  }

  // From JSON - compatible with /api/clients/profile/
  factory ClientProfile.fromJson(Map<String, dynamic> json) {
    return ClientProfile(
      id: json['id'] ?? 0,
      phone: json['phone'] ?? '',
      firstName: json['first_name'],
      lastName: json['last_name'],
      gender: json['gender'],
      address: json['address'],
      emergencyContact: json['emergency_contact'],
      profileImageUrl: json['profile_image_url'],
      totalTasksPublished: json['total_tasks_published'] ?? 0,
      totalTasksCompleted: json['total_tasks_completed'] ?? 0,
      totalAmountSpent:
          double.tryParse(json['total_amount_spent']?.toString() ?? '0') ?? 0.0,
      notificationsEnabled: json['notifications_enabled'] ?? true,
      isVerified: json['is_verified'] ?? false,
      memberSince: json['member_since'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      isOnline: json['is_online'] ?? false,
      lastSeen: json['last_seen'] != null
          ? DateTime.tryParse(json['last_seen'])
          : null,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'first_name': firstName,
      'last_name': lastName,
      'gender': gender,
      'address': address,
      'emergency_contact': emergencyContact,
      'profile_image_url': profileImageUrl,
      'total_tasks_published': totalTasksPublished,
      'total_tasks_completed': totalTasksCompleted,
      'total_amount_spent': totalAmountSpent,
      'notifications_enabled': notificationsEnabled,
      'is_verified': isVerified,
      'member_since': memberSince,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_online': isOnline,
      'last_seen': lastSeen?.toIso8601String(),
    };
  }

  // Copy with
  ClientProfile copyWith({
    int? id,
    String? phone,
    String? firstName,
    String? lastName,
    String? gender,
    String? address,
    String? emergencyContact,
    String? profileImageUrl,
    int? totalTasksPublished,
    int? totalTasksCompleted,
    double? totalAmountSpent,
    bool? notificationsEnabled,
    bool? isVerified,
    String? memberSince,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isOnline,
    DateTime? lastSeen,
  }) {
    return ClientProfile(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      totalTasksPublished: totalTasksPublished ?? this.totalTasksPublished,
      totalTasksCompleted: totalTasksCompleted ?? this.totalTasksCompleted,
      totalAmountSpent: totalAmountSpent ?? this.totalAmountSpent,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      isVerified: isVerified ?? this.isVerified,
      memberSince: memberSince ?? this.memberSince,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  @override
  String toString() {
    return 'ClientProfile{id: $id, fullName: $fullName, tasksPublished: $totalTasksPublished, isOnline: $isOnline}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClientProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
