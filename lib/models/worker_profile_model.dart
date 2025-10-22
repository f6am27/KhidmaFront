// lib/models/worker_profile_model.dart - Fixed version
class WorkerProfile {
  final int id;
  final String phone;
  final String? firstName;
  final String? lastName;
  final String bio;
  final String serviceArea;
  final String serviceCategory;
  final double basePrice;
  final String? profileImageUrl;
  final List<String> availableDays;
  final String workStartTime; // "08:00"
  final String workEndTime; // "18:00"
  final double? latitude;
  final double? longitude;
  final int totalJobsCompleted;
  final double averageRating;
  final int totalReviews;
  final bool isVerified;
  final bool isAvailable;
  final bool isOnline;
  final DateTime? lastSeen;
  final String memberSince;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Location sharing fields
  final bool locationSharingEnabled;
  final double? currentLatitude;
  final double? currentLongitude;
  final DateTime? locationLastUpdated;
  final String locationStatus; // 'active', 'stale', 'disabled'
  final double? locationAccuracy;

  WorkerProfile({
    required this.id,
    required this.phone,
    this.firstName,
    this.lastName,
    required this.bio,
    required this.serviceArea,
    required this.serviceCategory,
    required this.basePrice,
    this.profileImageUrl,
    required this.availableDays,
    required this.workStartTime,
    required this.workEndTime,
    this.latitude,
    this.longitude,
    required this.totalJobsCompleted,
    required this.averageRating,
    required this.totalReviews,
    required this.isVerified,
    required this.isAvailable,
    required this.isOnline,
    this.lastSeen,
    required this.memberSince,
    required this.createdAt,
    required this.updatedAt,
    required this.locationSharingEnabled,
    this.currentLatitude,
    this.currentLongitude,
    this.locationLastUpdated,
    required this.locationStatus,
    this.locationAccuracy,
  });

