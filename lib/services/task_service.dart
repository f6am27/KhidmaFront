// lib/services/task_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../models/task_model.dart';
import '../models/task_application_model.dart';
import '../models/task_counter_model.dart';
import 'auth_manager.dart';
import 'service_category_mapper.dart';
import '../models/review_model.dart';

class TaskService {
  final String _baseUrl = ApiConfig.baseUrl().replaceAll('/users', '');

  // ==================== CLIENT ENDPOINTS ====================

  /// Create new task (للعميل)
  Future<Map<String, dynamic>> createTask({
    required String title,
    required String description,
    required String serviceType,
    required int budget,
    required String location,
    required String preferredTime,
    bool isUrgent = false,
    double? latitude,
    double? longitude,
    String? timeDescription,
  }) async {
    try {
      final body = {
        'title': title,
        'description': description,
        'budget': budget,
        'location': location,
        'preferred_time': preferredTime,
        'is_urgent': isUrgent,
      };

      // ✅ السماح بـ serviceType فارغ
      if (serviceType.isNotEmpty) {
        final categoryId = ServiceCategoryMapper.getCategoryId(serviceType);
        if (categoryId != null) {
          body['service_category_id'] = categoryId;
        }
      }
      // إذا serviceType فارغ، لا نضيف service_category_id أصلاً

      // Add coordinates if available
      if (latitude != null && longitude != null) {
        body['latitude'] = latitude;
        body['longitude'] = longitude;
      }

      if (timeDescription != null) {
        body['time_description'] = timeDescription;
      }

      print('Creating task with data: $body');

      final response = await AuthManager.authenticatedRequest(
        method: 'POST',
        endpoint: '$_baseUrl/tasks/create/',
        body: body,
      );

      print('Create task response: ${response.statusCode}');
      print('Response body: ${response.body}');

      final json = _parseResponse(response);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final task = TaskModel.fromJson(json);
        return {
          'ok': true,
          'task': task,
          'message': 'Tâche créée avec succès',
          'json': json,
        };
      } else {
        return {
          'ok': false,
          'error': json['detail'] ?? json['error'] ?? 'Échec de création',
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

  /// Get my tasks (للعميل)
  Future<Map<String, dynamic>> getMyTasks({String? status}) async {
    try {
      String endpoint = '$_baseUrl/tasks/my-tasks/';
      if (status != null && status.isNotEmpty) {
        endpoint += '?status=$status';
      }

      final response = await AuthManager.authenticatedRequest(
        method: 'GET',
        endpoint: endpoint,
      );

      print('════════ GET MY TASKS ════════');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('═══════════════════════════════');

      final json = _parseResponse(response);

      print('Parsed JSON type: ${json.runtimeType}');

      if (response.statusCode == 200) {
        List<dynamic> tasksData = [];

        // Try different response formats
        if (json is List) {
          print('✅ Response is a List');
          tasksData = json;
        } else if (json is Map) {
          print('Response is a Map');
          if (json['results'] != null) {
            tasksData = json['results'] as List;
          } else if (json['data'] != null) {
            tasksData = json['data'] as List;
          } else if (json['tasks'] != null) {
            tasksData = json['tasks'] as List;
          }
        }

        print('Tasks data length: ${tasksData.length}');

        final tasks = <TaskModel>[];
        for (var i = 0; i < tasksData.length; i++) {
          try {
            print('════════ TASK $i ════════');
            print('Task data type: ${tasksData[i].runtimeType}');

            // Ensure element is Map
            if (tasksData[i] is! Map) {
              print(
                  '❌ Task $i is NOT a Map! Type: ${tasksData[i].runtimeType}');
              print('Data: ${tasksData[i]}');
              continue;
            }

            final taskJson = Map<String, dynamic>.from(tasksData[i]);
            print('✅ Task ${taskJson['id']} - ${taskJson['title']}');

            tasks.add(TaskModel.fromJson(taskJson));
            print('✅ Parsed successfully');
          } catch (e, stackTrace) {
            print('❌ Error parsing task $i: $e');
            print('StackTrace: $stackTrace');
          }
          print('═════════════════════════');
        }

        print('✅ Total tasks parsed: ${tasks.length}');

        return {
          'ok': true,
          'tasks': tasks,
          'count': tasks.length,
          'json': json,
        };
      } else {
        return {
          'ok': false,
          'error': json['detail'] ?? 'Échec de chargement',
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
    } catch (e, stackTrace) {
      print('════════ EXCEPTION ════════');
      print('Error: $e');
      print('StackTrace: $stackTrace');
      print('═══════════════════════════');
      return {
        'ok': false,
        'error': 'Erreur réseau: ${e.toString()}',
        'json': {},
      };
    }
  }

  /// Get task details
  Future<Map<String, dynamic>> getTaskDetails(String taskId) async {
    try {
      final response = await AuthManager.authenticatedRequest(
        method: 'GET',
        endpoint: '$_baseUrl/tasks/$taskId/',
      );

      final json = _parseResponse(response);

      if (response.statusCode == 200) {
        final task = TaskModel.fromJson(json);
        return {
          'ok': true,
          'task': task,
          'json': json,
        };
      } else {
        return {
          'ok': false,
          'error': json['detail'] ?? 'Tâche non trouvée',
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

  /// Update task (للعميل)
  Future<Map<String, dynamic>> updateTask({
    required String taskId,
    String? title,
    String? description,
    String? serviceType,
    int? budget,
    String? location,
    String? preferredTime,
    bool? isUrgent,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final body = <String, dynamic>{};

      if (title != null) body['title'] = title;
      if (description != null) body['description'] = description;

      // ✅ معالجة التصنيف - يسمح بـ null
      if (serviceType != null) {
        if (serviceType.isEmpty) {
          // ✅ إذا فارغ، أرسل null
          body['service_category_id'] = null;
        } else {
          // ✅ إذا موجود، ابحث عن ID
          final categoryId = ServiceCategoryMapper.getCategoryId(serviceType);
          if (categoryId != null) {
            body['service_category_id'] = categoryId;
          } else {
            // ✅ إذا لم يُعثر على ID، أرسل null
            body['service_category_id'] = null;
          }
        }
      }

      if (budget != null) body['budget'] = budget;
      if (location != null) body['location'] = location;
      if (preferredTime != null) body['preferredTime'] = preferredTime;
      if (isUrgent != null) body['is_urgent'] = isUrgent;
      if (latitude != null) body['latitude'] = latitude;
      if (longitude != null) body['longitude'] = longitude;

      final response = await AuthManager.authenticatedRequest(
        method: 'PUT',
        endpoint: '$_baseUrl/tasks/$taskId/update/',
        body: body,
      );

      final json = _parseResponse(response);

      if (response.statusCode == 200) {
        final task = TaskModel.fromJson(json);
        return {
          'ok': true,
          'task': task,
          'message': 'Tâche mise à jour',
          'json': json,
        };
      } else {
        return {
          'ok': false,
          'error': json['detail'] ?? 'Échec de mise à jour',
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

  /// Cancel task (للعميل)
  Future<Map<String, dynamic>> cancelTask({
    required String taskId,
  }) async {
    try {
      final response = await AuthManager.authenticatedRequest(
        method: 'PUT',
        endpoint: '$_baseUrl/tasks/$taskId/status/',
        body: {'status': 'cancelled'},
      );

      final json = _parseResponse(response);

      if (response.statusCode == 200) {
        return {
          'ok': true,
          'message': json['message'] ?? 'Tâche annulée avec succès',
          'json': json,
        };
      } else {
        return {
          'ok': false,
          'error': json['detail'] ?? json['error'] ?? 'Échec d\'annulation',
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

  /// Get task candidates/applications (للعميل)
  Future<Map<String, dynamic>> getTaskCandidates(String taskId) async {
    try {
      final response = await AuthManager.authenticatedRequest(
        method: 'GET',
        endpoint: '$_baseUrl/tasks/$taskId/candidates/',
      );

      final json = _parseResponse(response);

      if (response.statusCode == 200) {
        List<dynamic> candidatesData;
        if (json is List) {
          candidatesData = json;
        } else if (json['results'] != null) {
          candidatesData = json['results'];
        } else {
          candidatesData = [];
        }

        final candidates = candidatesData
            .map((item) =>
                TaskApplicationModel.fromJson(item as Map<String, dynamic>))
            .toList();

        return {
          'ok': true,
          'candidates': candidates,
          'count': candidates.length,
          'json': json,
        };
      } else {
        return {
          'ok': false,
          'error': json['detail'] ?? 'Échec de chargement',
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

  /// Accept worker for task (للعميل)
  ///
  /// Backend: POST /api/tasks/{id}/accept_worker/
  ///
  /// On success:
  /// {
  ///   'ok': true,
  ///   'message': ...,
  ///   'taskStatus': String,
  ///   'assignedWorker': dynamic,
  ///   'clientCounter': TaskCounterModel?,
  ///   'workerCounter': TaskCounterModel?,
  ///   'json': rawJson,
  /// }
  ///
  /// On 403 with soft-lock:
  /// {
  ///   'ok': false,
  ///   'subscriptionRequired': true,
  ///   'errorType': 'client_limit_reached' | ...,
  ///   'message': ...,
  ///   'json': rawJson,
  /// }
  Future<Map<String, dynamic>> acceptWorker({
    required String taskId,
    required String workerId,
  }) async {
    try {
      final response = await AuthManager.authenticatedRequest(
        method: 'POST',
        endpoint: '$_baseUrl/tasks/$taskId/accept/',
        body: {'worker_id': workerId},
      );

      final dynamic json = _parseResponse(response);

      if (response.statusCode == 200) {
        TaskCounterModel? clientCounter;
        TaskCounterModel? workerCounter;

        if (json is Map<String, dynamic>) {
          final taskCounter = json['task_counter'];
          if (taskCounter is Map<String, dynamic>) {
            final clientJson = taskCounter['client'];
            final workerJson = taskCounter['worker'];

            if (clientJson is Map<String, dynamic>) {
              clientCounter = TaskCounterModel.fromJson(clientJson);
            }
            if (workerJson is Map<String, dynamic>) {
              workerCounter = TaskCounterModel.fromJson(workerJson);
            }
          }
        }

        return {
          'ok': true,
          'message':
              (json is Map ? json['message'] : null) ?? 'Candidat accepté',
          'taskStatus': json is Map ? json['task_status'] : null,
          'assignedWorker': json is Map ? json['assigned_worker'] : null,
          'clientCounter': clientCounter,
          'workerCounter': workerCounter,
          'json': json,
        };
      }

      // Handle soft-lock / subscription_required
      if (response.statusCode == 403 && json is Map<String, dynamic>) {
        final error = json['error']?.toString();
        final errorType = json['error_type']?.toString();
        final subscriptionRequired = error == 'subscription_required' ||
            (errorType != null && errorType.contains('limit_reached'));

        if (subscriptionRequired) {
          return {
            'ok': false,
            'subscriptionRequired': true,
            'errorType': errorType,
            'message': json['message']?.toString() ??
                json['detail']?.toString() ??
                'Abonnement requis',
            'json': json,
          };
        }
      }

      final errorMessage = (json is Map<String, dynamic>)
          ? (json['detail'] ??
                  json['error'] ??
                  json['message'] ??
                  'Échec d\'acceptation')
              .toString()
          : 'Échec d\'acceptation';

      return {
        'ok': false,
        'error': errorMessage,
        'json': json,
      };
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

  // ==================== WORKER ENDPOINTS ====================

  /// Get available tasks for workers
  Future<Map<String, dynamic>> getAvailableTasks({
    String? category,
    String? location,
    int? budgetMin,
    int? budgetMax,
    String?
        sortBy, // 'latest', 'budget_high', 'budget_low', 'urgent', 'nearest'
    double? lat, // worker latitude
    double? lng, // worker longitude
    int? limit,
  }) async {
    try {
      String endpoint = '$_baseUrl/tasks/available/';
      List<String> queryParams = [];

      if (category != null) queryParams.add('category=$category');
      if (location != null) queryParams.add('location=$location');
      if (budgetMin != null) queryParams.add('budget_min=$budgetMin');
      if (budgetMax != null) queryParams.add('budget_max=$budgetMax');
      if (sortBy != null) queryParams.add('sort_by=$sortBy');

      if (lat != null) queryParams.add('lat=$lat');
      if (lng != null) queryParams.add('lng=$lng');
      if (limit != null) queryParams.add('limit=$limit');

      if (queryParams.isNotEmpty) {
        endpoint += '?${queryParams.join('&')}';
      }

      print('📍 Requesting tasks with location: lat=$lat, lng=$lng');
      print('🔗 Endpoint: $endpoint');

      final response = await AuthManager.authenticatedRequest(
        method: 'GET',
        endpoint: endpoint,
      );

      final json = _parseResponse(response);

      if (response.statusCode == 200) {
        List<dynamic> tasksData;
        if (json is List) {
          tasksData = json;
        } else if (json['results'] != null) {
          tasksData = json['results'];
        } else {
          tasksData = [];
        }

        final tasks = tasksData
            .map((item) => TaskModel.fromJson(item as Map<String, dynamic>))
            .toList();

        print('✅ Received ${tasks.length} tasks');
        if (tasks.isNotEmpty && tasks[0].distance != null) {
          print('✅ Distance calculated: ${tasks[0].distance} km');
        }

        return {
          'ok': true,
          'tasks': tasks,
          'count': json['count'] ?? tasks.length,
          'json': json,
        };
      } else {
        return {
          'ok': false,
          'error': json['detail'] ?? 'Échec de chargement',
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
      print('❌ Error in getAvailableTasks: $e');
      return {
        'ok': false,
        'error': 'Erreur réseau: ${e.toString()}',
        'json': {},
      };
    }
  }

  /// Apply to task (للعامل)
  ///
  /// On success: same as before.
  ///
  /// On 403 with worker soft-lock:
  /// {
  ///   'ok': false,
  ///   'subscriptionRequired': true,
  ///   'errorType': 'worker_limit_reached' | ...,
  ///   'message': ...,
  ///   'json': rawJson,
  /// }
  Future<Map<String, dynamic>> applyToTask({
    required String taskId,
    String? message,
  }) async {
    try {
      // Safe conversion from String to int
      final taskIdInt = int.tryParse(taskId);

      if (taskIdInt == null) {
        return {
          'ok': false,
          'error': 'ID de tâche invalide',
          'json': {},
        };
      }

      final body = <String, dynamic>{};

      if (message != null && message.isNotEmpty) {
        body['application_message'] = message;
      }

      print('🔍 Sending to: $_baseUrl/tasks/$taskIdInt/apply/');
      print('🔍 Body: $body');

      final response = await AuthManager.authenticatedRequest(
        method: 'POST',
        endpoint: '$_baseUrl/tasks/$taskIdInt/apply/',
        body: body,
      );

      print('🔍 Response Status: ${response.statusCode}');
      print('🔍 Response Body: ${response.body}');

      dynamic json;

      try {
        json = _parseResponse(response);
        print('🔍 Parsed JSON: $json');
      } catch (parseError) {
        print('❌ Parse Error: $parseError');

        return {
          'ok': false,
          'error': 'Erreur de parsing: ${response.body}',
          'json': {},
        };
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'ok': true,
          'message': 'Candidature envoyée',
          'json': json is Map ? json : {},
        };
      } else {
        // Handle soft-lock / subscription_required for workers
        if (response.statusCode == 403 && json is Map<String, dynamic>) {
          final error = json['error']?.toString();
          final errorType = json['error_type']?.toString();
          final subscriptionRequired = error == 'subscription_required' ||
              (errorType != null && errorType.contains('limit_reached'));

          if (subscriptionRequired) {
            return {
              'ok': false,
              'subscriptionRequired': true,
              'errorType': errorType,
              'message': json['message']?.toString() ??
                  json['detail']?.toString() ??
                  'Limite atteinte, abonnement requis',
              'json': json,
            };
          }
        }

        // Generic error handling
        String errorMessage = 'Échec de candidature';

        if (json is Map<String, dynamic>) {
          errorMessage = json['detail']?.toString() ??
              json['error']?.toString() ??
              json['message']?.toString() ??
              'Échec de candidature';
        } else if (json is List) {
          errorMessage =
              json.isNotEmpty ? json[0].toString() : 'Échec de candidature';
        } else if (json is String) {
          errorMessage = json;
        }

        print('❌ Backend Error: $errorMessage');

        return {
          'ok': false,
          'error': errorMessage,
          'json': json is Map ? json : {},
        };
      }
    } on AuthException catch (e) {
      print('❌ Auth Exception: ${e.message}');

      return {
        'ok': false,
        'error': e.needsLogin ? 'Veuillez vous reconnecter' : e.message,
        'needsLogin': e.needsLogin,
        'json': {},
      };
    } catch (e, stackTrace) {
      print('❌ Unexpected Error: $e');
      print('❌ StackTrace: $stackTrace');

      return {
        'ok': false,
        'error': 'Erreur: ${e.toString()}',
        'json': {},
      };
    }
  }

  // ==================== COMMON ENDPOINTS ====================

  /// Get task statistics
  Future<Map<String, dynamic>> getTaskStats() async {
    try {
      final response = await AuthManager.authenticatedRequest(
        method: 'GET',
        endpoint: '$_baseUrl/tasks/stats/',
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
          'error': json['detail'] ?? 'Échec de chargement',
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

  // ==================== REVIEWS ENDPOINTS ====================

  /// Submit task review (للعميل)
  Future<Map<String, dynamic>> submitTaskReview({
    required String taskId,
    required int rating,
    String? reviewText,
  }) async {
    try {
      // Convert taskId to int
      final taskIdInt = int.tryParse(taskId);
      if (taskIdInt == null) {
        return {
          'ok': false,
          'error': 'ID de tâche invalide',
          'json': {},
        };
      }

      final body = <String, dynamic>{
        'rating': rating,
      };

      if (reviewText != null && reviewText.isNotEmpty) {
        body['review_text'] = reviewText;
      }

      print('🔍 Review endpoint: $_baseUrl/tasks/$taskIdInt/review/');
      print('🔍 Review body: $body');

      final response = await AuthManager.authenticatedRequest(
        method: 'POST',
        endpoint: '$_baseUrl/tasks/$taskIdInt/review/',
        body: body,
      );

      print('🔍 Review response: ${response.statusCode}');
      print('🔍 Review body: ${response.body}');
      final json = _parseResponse(response);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'ok': true,
          'message': 'Évaluation envoyée',
          'json': json is Map ? json : {},
        };
      } else {
        // Safe error handling
        String errorMessage = 'Échec d\'envoi';

        if (json is List && json.isNotEmpty) {
          errorMessage = json[0].toString();
        } else if (json is Map) {
          errorMessage = json['detail']?.toString() ??
              json['error']?.toString() ??
              'Échec d\'envoi';
        } else if (json is String) {
          errorMessage = json;
        }

        return {
          'ok': false,
          'error': errorMessage,
          'json': json is Map ? json : {},
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
      print('❌ Review error: $e');
      return {
        'ok': false,
        'error': 'Erreur: ${e.toString()}',
        'json': {},
      };
    }
  }

  /// Get my reviews (للعامل)
  Future<Map<String, dynamic>> getMyReviews({
    int? rating,
    String? search,
    String? ordering,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      String endpoint = '$_baseUrl/tasks/my-reviews/';
      List<String> queryParams = [];

      if (rating != null) queryParams.add('rating=$rating');
      if (search != null && search.isNotEmpty) {
        queryParams.add('search=$search');
      }
      if (ordering != null) queryParams.add('ordering=$ordering');
      queryParams.add('limit=$limit');
      queryParams.add('offset=$offset');

      endpoint += '?${queryParams.join('&')}';

      print('📍 Fetching reviews: $endpoint');

      final response = await AuthManager.authenticatedRequest(
        method: 'GET',
        endpoint: endpoint,
      );

      print('Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = _parseResponse(response);
        final reviewsResponse = ReviewsResponseModel.fromJson(json);

        print('✅ Loaded ${reviewsResponse.reviews.length} reviews');

        return {
          'ok': true,
          'response': reviewsResponse,
          'reviews': reviewsResponse.reviews,
          'statistics': reviewsResponse.statistics,
          'count': reviewsResponse.count,
          'json': json,
        };
      } else {
        final json = _parseResponse(response);
        return {
          'ok': false,
          'error': json['detail'] ?? 'Échec de chargement',
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
      print('❌ Error in getMyReviews: $e');
      return {
        'ok': false,
        'error': 'Erreur réseau: ${e.toString()}',
        'json': {},
      };
    }
  }

  /// Get review statistics (للعامل)
  Future<Map<String, dynamic>> getReviewStats() async {
    try {
      final response = await AuthManager.authenticatedRequest(
        method: 'GET',
        endpoint: '$_baseUrl/tasks/review-stats/',
      );

      print('Review stats status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = _parseResponse(response);
        final stats = ReviewStatisticsModel.fromJson(json);

        print('✅ Stats loaded: ${stats.averageRating} / ${stats.totalReviews}');

        return {
          'ok': true,
          'statistics': stats,
          'json': json,
        };
      } else {
        final json = _parseResponse(response);
        return {
          'ok': false,
          'error': json['detail'] ?? 'Échec de chargement',
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
      print('❌ Error in getReviewStats: $e');
      return {
        'ok': false,
        'error': 'Erreur réseau: ${e.toString()}',
        'json': {},
      };
    }
  }

  // ==================== HELPER METHODS ====================

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
    // No client to dispose since we're using AuthManager
  }
}

/// Singleton instance
final TaskService taskService = TaskService();
