// lib/services/service_category_mapper.dart
import '../models/service_category_model.dart';

class ServiceCategoryMapper {
  static Map<String, int> _serviceTypeToId = {};

  /// تهيئة الـ mapping من الـ categories المسحوبة من Backend
  static void initialize(List<ServiceCategory> categories) {
    _serviceTypeToId = {for (var cat in categories) cat.name: cat.id};
  }

  static int? getCategoryId(String serviceType) {
    return _serviceTypeToId[serviceType];
  }

  static String? getServiceType(int categoryId) {
    final entry = _serviceTypeToId.entries.firstWhere(
      (entry) => entry.value == categoryId,
      orElse: () => MapEntry('', 0),
    );
    return entry.key.isNotEmpty ? entry.key : null;
  }

  static bool isValidServiceType(String serviceType) {
    return _serviceTypeToId.containsKey(serviceType);
  }
}