  // Computed properties
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName'.trim();
    }
    return firstName ?? phone;
  }

  // Check if location is fresh (within 30 minutes)
  bool get isLocationFresh {
    if (locationLastUpdated == null) return false;
    final now = DateTime.now();
    final diff = now.difference(locationLastUpdated!);
    return diff.inMinutes <= 30;
  }

  // Check if currently available with location
  bool get isCurrentlyAvailableWithLocation {
    return isAvailable &&
        locationSharingEnabled &&
        locationStatus == 'active' &&
        isLocationFresh;
  }

  // FIXED: From JSON to handle nested user object
  factory WorkerProfile.fromJson(Map<String, dynamic> json) {
    // Extract user data from nested object
    final userData = json['user'] as Map<String, dynamic>? ?? {};

    // Format member_since from user creation date
    String memberSince = '';
    if (userData['created_at'] != null) {
      try {
        final createdAt = DateTime.parse(userData['created_at']);
        final months = [
          '',
          'janvier',
          'février',
          'mars',
          'avril',
          'mai',
          'juin',
          'juillet',
          'août',
          'septembre',
          'octobre',
          'novembre',
          'décembre'
        ];
        memberSince = '${months[createdAt.month]} ${createdAt.year}';
      } catch (e) {
        memberSince = 'Récemment';
      }
    }

    return WorkerProfile(
      id: json['id'] ?? 0,
      phone: userData['display_identifier'] ?? '',
      firstName: userData['first_name'],
      lastName: userData['last_name'],
      bio: json['bio'] ?? '',
      serviceArea: json['service_area'] ?? '',
      serviceCategory: json['service_category'] ?? '',
      basePrice: double.tryParse(json['base_price']?.toString() ?? '0') ?? 0.0,
      profileImageUrl: json['profile_image_url'] ?? json['profile_image'],
      availableDays: List<String>.from(json['available_days'] ?? []),
      workStartTime: json['work_start_time'] ?? '08:00',
      workEndTime: json['work_end_time'] ?? '18:00',
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      totalJobsCompleted: json['total_jobs_completed'] ?? 0,
      averageRating:
          double.tryParse(json['average_rating']?.toString() ?? '0') ?? 0.0,
      totalReviews: json['total_reviews'] ?? 0,
      isVerified: json['is_verified'] ?? false,
      isAvailable: json['is_available'] ?? true,
      isOnline: json['is_online'] ?? false,
      lastSeen: json['last_seen'] != null
          ? DateTime.tryParse(json['last_seen'])
          : null,
      memberSince: memberSince,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      locationSharingEnabled: json['location_sharing_enabled'] ?? false,
      currentLatitude: json['current_latitude'] != null
          ? double.tryParse(json['current_latitude'].toString())
          : null,
      currentLongitude: json['current_longitude'] != null
          ? double.tryParse(json['current_longitude'].toString())
          : null,
      locationLastUpdated: json['location_last_updated'] != null
          ? DateTime.tryParse(json['location_last_updated'])
          : null,
      locationStatus: json['location_status'] ?? 'disabled',
      locationAccuracy: json['location_accuracy'] != null
          ? double.tryParse(json['location_accuracy'].toString())
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
      'bio': bio,
      'service_area': serviceArea,
      'service_category': serviceCategory,
      'base_price': basePrice,
      'profile_image_url': profileImageUrl,
      'available_days': availableDays,
      'work_start_time': workStartTime,
      'work_end_time': workEndTime,
      'latitude': latitude,
      'longitude': longitude,
      'total_jobs_completed': totalJobsCompleted,
      'average_rating': averageRating,
      'total_reviews': totalReviews,
      'is_verified': isVerified,
      'is_available': isAvailable,
      'is_online': isOnline,
      'last_seen': lastSeen?.toIso8601String(),
      'member_since': memberSince,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'location_sharing_enabled': locationSharingEnabled,
      'current_latitude': currentLatitude,
      'current_longitude': currentLongitude,
      'location_last_updated': locationLastUpdated?.toIso8601String(),
      'location_status': locationStatus,
      'location_accuracy': locationAccuracy,
    };
  }

  // Copy with
  WorkerProfile copyWith({
    int? id,
    String? phone,
    String? firstName,
    String? lastName,
    String? bio,
    String? serviceArea,
    String? serviceCategory,
    double? basePrice,
    String? profileImageUrl,
    List<String>? availableDays,
    String? workStartTime,
    String? workEndTime,
    double? latitude,
    double? longitude,
    int? totalJobsCompleted,
    double? averageRating,
    int? totalReviews,
    bool? isVerified,
    bool? isAvailable,
    bool? isOnline,
    DateTime? lastSeen,
    String? memberSince,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? locationSharingEnabled,
    double? currentLatitude,
    double? currentLongitude,
    DateTime? locationLastUpdated,
    String? locationStatus,
    double? locationAccuracy,
  }) {
    return WorkerProfile(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      bio: bio ?? this.bio,
      serviceArea: serviceArea ?? this.serviceArea,
      serviceCategory: serviceCategory ?? this.serviceCategory,
      basePrice: basePrice ?? this.basePrice,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      availableDays: availableDays ?? this.availableDays,
      workStartTime: workStartTime ?? this.workStartTime,
      workEndTime: workEndTime ?? this.workEndTime,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      totalJobsCompleted: totalJobsCompleted ?? this.totalJobsCompleted,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      isVerified: isVerified ?? this.isVerified,
      isAvailable: isAvailable ?? this.isAvailable,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      memberSince: memberSince ?? this.memberSince,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      locationSharingEnabled:
          locationSharingEnabled ?? this.locationSharingEnabled,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      locationLastUpdated: locationLastUpdated ?? this.locationLastUpdated,
      locationStatus: locationStatus ?? this.locationStatus,
      locationAccuracy: locationAccuracy ?? this.locationAccuracy,
    );
  }

  @override
  String toString() {
    return 'WorkerProfile{id: $id, fullName: $fullName, category: $serviceCategory}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkerProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
