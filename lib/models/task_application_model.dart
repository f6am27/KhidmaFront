/// Application Status Enum - متزامن مع Backend
enum ApplicationStatus {
  pending,
  accepted,
  rejected;

  /// Convert from Backend string to enum
  static ApplicationStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return ApplicationStatus.pending;
      case 'accepted':
        return ApplicationStatus.accepted;
      case 'rejected':
        return ApplicationStatus.rejected;
      default:
        return ApplicationStatus.pending;
    }
  }

  /// Convert to Backend string format
  String toBackendString() {
    switch (this) {
      case ApplicationStatus.pending:
        return 'pending';
      case ApplicationStatus.accepted:
        return 'accepted';
      case ApplicationStatus.rejected:
        return 'rejected';
    }
  }

  /// Display text in French (for UI)
  String get displayText {
    switch (this) {
      case ApplicationStatus.pending:
        return 'En attente';
      case ApplicationStatus.accepted:
        return 'Acceptée';
      case ApplicationStatus.rejected:
        return 'Refusée';
    }
  }
}

/// Task Application Model (Candidate) - من Backend TaskApplication
class TaskApplicationModel {
  final String id;
  final String name;
  final double rating;
  final int reviewCount;
  final String location;
  final int completedJobs;
  final int proposedPrice;
  final String availableTime;
  final String applicationMessage;
  final bool isOnline;
  final String? profileImage;
  final ApplicationStatus applicationStatus;
  final DateTime? appliedAt;

  TaskApplicationModel({
    required this.id,
    required this.name,
    required this.rating,
    required this.reviewCount,
    required this.location,
    required this.completedJobs,
    required this.proposedPrice,
    required this.availableTime,
    required this.applicationMessage,
    required this.isOnline,
    this.profileImage,
    this.applicationStatus = ApplicationStatus.pending,
    this.appliedAt,
  });

  /// Create from Backend JSON response
  factory TaskApplicationModel.fromJson(Map<String, dynamic> json) {
    return TaskApplicationModel(
      id: json['id']?.toString() ?? json['worker_id']?.toString() ?? '0',
      name: json['name'] ?? '',
      rating: _parseToDouble(json['rating']),
      reviewCount:
          _parseToInt(json['reviewCount'] ?? json['review_count'] ?? 0),
      location: json['location'] ?? '',
      completedJobs:
          _parseToInt(json['completedJobs'] ?? json['completed_jobs'] ?? 0),
      proposedPrice:
          _parseToInt(json['proposedPrice'] ?? json['proposed_price'] ?? 0),
      availableTime: json['availableTime'] ?? json['available_time'] ?? '',
      applicationMessage:
          json['applicationMessage'] ?? json['application_message'] ?? '',
      isOnline: json['isOnline'] ?? json['is_online'] ?? false,
      profileImage: json['profileImage'] ?? json['profile_image'],
      applicationStatus: json['applicationStatus'] != null
          ? ApplicationStatus.fromString(json['applicationStatus'])
          : (json['application_status'] != null
              ? ApplicationStatus.fromString(json['application_status'])
              : ApplicationStatus.pending),
      appliedAt: _parseDateTime(json['appliedAt'] ?? json['applied_at']),
    );
  }

  /// Convert to JSON for Backend API
  Map<String, dynamic> toJson() {
    return {
      'application_message': applicationMessage,
    };
  }

  /// Copy with method for updating fields
  TaskApplicationModel copyWith({
    String? id,
    String? name,
    double? rating,
    int? reviewCount,
    String? location,
    int? completedJobs,
    int? proposedPrice,
    String? availableTime,
    String? applicationMessage,
    bool? isOnline,
    String? profileImage,
    ApplicationStatus? applicationStatus,
    DateTime? appliedAt,
  }) {
    return TaskApplicationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      location: location ?? this.location,
      completedJobs: completedJobs ?? this.completedJobs,
      proposedPrice: proposedPrice ?? this.proposedPrice,
      availableTime: availableTime ?? this.availableTime,
      applicationMessage: applicationMessage ?? this.applicationMessage,
      isOnline: isOnline ?? this.isOnline,
      profileImage: profileImage ?? this.profileImage,
      applicationStatus: applicationStatus ?? this.applicationStatus,
      appliedAt: appliedAt ?? this.appliedAt,
    );
  }

  // Helper methods
  static int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  @override
  String toString() {
    return 'TaskApplicationModel(id: $id, name: $name, rating: $rating, status: ${applicationStatus.displayText})';
  }
}

/// Candidate Model - نفس TaskApplicationModel (للتوافق مع الكود الموجود)
typedef CandidateModel = TaskApplicationModel;
