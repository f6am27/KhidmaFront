// lib/services/notification_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';
import '../models/notification_model.dart';
import 'auth_manager.dart';

class NotificationService {
  final String _baseUrl =
      ApiConfig.baseUrl().replaceAll('/users', '/notifications');
  final http.Client _client = http.Client();

  /// Register device token for push notifications
  Future<Map<String, dynamic>> registerDevice({
    required String token,
    required String platform, // 'android', 'ios', 'web'
    String? deviceName,
    String? appVersion,
  }) async {
    try {
      print('📍 Registering device token...');

      final body = {
        'token': token,
        'platform': platform,
      };

      if (deviceName != null) {
        body['device_name'] = deviceName;
      }

      if (appVersion != null) {
        body['app_version'] = appVersion;
      }

      final response = await AuthManager.authenticatedRequest(
        method: 'POST',
        endpoint: '$_baseUrl/register-device/',
        body: body,
      );

      print('📱 Register device response: ${response.statusCode}');

      final json = _parseResponse(response);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('✅ Device registered successfully');
        return {
          'ok': true,
          'message': json['message'] ?? 'Device registered',
          'data': json['data'],
          'json': json,
        };
      } else {
        print('⚠️ Registration failed: ${json['error']}');
        return {
          'ok': false,
          'error': json['error'] ?? 'Failed to register device',
          'json': json,
        };
      }
    } on AuthException catch (e) {
      print('❌ Auth error: ${e.message}');
      return {
        'ok': false,
        'error': e.needsLogin ? 'Veuillez vous reconnecter' : e.message,
        'needsLogin': e.needsLogin,
        'json': {},
      };
    } catch (e) {
      print('❌ Error: $e');
      return {
        'ok': false,
        'error': 'Erreur réseau: ${e.toString()}',
        'json': {},
      };
    }
  }

  /// Get notifications list
  Future<Map<String, dynamic>> getNotifications({
    bool? isRead,
    String? notificationType,
    int? days,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      String endpoint = '$_baseUrl/';
      List<String> params = [];

      if (isRead != null) {
        params.add('is_read=${isRead.toString()}');
      }

      if (notificationType != null && notificationType.isNotEmpty) {
        params.add('type=$notificationType');
      }

      if (days != null) {
        params.add('days=$days');
      }

      params.add('limit=$limit');
      params.add('offset=$offset');

      if (params.isNotEmpty) {
        endpoint += '?${params.join('&')}';
      }

      print('📍 Fetching notifications: $endpoint');

      final response = await AuthManager.authenticatedRequest(
        method: 'GET',
        endpoint: endpoint,
      );

      print('Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = _parseResponse(response);

        List<dynamic> notificationsData = [];

        if (json is List) {
          notificationsData = json;
        } else if (json is Map && json['results'] != null) {
          notificationsData = json['results'] as List;
        }

        List<NotificationModel> notifications = notificationsData
            .map((item) {
              try {
                return NotificationModel.fromJson(item as Map<String, dynamic>);
              } catch (e) {
                print('Notification parse error: $e');
                return null;
              }
            })
            .whereType<NotificationModel>()
            .toList();

        print('✅ Loaded ${notifications.length} notifications');

        return {
          'ok': true,
          'notifications': notifications,
          'count': notifications.length,
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
      print('❌ Error: $e');
      return {
        'ok': false,
        'error': 'Erreur réseau: ${e.toString()}',
        'json': {},
      };
    }
  }

  /// Get notification details
  Future<Map<String, dynamic>> getNotificationDetails(
      int notificationId) async {
    try {
      print('📍 Fetching notification $notificationId details...');

      final response = await AuthManager.authenticatedRequest(
        method: 'GET',
        endpoint: '$_baseUrl/$notificationId/',
      );

      print('Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = _parseResponse(response);
        final notification = NotificationModel.fromJson(json);

        print('✅ Notification details loaded');

        return {
          'ok': true,
          'notification': notification,
          'json': json,
        };
      } else {
        final json = _parseResponse(response);
        return {
          'ok': false,
          'error': json['detail'] ?? 'Notification non trouvée',
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
      print('❌ Error: $e');
      return {
        'ok': false,
        'error': 'Erreur réseau: ${e.toString()}',
        'json': {},
      };
    }
  }

  /// Mark notification as read
  Future<Map<String, dynamic>> markAsRead(int notificationId) async {
    try {
      print('📍 Marking notification $notificationId as read...');

      final response = await AuthManager.authenticatedRequest(
        method: 'PUT',
        endpoint: '$_baseUrl/$notificationId/mark-read/',
      );

      print('Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = _parseResponse(response);

        print('✅ Notification marked as read');

        return {
          'ok': true,
          'message': json['message'] ?? 'Notification marquée comme lue',
          'json': json,
        };
      } else {
        final json = _parseResponse(response);
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
      print('❌ Error: $e');
      return {
        'ok': false,
        'error': 'Erreur réseau: ${e.toString()}',
        'json': {},
      };
    }
  }

  /// Mark notification as unread
  Future<Map<String, dynamic>> markAsUnread(int notificationId) async {
    try {
      print('📍 Marking notification $notificationId as unread...');

      final response = await AuthManager.authenticatedRequest(
        method: 'PUT',
        endpoint: '$_baseUrl/$notificationId/mark-unread/',
      );

      print('Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = _parseResponse(response);

        print('✅ Notification marked as unread');

        return {
          'ok': true,
          'message': json['message'] ?? 'Notification marquée comme non lue',
          'json': json,
        };
      } else {
        final json = _parseResponse(response);
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
      print('❌ Error: $e');
      return {
        'ok': false,
        'error': 'Erreur réseau: ${e.toString()}',
        'json': {},
      };
    }
  }

  /// Mark all notifications as read
  Future<Map<String, dynamic>> markAllAsRead() async {
    try {
      print('📍 Marking all notifications as read...');

      final response = await AuthManager.authenticatedRequest(
        method: 'PUT',
        endpoint: '$_baseUrl/mark-all-read/',
      );

      print('Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = _parseResponse(response);

        print('✅ All notifications marked as read');

        return {
          'ok': true,
          'message':
              json['message'] ?? 'Toutes les notifications marquées comme lues',
          'updatedCount': json['updated_count'] ?? 0,
          'json': json,
        };
      } else {
        final json = _parseResponse(response);
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
      print('❌ Error: $e');
      return {
        'ok': false,
        'error': 'Erreur réseau: ${e.toString()}',
        'json': {},
      };
    }
  }

  /// Delete notification
  Future<Map<String, dynamic>> deleteNotification(int notificationId) async {
    try {
      print('📍 Deleting notification $notificationId...');

      final response = await AuthManager.authenticatedRequest(
        method: 'DELETE',
        endpoint: '$_baseUrl/$notificationId/delete/',
      );

      print('Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = _parseResponse(response);

        print('✅ Notification deleted');

        return {
          'ok': true,
          'message': json['message'] ?? 'Notification supprimée',
          'json': json,
        };
      } else {
        final json = _parseResponse(response);
        return {
          'ok': false,
          'error': json['detail'] ?? 'Échec de suppression',
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
      print('❌ Error: $e');
      return {
        'ok': false,
        'error': 'Erreur réseau: ${e.toString()}',
        'json': {},
      };
    }
  }

  /// Bulk actions on notifications
  Future<Map<String, dynamic>> bulkAction({
    required List<int> notificationIds,
    required String action, // 'mark_read', 'mark_unread', 'delete'
  }) async {
    try {
      print(
          '📍 Performing bulk action: $action on ${notificationIds.length} notifications');

      final body = {
        'notification_ids': notificationIds,
        'action': action,
      };

      final response = await AuthManager.authenticatedRequest(
        method: 'POST',
        endpoint: '$_baseUrl/bulk-actions/',
        body: body,
      );

      print('Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = _parseResponse(response);

        print('✅ Bulk action completed');

        return {
          'ok': true,
          'message': json['message'] ?? 'Action effectuée',
          'affectedCount': json['affected_count'] ?? 0,
          'json': json,
        };
      } else {
        final json = _parseResponse(response);
        return {
          'ok': false,
          'error': json['detail'] ?? 'Échec de l\'action',
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
      print('❌ Error: $e');
      return {
        'ok': false,
        'error': 'Erreur réseau: ${e.toString()}',
        'json': {},
      };
    }
  }

  /// Clear all read notifications
  Future<Map<String, dynamic>> clearAllRead() async {
    try {
      print('📍 Clearing all read notifications...');

      final response = await AuthManager.authenticatedRequest(
        method: 'DELETE',
        endpoint: '$_baseUrl/clear-all/',
      );

      print('Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = _parseResponse(response);

        print('✅ All read notifications cleared');

        return {
          'ok': true,
          'message': json['message'] ?? 'Notifications supprimées',
          'deletedCount': json['deleted_count'] ?? 0,
          'json': json,
        };
      } else {
        final json = _parseResponse(response);
        return {
          'ok': false,
          'error': json['detail'] ?? 'Échec de suppression',
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
      print('❌ Error: $e');
      return {
        'ok': false,
        'error': 'Erreur réseau: ${e.toString()}',
        'json': {},
      };
    }
  }

  /// Get notification statistics
  Future<Map<String, dynamic>> getStats() async {
    try {
      print('📍 Fetching notification statistics...');

      final response = await AuthManager.authenticatedRequest(
        method: 'GET',
        endpoint: '$_baseUrl/stats/',
      );

      print('Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = _parseResponse(response);
        final stats = NotificationStatsModel.fromJson(json);

        print('✅ Stats loaded: ${stats.unreadNotifications} unread');

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
      print('❌ Error: $e');
      return {
        'ok': false,
        'error': 'Erreur réseau: ${e.toString()}',
        'json': {},
      };
    }
  }

  /// Get notification settings
  Future<Map<String, dynamic>> getSettings() async {
    try {
      print('📍 Fetching notification settings...');

      final response = await AuthManager.authenticatedRequest(
        method: 'GET',
        endpoint: '$_baseUrl/settings/',
      );

      print('Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = _parseResponse(response);
        final settings = NotificationSettingsModel.fromJson(json);

        print('✅ Settings loaded');

        return {
          'ok': true,
          'settings': settings,
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
      print('❌ Error: $e');
      return {
        'ok': false,
        'error': 'Erreur réseau: ${e.toString()}',
        'json': {},
      };
    }
  }

  /// Update notification settings
  /// Update notification settings
  Future<Map<String, dynamic>> updateSettings({
    required bool notificationsEnabled,
  }) async {
    try {
      print('📍 Updating notification settings to: $notificationsEnabled');

      final body = {
        'notifications_enabled': notificationsEnabled,
      };

      final response = await AuthManager.authenticatedRequest(
        method: 'PATCH', // ✅ تغيير من PUT إلى PATCH
        endpoint: '$_baseUrl/settings/',
        body: body,
      );

      print('✅ Response status: ${response.statusCode}');
      print('📩 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final json = _parseResponse(response);

        print('✅ Settings updated successfully');

        return {
          'ok': true,
          'message': 'Paramètres mis à jour',
          'settings': NotificationSettingsModel.fromJson(json),
          'json': json,
        };
      } else {
        final json = _parseResponse(response);
        print('❌ Update failed: $json');
        return {
          'ok': false,
          'error': json['detail'] ?? 'Échec de mise à jour',
          'json': json,
        };
      }
    } on AuthException catch (e) {
      print('❌ Auth error: ${e.message}');
      return {
        'ok': false,
        'error': e.needsLogin ? 'Veuillez vous reconnecter' : e.message,
        'needsLogin': e.needsLogin,
        'json': {},
      };
    } catch (e) {
      print('❌ Error: $e');
      return {
        'ok': false,
        'error': 'Erreur réseau: ${e.toString()}',
        'json': {},
      };
    }
  }

  /// Get available notification types for current user role
  Future<Map<String, dynamic>> getNotificationTypes() async {
    try {
      print('📍 Fetching notification types...');

      final response = await AuthManager.authenticatedRequest(
        method: 'GET',
        endpoint: '$_baseUrl/types/',
      );

      print('Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = _parseResponse(response);

        print('✅ Notification types loaded');

        return {
          'ok': true,
          'userRole': json['user_role'],
          'notificationTypes': json['notification_types'],
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
      print('❌ Error: $e');
      return {
        'ok': false,
        'error': 'Erreur réseau: ${e.toString()}',
        'json': {},
      };
    }
  }

  /// Test notification (send test push notification)
  Future<Map<String, dynamic>> testNotification({
    String? title,
    String? message,
  }) async {
    try {
      print('📍 Sending test notification...');

      final body = <String, dynamic>{};

      if (title != null) {
        body['title'] = title;
      }

      if (message != null) {
        body['message'] = message;
      }

      final response = await AuthManager.authenticatedRequest(
        method: 'POST',
        endpoint: '$_baseUrl/test/',
        body: body,
      );

      print('Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = _parseResponse(response);

        print('✅ Test notification sent');

        return {
          'ok': true,
          'message': json['message'] ?? 'Test notification envoyée',
          'json': json,
        };
      } else {
        final json = _parseResponse(response);
        return {
          'ok': false,
          'error': json['error'] ?? 'Échec d\'envoi',
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
      print('❌ Error: $e');
      return {
        'ok': false,
        'error': 'Erreur réseau: ${e.toString()}',
        'json': {},
      };
    }
  }

  /// Helper method to parse response
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
final NotificationService notificationService = NotificationService();
