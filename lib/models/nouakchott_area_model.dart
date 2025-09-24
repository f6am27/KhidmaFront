// lib/models/nouakchott_area_model.dart
class NouakchottArea {
  final int id;
  final String name;
  final String nameAr;
  final String areaType; // 'district' or 'neighborhood'
  final int? parentId;
  final String? parentName;
  final double? latitude;
  final double? longitude;
  final bool isActive;
  final int order;

  NouakchottArea({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.areaType,
    this.parentId,
    this.parentName,
    this.latitude,
    this.longitude,
    required this.isActive,
    required this.order,
  });

  // Get localized name based on language
  String getLocalizedName(String languageCode) {
    return languageCode == 'ar' ? nameAr : name;
  }

  // Check if this is a district or neighborhood
  bool get isDistrict => areaType == 'district';
  bool get isNeighborhood => areaType == 'neighborhood';

  // Get display name with type
  String get displayName {
    final typeText = isDistrict ? 'District' : 'Quartier';
    return '$name ($typeText)';
  }

  // From JSON
  factory NouakchottArea.fromJson(Map<String, dynamic> json) {
    return NouakchottArea(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      nameAr: json['name_ar'] ?? '',
      areaType: json['area_type'] ?? 'district',
      parentId: json['parent'],
      parentName: json['parent_name'],
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      isActive: json['is_active'] ?? true,
      order: json['order'] ?? 0,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_ar': nameAr,
      'area_type': areaType,
      'parent': parentId,
      'parent_name': parentName,
      'latitude': latitude,
      'longitude': longitude,
      'is_active': isActive,
      'order': order,
    };
  }

  // Copy with
  NouakchottArea copyWith({
    int? id,
    String? name,
    String? nameAr,
    String? areaType,
    int? parentId,
    String? parentName,
    double? latitude,
    double? longitude,
    bool? isActive,
    int? order,
  }) {
    return NouakchottArea(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      areaType: areaType ?? this.areaType,
      parentId: parentId ?? this.parentId,
      parentName: parentName ?? this.parentName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
    );
  }

  @override
  String toString() {
    return 'NouakchottArea{id: $id, name: $name, type: $areaType}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NouakchottArea && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
