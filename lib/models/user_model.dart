// lib/models/user_model.dart
class User {
  final int id;
  final String? phone;
  final String? firstName;
  final String? lastName;
  final String role; // 'client', 'worker', 'admin'
  final bool isVerified;
  final bool onboardingCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    this.phone,
    this.firstName,
    this.lastName,
    required this.role,
    required this.isVerified,
    required this.onboardingCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  // Computed properties
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName'.trim();
    }
    return firstName ?? phone ?? 'User';
  }

  String get displayIdentifier {
    return phone ?? 'No identifier';
  }

  bool get isWorker => role == 'worker';
  bool get isClient => role == 'client';
  bool get isAdmin => role == 'admin';

  // From JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      phone: json['phone'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      role: json['role'] ?? 'client',
      isVerified: json['is_verified'] ?? false,
      onboardingCompleted: json['onboarding_completed'] ?? false,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
      'is_verified': isVerified,
      'onboarding_completed': onboardingCompleted,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Copy with
  User copyWith({
    int? id,
    String? phone,
    String? firstName,
    String? lastName,
    String? role,
    bool? isVerified,
    bool? onboardingCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'User{id: $id, fullName: $fullName, role: $role}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
