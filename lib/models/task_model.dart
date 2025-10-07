import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Task Status Enum - متزامن مع Backend
enum TaskStatus {
  published,
  active,
  workCompleted,
  completed,
  cancelled;

  /// Convert from Backend string to enum
  static TaskStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'published':
        return TaskStatus.published;
      case 'active':
        return TaskStatus.active;
      case 'work_completed':
        return TaskStatus.workCompleted;
      case 'completed':
        return TaskStatus.completed;
      case 'cancelled':
        return TaskStatus.cancelled;
      default:
        return TaskStatus.published;
    }
  }

  /// Convert to Backend string format
  String toBackendString() {
    switch (this) {
      case TaskStatus.published:
        return 'published';
      case TaskStatus.active:
        return 'active';
      case TaskStatus.workCompleted:
        return 'work_completed';
      case TaskStatus.completed:
        return 'completed';
      case TaskStatus.cancelled:
        return 'cancelled';
    }
  }

  /// Display text in French (for UI)
  String get displayText {
    switch (this) {
      case TaskStatus.published:
        return 'Publiée';
      case TaskStatus.active:
        return 'En cours';
      case TaskStatus.workCompleted:
        return 'Travail terminé';
      case TaskStatus.completed:
        return 'Terminée';
      case TaskStatus.cancelled:
        return 'Annulée';
    }
  }
}

/// Task Model - ServiceRequest من Backend
class TaskModel {
  final String id;
  final String title;
  final String description;
  final String serviceType;
  final int budget;
  final String location;
  final String preferredTime;
  final TaskStatus status;
  final DateTime createdAt;
  final int applicantsCount;
  final String? assignedProvider;
  final int? providerRating;
  final bool isUrgent;
  final LatLng? coordinates;
  final String? timeDescription; // أضف هذا

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.serviceType,
    required this.budget,
    required this.location,
    required this.preferredTime,
    required this.status,
    required this.createdAt,
    required this.applicantsCount,
    this.assignedProvider,
    this.providerRating,
    this.isUrgent = false,
    this.coordinates,
    this.timeDescription, // أضف هذا
  });

  /// Create from Backend JSON response
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    // Handle coordinates
    LatLng? coords;
    if (json['latitude'] != null && json['longitude'] != null) {
      coords = LatLng(
        double.parse(json['latitude'].toString()),
        double.parse(json['longitude'].toString()),
      );
    } else if (json['coordinates'] != null) {
      final coordsData = json['coordinates'];
      if (coordsData is Map &&
          coordsData['latitude'] != null &&
          coordsData['longitude'] != null) {
        coords = LatLng(
          double.parse(coordsData['latitude'].toString()),
          double.parse(coordsData['longitude'].toString()),
        );
      }
    }

    return TaskModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      serviceType: json['serviceType'] ?? json['service_type'] ?? '',
      budget: _parseToInt(json['budget']),
      location: json['location'] ?? '',
      preferredTime: json['preferredTime'] ?? json['preferred_time'] ?? '',
      status: TaskStatus.fromString(json['status'] ?? 'published'),
      createdAt: _parseDateTime(json['createdAt'] ?? json['created_at']),
      applicantsCount:
          _parseToInt(json['applicantsCount'] ?? json['applicants_count'] ?? 0),
      assignedProvider: json['assignedProvider'] ?? json['assigned_provider'],
      providerRating: json['providerRating'] != null
          ? _parseToInt(json['providerRating'])
          : (json['provider_rating'] != null
              ? _parseToInt(json['provider_rating'])
              : null),
      isUrgent: json['isUrgent'] ?? json['is_urgent'] ?? false,
      coordinates: coords,
      timeDescription: json['timeDescription'] ?? json['time_description'],
    );
  }

  /// Convert to JSON for Backend API
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'title': title,
      'description': description,
      'serviceType': serviceType,
      'budget': budget,
      'location': location,
      'preferredTime': preferredTime,
      'is_urgent': isUrgent,
    };

    // Add coordinates if available
    if (coordinates != null) {
      data['latitude'] = coordinates!.latitude;
      data['longitude'] = coordinates!.longitude;
    }

    return data;
  }

  /// Copy with method for updating fields
  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? serviceType,
    int? budget,
    String? location,
    String? preferredTime,
    TaskStatus? status,
    DateTime? createdAt,
    int? applicantsCount,
    String? assignedProvider,
    int? providerRating,
    bool? isUrgent,
    LatLng? coordinates,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      serviceType: serviceType ?? this.serviceType,
      budget: budget ?? this.budget,
      location: location ?? this.location,
      preferredTime: preferredTime ?? this.preferredTime,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      applicantsCount: applicantsCount ?? this.applicantsCount,
      assignedProvider: assignedProvider ?? this.assignedProvider,
      providerRating: providerRating ?? this.providerRating,
      isUrgent: isUrgent ?? this.isUrgent,
      coordinates: coordinates ?? this.coordinates,
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

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  @override
  String toString() {
    return 'TaskModel(id: $id, title: $title, status: ${status.displayText}, budget: $budget MRU)';
  }
}
