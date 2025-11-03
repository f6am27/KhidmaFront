// lib/services/firebase_service.dart
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../services/notification_service.dart';
import '../core/storage/token_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Firebase Messaging Service
class FirebaseService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static String? _fcmToken;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Get FCM token
  static String? get fcmToken => _fcmToken;

  /// Initialize Firebase Messaging
  static Future<void> initialize() async {
    try {
      // Request permission for notifications
      await _requestPermission();

      await clearAllNotifications();
      // Get FCM token
      _fcmToken = await _messaging.getToken();

      if (_fcmToken != null) {
        print('🔑 FCM Token: $_fcmToken');

        // Register device token with backend (if user is logged in)
        await registerDeviceIfLoggedIn();
      } else {
        print('⚠️ Failed to get FCM token');
      }

      // Listen to token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        print('🔄 FCM Token refreshed: $newToken');
        _fcmToken = newToken;
        registerDeviceIfLoggedIn();
      });

      // Setup message handlers
      _setupMessageHandlers();

      print('✅ Firebase Messaging initialized');
    } catch (e) {
      print('❌ Firebase Messaging initialization error: $e');
    }
  }

  /// Request notification permission
  static Future<void> _requestPermission() async {
    try {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ Notification permission granted');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        print('⚠️ Notification permission granted provisionally');
      } else {
        print('❌ Notification permission denied');
      }
    } catch (e) {
      print('❌ Error requesting permission: $e');
    }
  }

  /// Register device token with backend// ========================================
// 🆕 دالة عامة يمكن استدعاؤها من أي مكان
// ========================================

  /// Register device token - can be called after login
  static Future<void> registerDeviceIfLoggedIn() async {
    try {
      // Check if user is logged in
      final accessToken = await TokenStorage.readAccess();
      if (accessToken == null || accessToken.isEmpty) {
        print('⚠️ User not logged in, skipping device registration');
        return;
      }

      if (_fcmToken == null) {
        print('⚠️ No FCM token available');
        return;
      }

      // Get device info
      String platform = 'web';
      String deviceName = 'Unknown Device';

      if (Platform.isAndroid) {
        platform = 'android';
        try {
          final deviceInfo = DeviceInfoPlugin();
          final androidInfo = await deviceInfo.androidInfo;
          deviceName = '${androidInfo.manufacturer} ${androidInfo.model}';
          print('📱 Device: $deviceName');
        } catch (e) {
          deviceName = 'Android Device';
          print('⚠️ Could not get device name: $e');
        }
      } else if (Platform.isIOS) {
        platform = 'ios';
        try {
          final deviceInfo = DeviceInfoPlugin();
          final iosInfo = await deviceInfo.iosInfo;
          deviceName = '${iosInfo.name} ${iosInfo.model}';
          print('📱 Device: $deviceName');
        } catch (e) {
          deviceName = 'iOS Device';
          print('⚠️ Could not get device name: $e');
        }
      }

      // Register with backend
      print(
          '📤 Registering device: $deviceName with token: ${_fcmToken!.substring(0, 20)}...');

      final result = await notificationService.registerDevice(
        token: _fcmToken!,
        platform: platform,
        deviceName: deviceName,
        appVersion: '1.0.0',
      );

      if (result['ok']) {
        print('✅ Device registered successfully in backend: $deviceName');
      } else {
        print('⚠️ Failed to register device: ${result['error']}');
      }
    } catch (e) {
      print('❌ Error registering device token: $e');
    }
  }

  /// Setup message handlers
  static void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📬 Foreground message received');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');

      // You can show a local notification or dialog here
      _handleMessage(message);
    });

    // Handle background messages when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📬 Notification opened app');
      print('Data: ${message.data}');

      _handleMessage(message);
    });

    // Handle initial message (when app is opened from terminated state)
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('📬 App opened from terminated state');
        print('Data: ${message.data}');

        _handleMessage(message);
      }
    });
  }

  /// Handle received message
  static void _handleMessage(RemoteMessage message) {
    try {
      final data = message.data;

      // Extract notification details
      final notificationId = data['notification_id'];
      final notificationType = data['notification_type'];
      final taskId = data['task_id'];

      print('📌 Notification details:');
      print('  - ID: $notificationId');
      print('  - Type: $notificationType');
      print('  - Task ID: $taskId');

      // TODO: Navigate to appropriate screen based on notification type
      // You can implement navigation logic here later
    } catch (e) {
      print('❌ Error handling message: $e');
    }
  }

  /// Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      print('✅ Subscribed to topic: $topic');
    } catch (e) {
      print('❌ Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      print('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      print('❌ Error unsubscribing from topic: $e');
    }
  }

  /// Get badge count (iOS only)
  static Future<void> setBadgeCount(int count) async {
    if (Platform.isIOS) {
      try {
        await _messaging.setAutoInitEnabled(true);
        print('✅ Badge count set to: $count');
      } catch (e) {
        print('❌ Error setting badge count: $e');
      }
    }
  }

  /// Delete FCM token
  static Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      _fcmToken = null;
      print('✅ FCM token deleted');
    } catch (e) {
      print('❌ Error deleting token: $e');
    }
  }

  /// Clear all notifications from notification tray
  static Future<void> clearAllNotifications() async {
    try {
      // Clear all notifications
      await _localNotifications.cancelAll();

      // Reset badge count for iOS
      if (Platform.isIOS) {
        await _messaging.setAutoInitEnabled(true);
      }

      print('🧹 All notifications cleared');
    } catch (e) {
      print('⚠️ Error clearing notifications: $e');
    }
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📬 Background message received');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Data: ${message.data}');
}
