// lib/services/category_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';
import '../core/storage/token_storage.dart';
import '../models/service_category_model.dart';
import '../models/nouakchott_area_model.dart';

class CategoryService {
  final String _baseUrl = ApiConfig.baseUrl().replaceAll('/users', '');
  final http.Client _client = http.Client();

  /// Get all service categories
  Future<Map<String, dynamic>> getServiceCategories({String? lang}) async {
    try {
      String url = '$_baseUrl/services/categories/';
      if (lang != null) {
        url += '?lang=$lang';
      }

      final response = await _client.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      final json = _parseResponse(response);

      if (response.statusCode == 200) {
        final List<dynamic> data = (json is List) ? json : [];
        final categories = data
            .map((item) =>
                ServiceCategory.fromJson(item as Map<String, dynamic>))
            .toList();

        return {
          'ok': true,
          'categories': categories,
          'json': json,
        };
      } else {
        return {
          'ok': false,
          'error': json['detail'] ?? 'Failed to load categories',
          'json': json,
        };
      }
    } catch (e) {
      return {
        'ok': false,
        'error': 'Network error: ${e.toString()}',
        'json': {},
      };
    }
  }

  /// Get all Nouakchott areas
  Future<Map<String, dynamic>> getNouakchottAreas({
    String? areaType, // 'district' or 'neighborhood'
    bool simple = true, // Use simple API for dropdowns
  }) async {
    try {
      String url = '$_baseUrl/services/areas/';
      if (simple) {
        url += 'simple/';
      }

      List<String> queryParams = [];
      if (areaType != null) {
        queryParams.add('type=$areaType');
      }

      if (queryParams.isNotEmpty) {
        url += '?${queryParams.join('&')}';
      }

      final response = await _client.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      final json = _parseResponse(response);

      if (response.statusCode == 200) {
        final List<dynamic> data = (json is List) ? json : [];
        final areas = data
            .map(
                (item) => NouakchottArea.fromJson(item as Map<String, dynamic>))
            .toList();

        return {
          'ok': true,
          'areas': areas,
          'json': json,
        };
      } else {
        return {
          'ok': false,
          'error': json['detail'] ?? 'Failed to load areas',
          'json': json,
        };
      }
    } catch (e) {
      return {
        'ok': false,
        'error': 'Network error: ${e.toString()}',
        'json': {},
      };
    }
  }

  /// Get combined data (categories + areas) in one call
  Future<Map<String, dynamic>> getCombinedData() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/services/all-data/'),
        headers: {'Content-Type': 'application/json'},
      );

      final json = _parseResponse(response);

      if (response.statusCode == 200) {
        final categoriesData =
            (json['categories'] is List) ? json['categories'] as List : [];
        final areasData = (json['areas'] is List) ? json['areas'] as List : [];

        final categories = categoriesData
            .map<ServiceCategory>((item) =>
                ServiceCategory.fromJson(item as Map<String, dynamic>))
            .toList();
        final areas = areasData
            .map<NouakchottArea>(
                (item) => NouakchottArea.fromJson(item as Map<String, dynamic>))
            .toList();

        return {
          'ok': true,
          'categories': categories,
          'areas': areas,
          'json': json,
        };
      } else {
        return {
          'ok': false,
          'error': json['detail'] ?? 'Failed to load data',
          'json': json,
        };
      }
    } catch (e) {
      return {
        'ok': false,
        'error': 'Network error: ${e.toString()}',
        'json': {},
      };
    }
  }

  /// Get specific service category by ID
  Future<Map<String, dynamic>> getServiceCategory(int id) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/services/categories/$id/'),
        headers: {'Content-Type': 'application/json'},
      );

      final json = _parseResponse(response);

      if (response.statusCode == 200) {
        final category = ServiceCategory.fromJson(json);

        return {
          'ok': true,
          'category': category,
          'json': json,
        };
      } else {
        return {
          'ok': false,
          'error': json['detail'] ?? 'Category not found',
          'json': json,
        };
      }
    } catch (e) {
      return {
        'ok': false,
        'error': 'Network error: ${e.toString()}',
        'json': {},
      };
    }
  }

  /// Get specific area by ID
  Future<Map<String, dynamic>> getNouakchottArea(int id) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/services/areas/$id/'),
        headers: {'Content-Type': 'application/json'},
      );

      final json = _parseResponse(response);

      if (response.statusCode == 200) {
        final area = NouakchottArea.fromJson(json);

        return {
          'ok': true,
          'area': area,
          'json': json,
        };
      } else {
        return {
          'ok': false,
          'error': json['detail'] ?? 'Area not found',
          'json': json,
        };
      }
    } catch (e) {
      return {
        'ok': false,
        'error': 'Network error: ${e.toString()}',
        'json': {},
      };
    }
  }

  /// Helper method to parse response body
  dynamic _parseResponse(http.Response response) {
    try {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body);
    } catch (e) {
      return {'detail': 'Invalid response format'};
    }
  }

  /// Dispose method for cleanup
  void dispose() {
    _client.close();
  }
}

/// Singleton instance
final CategoryService categoryService = CategoryService();
