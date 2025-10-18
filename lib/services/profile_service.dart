// lib/services/profile_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';
import '../models/user_model.dart';
import '../models/worker_profile_model.dart';
import 'auth_manager.dart';
import '../models/client_profile_model.dart';

class ProfileService {
  final String _baseUrl = ApiConfig.baseUrl();
  // ✅ إضافة متغير جديد للـ API بدون /users
  final String _apiBase = ApiConfig.baseUrl().replaceAll('/users', '');

  /// Complete worker onboarding with full profile data
  Future<Map<String, dynamic>> completeWorkerOnboarding({
    required String firstName,
    required String lastName,
    required String bio,
    required String serviceArea,
    required String serviceCategory,
    required double basePrice,
    required List<String> availableDays,
    required String workStartTime,
    required String workEndTime,
  }) async {
    try {
      final body = {
        'first_name': firstName,
        'last_name': lastName,
        'bio': bio,
        'service_area': serviceArea,
        'service_category': serviceCategory,
        'base_price': basePrice,
        'available_days': availableDays,
        'work_start_time': workStartTime,
        'work_end_time': workEndTime,
      };

      print('Sending worker onboarding data: $body');

      final response = await AuthManager.authenticatedRequest(
        method: 'POST',
        endpoint: '$_baseUrl/worker-onboarding/',
        body: body,
      );

      print('Worker onboarding response: ${response.statusCode}');
      print('Response body: ${response.body}');

      final json = _parseResponse(response);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'ok': true,
          'message': 'Worker profile created successfully',
          'json': json,
        };
      } else {
        return {
          'ok': false,
          'error': json['detail'] ??
              json['error'] ??
              'Failed to create worker profile',
          'json': json,
        };
      }
    } on AuthException catch (e) {
      return {
        'ok': false,
        'error': e.needsLogin ? 'Please login again' : e.message,
        'needsLogin': e.needsLogin,
        'json': {},
      };
    } catch (e) {
      return {
        'ok': false,
        'error': 'Network error: ${e.toString()}',
        'json': {},
      };
    }
  }

  /// Get current user profile
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await AuthManager.authenticatedRequest(
        method: 'GET',
        endpoint: '$_baseUrl/profile/',
      );

      final json = _parseResponse(response);

      if (response.statusCode == 200) {
        final user = User.fromJson(json);

        return {
          'ok': true,
          'user': user,
          'json': json,
        };
      } else {
        return {
          'ok': false,
          'error': json['detail'] ?? 'Failed to load profile',
          'json': json,
        };
      }
    } on AuthException catch (e) {
      return {
        'ok': false,
        'error': e.needsLogin ? 'Please login again' : e.message,
        'needsLogin': e.needsLogin,
        'json': {},
      };
    } catch (e) {
      return {
        'ok': false,
        'error': 'Network error: ${e.toString()}',
        'json': {},
      };
    }
  }

  /// Get worker profile
  Future<Map<String, dynamic>> getWorkerProfile() async {
    try {
      final response = await AuthManager.authenticatedRequest(
        method: 'GET',
        endpoint: '$_baseUrl/worker-profile/',
      );

      final json = _parseResponse(response);

      if (response.statusCode == 200) {
        final workerProfile = WorkerProfile.fromJson(json);

        return {
          'ok': true,
          'workerProfile': workerProfile,
          'json': json,
        };
      } else {
        return {
          'ok': false,
          'error': json['detail'] ?? 'Failed to load worker profile',
          'json': json,
        };
      }
    } on AuthException catch (e) {
      return {
        'ok': false,
        'error': e.needsLogin ? 'Please login again' : e.message,
        'needsLogin': e.needsLogin,
        'json': {},
      };
    } catch (e) {
      return {
        'ok': false,
        'error': 'Network error: ${e.toString()}',
        'json': {},
      };
    }
  }

  /// Update worker profile
  Future<Map<String, dynamic>> updateWorkerProfile({
    String? firstName,
    String? lastName,
    String? bio,
    String? serviceArea,
    String? serviceCategory,
    double? basePrice,
    List<String>? availableDays,
    String? workStartTime,
    String? workEndTime,
    bool? isAvailable,
  }) async {
    try {
      final body = <String, dynamic>{};

      if (firstName != null) body['first_name'] = firstName;
      if (lastName != null) body['last_name'] = lastName;
      if (bio != null) body['bio'] = bio;
      if (serviceArea != null) body['service_area'] = serviceArea;
      if (serviceCategory != null) body['service_category'] = serviceCategory;
      if (basePrice != null) body['base_price'] = basePrice;
      if (availableDays != null) body['available_days'] = availableDays;
      if (workStartTime != null) body['work_start_time'] = workStartTime;
      if (workEndTime != null) body['work_end_time'] = workEndTime;
      if (isAvailable != null) body['is_available'] = isAvailable;

      final response = await AuthManager.authenticatedRequest(
        method: 'PUT',
        endpoint: '$_baseUrl/worker-profile/',
        body: body,
      );

      final json = _parseResponse(response);

      if (response.statusCode == 200) {
        return {
          'ok': true,
          'message': json['message'] ?? 'Profile updated successfully',
          'json': json,
        };
      } else {
        return {
          'ok': false,
          'error': json['detail'] ?? 'Failed to update profile',
          'json': json,
        };
      }
    } on AuthException catch (e) {
      return {
        'ok': false,
        'error': e.needsLogin ? 'Please login again' : e.message,
        'needsLogin': e.needsLogin,
        'json': {},
      };
    } catch (e) {
      return {
        'ok': false,
        'error': 'Network error: ${e.toString()}',
        'json': {},
      };
    }
  }

  /// Upload profile image
  Future<Map<String, dynamic>> uploadProfileImage(File imageFile) async {
    try {
      final response = await AuthManager.authenticatedMultipartRequest(
        endpoint: '$_baseUrl/upload-profile-image/',
        fileFieldName: 'image',
        filePath: imageFile.path,
      );

      final json = _parseResponse(response);

      if (response.statusCode == 200) {
        return {
          'ok': true,
          'imageUrl': json['data']?['image_url'],
          'message': json['message'] ?? 'Image uploaded successfully',
          'json': json,
        };
      } else {
        return {
          'ok': false,
          'error': json['error'] ?? 'Failed to upload image',
          'json': json,
        };
      }
    } on AuthException catch (e) {
      return {
        'ok': false,
        'error': e.needsLogin ? 'Please login again' : e.message,
        'needsLogin': e.needsLogin,
        'json': {},
      };
    } catch (e) {
      return {
        'ok': false,
        'error': 'Network error: ${e.toString()}',
        'json': {},
      };
    }
  }

  /// Delete profile image
  Future<Map<String, dynamic>> deleteProfileImage() async {
    try {
      final response = await AuthManager.authenticatedRequest(
        method: 'DELETE',
        endpoint: '$_baseUrl/delete-profile-image/',
      );

      final json = _parseResponse(response);

      if (response.statusCode == 200) {
        return {
          'ok': true,
          'message': json['message'] ?? 'Image deleted successfully',
          'json': json,
        };
      } else {
        return {
          'ok': false,
          'error': json['error'] ?? 'Failed to delete image',
          'json': json,
        };
      }
    } on AuthException catch (e) {
      return {
        'ok': false,
        'error': e.needsLogin ? 'Please login again' : e.message,
        'needsLogin': e.needsLogin,
        'json': {},
      };
    } catch (e) {
      return {
        'ok': false,
        'error': 'Network error: ${e.toString()}',
        'json': {},
      };
    }
  }

  /// Get current profile image URL
  Future<Map<String, dynamic>> getProfileImage() async {
    try {
      final response = await AuthManager.authenticatedRequest(
        method: 'GET',
        endpoint: '$_baseUrl/profile-image/',
      );

      final json = _parseResponse(response);

      if (response.statusCode == 200) {
        return {
          'ok': true,
          'imageUrl': json['data']?['image_url'],
          'hasImage': json['data']?['has_image'] ?? false,
          'json': json,
        };
      } else {
        return {
          'ok': false,
          'error': json['error'] ?? 'Failed to get image info',
          'json': json,
        };
      }
    } on AuthException catch (e) {
      return {
        'ok': false,
        'error': e.needsLogin ? 'Please login again' : e.message,
        'needsLogin': e.needsLogin,
        'json': {},
      };
    } catch (e) {
      return {
        'ok': false,
        'error': 'Network error: ${e.toString()}',
        'json': {},
      };
    }
  }

  /// Get client profile
  Future<Map<String, dynamic>> getClientProfile() async {
    try {
      print('📍 Requesting client profile...');
      print('🔗 Full URL: $_apiBase/clients/profile/');

      final response = await AuthManager.authenticatedRequest(
        method: 'GET',
        // ✅ التعديل 1 - استخدام _apiBase بدل _baseUrl
        endpoint: '$_apiBase/clients/profile/',
      );

      print('✅ Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      final json = _parseResponse(response);

      print('🔍 Parsed JSON Type: ${json.runtimeType}');
      print('🔍 Parsed JSON: $json');

      if (response.statusCode == 200) {
        // ✅ التحقق من البيانات
        if (json is Map && json.isNotEmpty) {
          print('✅ Valid JSON received');
          final clientProfile = ClientProfile.fromJson(json);

          print('✅ ClientProfile created:');
          print('  - Full Name: ${clientProfile.fullName}');
          print('  - Tasks Published: ${clientProfile.totalTasksPublished}');
          print('  - Tasks Completed: ${clientProfile.totalTasksCompleted}');

          return {
            'ok': true,
            'clientProfile': clientProfile,
            'json': json,
          };
        } else {
          print('❌ Empty or invalid JSON');
          return {
            'ok': false,
            'error': 'البيانات المرجعة فارغة',
            'json': json,
          };
        }
      } else {
        print('❌ Error response: ${response.statusCode}');
        final errorMsg =
            json['detail'] ?? json['error'] ?? 'Failed to load client profile';
        return {
          'ok': false,
          'error': errorMsg,
          'statusCode': response.statusCode,
          'json': json,
        };
      }
    } on AuthException catch (e) {
      print('❌ AuthException: ${e.message}');
      return {
        'ok': false,
        'error': e.needsLogin ? 'Please login again' : e.message,
        'needsLogin': e.needsLogin,
        'json': {},
      };
    } catch (e, stackTrace) {
      print('❌ Exception: $e');
      print('❌ StackTrace: $stackTrace');
      return {
        'ok': false,
        'error': 'Network error: ${e.toString()}',
        'json': {},
      };
    }
  }

  /// Get client statistics
  Future<Map<String, dynamic>> getClientStats() async {
    try {
      final response = await AuthManager.authenticatedRequest(
        method: 'GET',
        // ✅ التعديل 2 - استخدام _apiBase بدل _baseUrl
        endpoint: '$_apiBase/clients/stats/',
      );

      final json = _parseResponse(response);

      if (response.statusCode == 200) {
        return {
          'ok': true,
          'stats': json,
          'json': json,
        };
      } else {
        return {
          'ok': false,
          'error': json['detail'] ?? 'Failed to load statistics',
          'json': json,
        };
      }
    } on AuthException catch (e) {
      return {
        'ok': false,
        'error': e.needsLogin ? 'Please login again' : e.message,
        'needsLogin': e.needsLogin,
        'json': {},
      };
    } catch (e) {
      return {
        'ok': false,
        'error': 'Network error: ${e.toString()}',
        'json': {},
      };
    }
  }

  /// Get client dashboard data
  Future<Map<String, dynamic>> getClientDashboard() async {
    try {
      final response = await AuthManager.authenticatedRequest(
        method: 'GET',
        // ✅ التعديل 3 - استخدام _apiBase بدل _baseUrl
        endpoint: '$_apiBase/clients/dashboard/',
      );

      final json = _parseResponse(response);

      if (response.statusCode == 200) {
        return {
          'ok': true,
          'dashboard': json,
          'json': json,
        };
      } else {
        return {
          'ok': false,
          'error': json['detail'] ?? 'Failed to load dashboard',
          'json': json,
        };
      }
    } on AuthException catch (e) {
      return {
        'ok': false,
        'error': e.needsLogin ? 'Please login again' : e.message,
        'needsLogin': e.needsLogin,
        'json': {},
      };
    } catch (e) {
      return {
        'ok': false,
        'error': 'Network error: ${e.toString()}',
        'json': {},
      };
    }
  }

  /// Update client profile
  /// Update client profile - SIMPLIFIED VERSION
  Future<Map<String, dynamic>> updateClientProfile({
    String? firstName,
    String? lastName,
    String? address,
    String? gender,
    String? emergencyContact,
    bool? notificationsEnabled,
  }) async {
    try {
      final body = <String, dynamic>{};

      // User fields
      if (firstName != null) body['first_name'] = firstName;
      if (lastName != null) body['last_name'] = lastName;

      // ClientProfile fields
      if (address != null) body['address'] = address;
      if (gender != null) body['gender'] = gender;
      if (emergencyContact != null)
        body['emergency_contact'] = emergencyContact;
      if (notificationsEnabled != null)
        body['notifications_enabled'] = notificationsEnabled;

      print('Updating client profile with: $body');

      final response = await AuthManager.authenticatedRequest(
        method: 'PUT',
        // ✅ التعديل 4 - استخدام _apiBase بدل replaceAll
        endpoint: '$_apiBase/clients/profile/',
        body: body,
      );

      final json = _parseResponse(response);

      if (response.statusCode == 200) {
        return {
          'ok': true,
          'message': 'Profil mis à jour avec succès',
          'json': json,
        };
      } else {
        return {
          'ok': false,
          'error': json['detail'] ?? json['error'] ?? 'Échec de la mise à jour',
          'json': json,
        };
      }
    } on AuthException catch (e) {
      return {
        'ok': false,
        'error': e.needsLogin ? 'Veuillez vous reconnecter' : e.message,
        'needsLogin': e.needsLogin,
        'json': {},
      };
    } catch (e) {
      return {
        'ok': false,
        'error': 'Erreur réseau: ${e.toString()}',
        'json': {},
      };
    }
  }

  /// Helper method to parse response body
  Map<String, dynamic> _parseResponse(http.Response response) {
    try {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {'detail': 'Invalid response format'};
    }
  }
}

/// Singleton instance
final ProfileService profileService = ProfileService();
