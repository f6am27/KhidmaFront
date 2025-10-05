// lib/services/task_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';
import '../models/task_model.dart';
import '../models/task_application_model.dart';
import 'auth_manager.dart';
import 'service_category_mapper.dart';

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
      // Import the mapper at the top of the file
      // import '../utils/service_category_mapper.dart';

      // Convert serviceType to category ID
      final categoryId = ServiceCategoryMapper.getCategoryId(serviceType);
      if (categoryId == null) {
        return {
          'ok': false,
          'error': 'Type de service invalide',
          'json': {},
        };
      }

      final body = {
        'title': title,
        'description': description,
        'service_category_id': categoryId,
        'budget': budget,
        'location': location,
        'preferred_time': preferredTime,
        'is_urgent': isUrgent,
      };

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

      // ════════ ADD DETAILED LOGGING ════════
      print('════════ GET MY TASKS ════════');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('═══════════════════════════════');

      final json = _parseResponse(response);

      print('Parsed JSON type: ${json.runtimeType}');
      print('Parsed JSON: $json');

      if (response.statusCode == 200) {
        List<dynamic> tasksData = [];

        // Try different response formats
        if (json is List) {
          print('Response is a List');
          tasksData = json;
        } else if (json is Map) {
          print('Response is a Map');
          if (json['results'] != null) {
            print('Found results key');
            tasksData = json['results'] as List;
          } else if (json['data'] != null) {
            print('Found data key');
            tasksData = json['data'] as List;
          } else if (json['tasks'] != null) {
            print('Found tasks key');
            tasksData = json['tasks'] as List;
          } else {
            print('No known array key found. Keys: ${json.keys}');
          }
        }

        print('Tasks data length: ${tasksData.length}');

        final tasks = <TaskModel>[];
        for (var i = 0; i < tasksData.length; i++) {
          try {
            final taskJson = tasksData[i] as Map<String, dynamic>;
            print(
                'Processing task $i: ${taskJson['id']} - ${taskJson['title']}');
            tasks.add(TaskModel.fromJson(taskJson));
          } catch (e, stackTrace) {
            print('Error parsing task $i: $e');
            print('StackTrace: $stackTrace');
            print('Task data: ${tasksData[i]}');
          }
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
      if (serviceType != null) body['serviceType'] = serviceType;
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

      final json = _parseResponse(response);

      if (response.statusCode == 200) {
        return {
          'ok': true,
          'message': json['message'] ?? 'Candidat accepté',
          'json': json,
        };
      } else {
        return {
          'ok': false,
          'error': json['detail'] ?? 'Échec d\'acceptation',
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

  /// Confirm task completion and payment (للعميل فقط)
  /// Used when client confirms the work is done and approves payment
  Future<Map<String, dynamic>> confirmTaskCompletion({
    required String taskId,
  }) async {
    return await updateTaskStatus(
      taskId: taskId,
      status: 'completed',
    );
  }

  /// Update task status (للعميل والعامل)
  Future<Map<String, dynamic>> updateTaskStatus({
    required String taskId,
    required String status, // 'work_completed', 'completed', 'cancelled'
  }) async {
    try {
      final response = await AuthManager.authenticatedRequest(
        method: 'PUT',
        endpoint: '$_baseUrl/tasks/$taskId/status/',
        body: {'status': status},
      );

      final json = _parseResponse(response);

      if (response.statusCode == 200) {
        return {
          'ok': true,
          'message': json['message'] ?? 'Statut mis à jour',
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

  // ==================== WORKER ENDPOINTS ====================

  /// Get available tasks for workers
  Future<Map<String, dynamic>> getAvailableTasks({
    String? category,
    String? location,
    int? budgetMin,
    int? budgetMax,
    String? sortBy, // 'latest', 'budget_high', 'budget_low', 'urgent'
  }) async {
    try {
      String endpoint = '$_baseUrl/tasks/available/';
      List<String> queryParams = [];

      if (category != null) queryParams.add('category=$category');
      if (location != null) queryParams.add('location=$location');
      if (budgetMin != null) queryParams.add('budget_min=$budgetMin');
      if (budgetMax != null) queryParams.add('budget_max=$budgetMax');
      if (sortBy != null) queryParams.add('sort_by=$sortBy');

      if (queryParams.isNotEmpty) {
        endpoint += '?${queryParams.join('&')}';
      }

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
      return {
        'ok': false,
        'error': 'Erreur réseau: ${e.toString()}',
        'json': {},
      };
    }
  }

  /// Apply to task (للعامل)
  Future<Map<String, dynamic>> applyToTask({
    required String taskId,
    String? message,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (message != null && message.isNotEmpty) {
        body['application_message'] = message;
      }

      final response = await AuthManager.authenticatedRequest(
        method: 'POST',
        endpoint: '$_baseUrl/tasks/$taskId/apply/',
        body: body,
      );

      final json = _parseResponse(response);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'ok': true,
          'message': 'Candidature envoyée',
          'json': json,
        };
      } else {
        return {
          'ok': false,
          'error': json['detail'] ?? 'Échec de candidature',
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

  // ==================== HELPER METHODS ====================

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
    // No client to dispose since we're using AuthManager
  }
}

/// Singleton instance
final TaskService taskService = TaskService();
