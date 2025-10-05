// lib/services/service_category_mapper.dart

/// Maps service type names to their corresponding category IDs in the backend
class ServiceCategoryMapper {
  static const Map<String, int> _serviceTypeToId = {
    'Nettoyage': 1,
    'Plomberie': 2,
    'Électricité': 3,
    'Jardinage': 4,
    'Peinture': 5,
    'Déménagement': 6,
    'Réparation': 7,
    'Cuisine': 8,
    'Autre': 9,
  };

  /// Get category ID from service type name
  static int? getCategoryId(String serviceType) {
    return _serviceTypeToId[serviceType];
  }

  /// Get service type name from category ID
  static String? getServiceType(int categoryId) {
    return _serviceTypeToId.entries
        .firstWhere(
          (entry) => entry.value == categoryId,
          orElse: () => const MapEntry('Autre', 9),
        )
        .key;
  }

  /// Check if service type exists
  static bool isValidServiceType(String serviceType) {
    return _serviceTypeToId.containsKey(serviceType);
  }
}
