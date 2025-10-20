// lib/models/worker_search_model.dart
// Model مطابق لـ WorkerProfileListSerializer في Backend

class WorkerSearchResult {
  final int id;
  final String name;
  final String service;
  final String category;
  final double rating;
  final String distance;
  final String time;
  final String? image;
  final bool isFavorite;
  final String area;
  final String phone;
  final List<String> services;

  // Location fields
  final bool locationSharingEnabled;
  final bool currentLocationAvailable;
  final double? distanceFromClient;
  final DateTime? locationLastUpdated;

  WorkerSearchResult({
    required this.id,
    required this.name,
    required this.service,
    required this.category,
    required this.rating,
    required this.distance,
    required this.time,
    this.image,
    required this.isFavorite,
    required this.area,
    required this.phone,
    required this.services,
    required this.locationSharingEnabled,
    required this.currentLocationAvailable,
    this.distanceFromClient,
    this.locationLastUpdated,
  });

  /// From JSON - مطابق للـ Backend response
  factory WorkerSearchResult.fromJson(Map<String, dynamic> json) {
    // استخراج services list
    List<String> servicesList = [];
    if (json['services'] != null) {
      servicesList = List<String>.from(json['services']);
    }

    // حساب distance_from_client إذا موجود
    double? calculatedDistance;
    if (json['distance_from_client'] != null) {
      calculatedDistance =
          double.tryParse(json['distance_from_client'].toString());
    }

    return WorkerSearchResult(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      service: json['service'] ?? '',
      category: json['category'] ?? '',
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      distance: json['distance'] ?? '',
      time: json['time'] ?? '15 Min',
      image: json['image'],
      isFavorite: json['isFavorite'] ?? false,
      area: json['area'] ?? '',
      phone: json['phone'] ?? '',
      services: servicesList,
      locationSharingEnabled: json['location_sharing_enabled'] ?? false,
      currentLocationAvailable: json['current_location_available'] ?? false,
      distanceFromClient: calculatedDistance,
      locationLastUpdated: json['location_last_updated'] != null
          ? DateTime.tryParse(json['location_last_updated'])
          : null,
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'service': service,
      'category': category,
      'rating': rating,
      'distance': distance,
      'time': time,
      'image': image,
      'isFavorite': isFavorite,
      'area': area,
      'phone': phone,
      'services': services,
      'location_sharing_enabled': locationSharingEnabled,
      'current_location_available': currentLocationAvailable,
      'distance_from_client': distanceFromClient,
      'location_last_updated': locationLastUpdated?.toIso8601String(),
    };
  }

  /// CopyWith للتعديل
  WorkerSearchResult copyWith({
    int? id,
    String? name,
    String? service,
    String? category,
    double? rating,
    String? distance,
    String? time,
    String? image,
    bool? isFavorite,
    String? area,
    String? phone,
    List<String>? services,
    bool? locationSharingEnabled,
    bool? currentLocationAvailable,
    double? distanceFromClient,
    DateTime? locationLastUpdated,
  }) {
    return WorkerSearchResult(
      id: id ?? this.id,
      name: name ?? this.name,
      service: service ?? this.service,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      distance: distance ?? this.distance,
      time: time ?? this.time,
      image: image ?? this.image,
      isFavorite: isFavorite ?? this.isFavorite,
      area: area ?? this.area,
      phone: phone ?? this.phone,
      services: services ?? this.services,
      locationSharingEnabled:
          locationSharingEnabled ?? this.locationSharingEnabled,
      currentLocationAvailable:
          currentLocationAvailable ?? this.currentLocationAvailable,
      distanceFromClient: distanceFromClient ?? this.distanceFromClient,
      locationLastUpdated: locationLastUpdated ?? this.locationLastUpdated,
    );
  }

  @override
  String toString() {
    return 'WorkerSearchResult{id: $id, name: $name, category: $category}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkerSearchResult && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
