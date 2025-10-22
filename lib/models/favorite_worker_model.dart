// lib/models/favorite_worker_model.dart
class FavoriteWorker {
  final int id;
  final int workerId;
  final String name;
  final double rating;
  final int reviewCount;
  final String location;
  final int completedJobs;
  final bool isOnline;
  final String? profileImage;
  final List<String> services;
  final double startingPrice;
  final DateTime? lastSeen;
  final DateTime addedAt;
  final int timesHired;
  final double totalSpent;
  final String? notes;
  final String phone;

  FavoriteWorker({
    required this.id,
    required this.workerId,
    required this.name,
    required this.rating,
    required this.reviewCount,
    required this.location,
    required this.completedJobs,
    required this.isOnline,
    this.profileImage,
    required this.services,
    required this.startingPrice,
    this.lastSeen,
    required this.addedAt,
    required this.timesHired,
    required this.totalSpent,
    this.notes,
    required this.phone,
  });

  factory FavoriteWorker.fromJson(Map<String, dynamic> json) {
    return FavoriteWorker(
      id: json['id'] ?? 0,
      workerId: json['worker_id'] ?? 0,
      name: json['name'] ?? '',
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      reviewCount: json['reviewCount'] ?? 0, // ✅ هذا صحيح (من Serializer)
      location: json['location'] ?? '',
      completedJobs: json['completedJobs'] ?? 0, // ✅ هذا صحيح
      isOnline: json['isOnline'] ?? false, // ✅ هذا صحيح
      profileImage: json['profileImage'], // ✅ هذا صحيح
      services: List<String>.from(json['services'] ?? []),
      startingPrice:
          double.tryParse(json['startingPrice']?.toString() ?? '0') ?? 0.0,
      lastSeen:
          json['lastSeen'] != null ? DateTime.parse(json['lastSeen']) : null,
      addedAt:
          DateTime.parse(json['addedAt'] ?? DateTime.now().toIso8601String()),
      timesHired: json['timesHired'] ?? 0,
      totalSpent: double.tryParse(json['totalSpent']?.toString() ?? '0') ?? 0.0,
      notes: json['notes'],
      phone: json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'worker_id': workerId,
      'name': name,
      'rating': rating,
      'reviewCount': reviewCount,
      'location': location,
      'completedJobs': completedJobs,
      'isOnline': isOnline,
      'profileImage': profileImage,
      'services': services,
      'startingPrice': startingPrice,
      'lastSeen': lastSeen?.toIso8601String(),
      'addedAt': addedAt.toIso8601String(),
      'timesHired': timesHired,
      'totalSpent': totalSpent,
      'notes': notes,
      'phone': phone,
    };
  }
}
