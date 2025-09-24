// lib/models/service_category_model.dart
class ServiceCategory {
  final int id;
  final String name;
  final String nameAr;
  final String icon;
  final String description;
  final String descriptionAr;
  final bool isActive;
  final int order;

  ServiceCategory({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.icon,
    required this.description,
    required this.descriptionAr,
    required this.isActive,
    required this.order,
  });

  // Get localized name based on language
  String getLocalizedName(String languageCode) {
    return languageCode == 'ar' ? nameAr : name;
  }

  // Get localized description based on language
  String getLocalizedDescription(String languageCode) {
    return languageCode == 'ar' ? descriptionAr : description;
  }

  // From JSON
  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      nameAr: json['name_ar'] ?? '',
      icon: json['icon'] ?? '',
      description: json['description'] ?? '',
      descriptionAr: json['description_ar'] ?? '',
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
      'icon': icon,
      'description': description,
      'description_ar': descriptionAr,
      'is_active': isActive,
      'order': order,
    };
  }

  // Copy with
  ServiceCategory copyWith({
    int? id,
    String? name,
    String? nameAr,
    String? icon,
    String? description,
    String? descriptionAr,
    bool? isActive,
    int? order,
  }) {
    return ServiceCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
    );
  }

  @override
  String toString() {
    return 'ServiceCategory{id: $id, name: $name}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServiceCategory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
