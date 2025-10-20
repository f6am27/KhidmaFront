// lib/services/worker_search_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';
import '../models/worker_search_model.dart';
import 'auth_manager.dart'; // ✅ أضف import

class WorkerSearchService {
  final String _baseUrl = ApiConfig.baseUrl().replaceAll('/users', '/workers');
  final http.Client _client = http.Client();

  /// البحث عن العمال مع الفلترة
  Future<Map<String, dynamic>> searchWorkers({
    String? category,
    String? area,
    String? search,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? sortBy,
    bool? onlineOnly,
    double? clientLat,
    double? clientLng,
    int? limit,
  }) async {
    try {
      String url = '$_baseUrl/';
      List<String> params = [];

      if (category != null &&
          category.isNotEmpty &&
          category != 'Toutes Catégories') {
        params.add('category=${Uri.encodeComponent(category)}');
      }

      if (area != null && area.isNotEmpty && area != 'Toutes Zones') {
        params.add('area=${Uri.encodeComponent(area)}');
      }

      if (search != null && search.isNotEmpty) {
        params.add('search=${Uri.encodeComponent(search)}');
      }

      if (minPrice != null) {
        params.add('min_price=$minPrice');
      }

      if (maxPrice != null) {
        params.add('max_price=$maxPrice');
      }

      if (minRating != null) {
        params.add('min_rating=$minRating');
      }

      if (sortBy != null && sortBy.isNotEmpty) {
        params.add('sort_by=$sortBy');
      }

      if (onlineOnly == true) {
        params.add('online_only=true');
      }

      if (clientLat != null && clientLng != null) {
        params.add('lat=$clientLat');
        params.add('lng=$clientLng');
      }

      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      print('📍 Fetching workers: $url');

      // ✅ احصل على التوكن الصحيح
      String? token = await AuthManager.getValidAccessToken();

      // ✅ أضف التوكن إلى الـ headers
      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        print('✅ Token added to request');
      } else {
        print('⚠️ No token found - request will be anonymous');
      }

      final response = await _client.get(
        Uri.parse(url),
        headers: headers,
      );

      print('Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        List<dynamic> workersData = [];

        if (json is List) {
          workersData = json;
        } else if (json is Map && json['results'] != null) {
          workersData = json['results'];
        }

        List<WorkerSearchResult> workers = workersData
            .map((item) {
              try {
                return WorkerSearchResult.fromJson(
                    item as Map<String, dynamic>);
              } catch (e) {
                print('Worker parse error: $e');
                return null;
              }
            })
            .whereType<WorkerSearchResult>()
            .toList();

        if (limit != null && workers.length > limit) {
          workers = workers.sublist(0, limit);
        }

        print('✅ Loaded ${workers.length} workers');

        return {
          'ok': true,
          'workers': workers,
          'count': workers.length,
        };
      } else {
        print('⚠️ Failed: ${response.statusCode}');
        return {
          'ok': false,
          'error': 'Failed to load workers',
        };
      }
    } catch (e) {
      print('❌ Error: $e');
      return {
        'ok': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> getTopWorkers({int limit = 10}) async {
    return await searchWorkers(
      sortBy: 'rating',
      limit: limit,
    );
  }

  Future<Map<String, dynamic>> getSearchFilters() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/search/filters/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return {
          'ok': true,
          'categories': json['categories'] ?? [],
          'nouakchottAreas': json['nouakchottAreas'] ?? [],
          'allServices': json['allServices'] ?? [],
          'priceRange': json['price_range'] ?? {},
          'sortOptions': json['sort_options'] ?? [],
        };
      } else {
        return {
          'ok': false,
          'error': 'Failed to load filters',
        };
      }
    } catch (e) {
      print('❌ Error loading filters: $e');
      return {
        'ok': false,
        'error': 'Network error',
      };
    }
  }

  Future<Map<String, dynamic>> getWorkerStats() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/stats/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return {
          'ok': true,
          'stats': json,
        };
      } else {
        return {
          'ok': false,
          'error': 'Failed to load stats',
        };
      }
    } catch (e) {
      return {
        'ok': false,
        'error': 'Network error',
      };
    }
  }

  void dispose() {
    _client.close();
  }
}

final WorkerSearchService workerSearchService = WorkerSearchService();
