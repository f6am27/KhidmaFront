// lib/models/saved_location_model.dart

import 'package:google_maps_flutter/google_maps_flutter.dart';

/// ════════════════════════════════════════════════════════════
/// SavedLocation Model - للمواقع المحفوظة
/// ════════════════════════════════════════════════════════════
class SavedLocation {
  final String id;
  final String? name; // اسم اختياري مثل "المنزل"
  final String address; // العنوان الكامل
  final double latitude;
  final double longitude;
  final String emoji; // الإيموجي
  final int usageCount; // عدد مرات الاستخدام
  final DateTime lastUsedAt; // آخر استخدام
  final DateTime createdAt;

  SavedLocation({
    required this.id,
    this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.emoji = '📍',
    required this.usageCount,
    required this.lastUsedAt,
    required this.createdAt,
  });

  /// Create from Backend JSON
  factory SavedLocation.fromJson(Map<String, dynamic> json) {
    return SavedLocation(
      id: json['id'].toString(),
      name: json['name'],
      address: json['address'] ?? '',
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      emoji: json['emoji'] ?? '📍',
      usageCount: int.parse(json['usage_count']?.toString() ?? '0'),
      lastUsedAt: DateTime.parse(json['last_used_at']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  /// Convert to JSON for Backend
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'emoji': emoji,
    };
  }

  /// Display name - يعرض الاسم أو الإيموجي
  String get displayName {
    if (name != null && name!.isNotEmpty) {
      return '$emoji $name';
    }
    return emoji;
  }

  /// Convert to LatLng
  LatLng get coordinates => LatLng(latitude, longitude);

  /// Copy with method
  SavedLocation copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? emoji,
    int? usageCount,
    DateTime? lastUsedAt,
    DateTime? createdAt,
  }) {
    return SavedLocation(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      emoji: emoji ?? this.emoji,
      usageCount: usageCount ?? this.usageCount,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'SavedLocation(id: $id, name: $name, address: $address, usageCount: $usageCount)';
  }
}
