// lib/services/favorite_workers_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';
import '../models/favorite_worker_model.dart';
import 'auth_manager.dart';

class FavoriteWorkersService {
  final String _baseUrl = ApiConfig.baseUrl().replaceAll('/users', '/clients');

  /// الحصول على قائمة العمال المفضلين
  Future<Map<String, dynamic>> getFavoriteWorkers({
    String? category,
    String? search,
    String? sortBy,
  }) async {
    try {
      String endpoint = '$_baseUrl/favorites/';
      List<String> params = [];

      if (category != null && category.isNotEmpty) {
        params.add('category=$category');
      }
      if (search != null && search.isNotEmpty) {
        params.add('search=$search');
      }
      if (sortBy != null && sortBy.isNotEmpty) {
        params.add('sort_by=$sortBy');
      }

      if (params.isNotEmpty) {
        endpoint += '?${params.join('&')}';
      }

      print('📍 Fetching: $endpoint');

      final response = await AuthManager.authenticatedRequest(
        method: 'GET',
        endpoint: endpoint,
      );

      print('Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        // ✅ FIX: Handle List responses directly
        List<dynamic> workersData = [];

        try {
          final decoded = jsonDecode(response.body);

          if (decoded is List) {
            workersData = decoded;
          } else if (decoded is Map && decoded['results'] != null) {
            workersData = decoded['results'] as List;
          }
        } catch (e) {
          print('Parse error: $e');
          workersData = [];
        }

        final workers = workersData
            .map((item) {
              try {
                return FavoriteWorker.fromJson(item as Map<String, dynamic>);
              } catch (e) {
                print('Worker parse error: $e');
                return null;
              }
            })
            .whereType<FavoriteWorker>()
            .toList();

        print('Loaded ${workers.length} workers');

        return {
          'ok': true,
          'workers': workers,
          'count': workers.length,
        };
      } else {
        return {
          'ok': false,
          'error': 'Failed to load workers',
        };
      }
    } on AuthException catch (e) {
      return {
        'ok': false,
        'error': e.needsLogin ? 'Please login again' : e.message,
        'needsLogin': e.needsLogin,
      };
    } catch (e) {
      print('Error: $e');
      return {
        'ok': false,
        'error': 'Network error',
      };
    }
  }

  /// إضافة عامل للمفضلة
  Future<Map<String, dynamic>> addToFavorites({
    required int workerId,
    String? notes,
  }) async {
    try {
      final body = <String, dynamic>{
        'worker_id': workerId,
      };

      if (notes != null) {
        body['notes'] = notes;
      }

      final response = await AuthManager.authenticatedRequest(
        method: 'POST',
        endpoint: '$_baseUrl/favorites/add/',
        body: body,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'ok': true,
          'message': 'Added to favorites',
        };
      } else {
        return {
          'ok': false,
          'error': 'Failed to add to favorites',
        };
      }
    } on AuthException catch (e) {
      return {
        'ok': false,
        'error': e.message,
        'needsLogin': e.needsLogin,
      };
    } catch (e) {
      return {
        'ok': false,
        'error': 'Network error',
      };
    }
  }

  /// إزالة عامل من المفضلة
  Future<Map<String, dynamic>> removeFromFavorites(int workerId) async {
    try {
      final response = await AuthManager.authenticatedRequest(
        method: 'DELETE',
        endpoint: '$_baseUrl/favorites/$workerId/remove/',
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {
          'ok': true,
          'message': 'Removed from favorites',
        };
      } else {
        return {
          'ok': false,
          'error': 'Failed to remove',
        };
      }
    } on AuthException catch (e) {
      return {
        'ok': false,
        'error': e.message,
        'needsLogin': e.needsLogin,
      };
    } catch (e) {
      return {
        'ok': false,
        'error': 'Network error',
      };
    }
  }

  /// تبديل حالة التفضيل
  Future<Map<String, dynamic>> toggleFavorite(int workerId) async {
    try {
      final response = await AuthManager.authenticatedRequest(
        method: 'POST',
        endpoint: '$_baseUrl/favorites/$workerId/toggle/',
      );

      final json = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'ok': true,
          'is_favorite': json['is_favorite'] ?? false,
          'message': json['message'],
        };
      } else {
        return {
          'ok': false,
          'error': 'Failed to toggle',
        };
      }
    } on AuthException catch (e) {
      return {
        'ok': false,
        'error': e.message,
        'needsLogin': e.needsLogin,
      };
    } catch (e) {
      return {
        'ok': false,
        'error': 'Network error',
      };
    }
  }

  /// التحقق من حالة التفضيل
  Future<Map<String, dynamic>> checkFavoriteStatus(int workerId) async {
    try {
      final response = await AuthManager.authenticatedRequest(
        method: 'GET',
        endpoint: '$_baseUrl/favorites/$workerId/status/',
      );

      final json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'ok': true,
          'is_favorite': json['is_favorite'] ?? false,
        };
      } else {
        return {
          'ok': false,
          'error': 'Failed to check',
        };
      }
    } on AuthException catch (e) {
      return {
        'ok': false,
        'error': e.message,
      };
    } catch (e) {
      return {
        'ok': false,
        'error': 'Network error',
      };
    }
  }
}

/// Singleton instance
final FavoriteWorkersService favoriteWorkersService = FavoriteWorkersService();
