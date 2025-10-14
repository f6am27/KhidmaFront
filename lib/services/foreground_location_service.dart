// lib/services/foreground_location_service.dart

import 'dart:async';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'location_service.dart';

class ForegroundLocationService {
  static final ForegroundLocationService _instance =
      ForegroundLocationService._internal();
  factory ForegroundLocationService() => _instance;
  ForegroundLocationService._internal();

  bool _isRunning = false;

  bool get isRunning => _isRunning;

  Future<void> initialize() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'location_tracking',
        channelName: 'Suivi de position',
        channelDescription: 'Micro Emploi suit votre position',
        onlyAlertOnce: true,
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(300000),
        autoRunOnBoot: false,
        autoRunOnMyPackageReplaced: false,
        allowWakeLock: true,
        allowWifiLock: false,
      ),
    );
  }

  Future<bool> start() async {
    if (_isRunning) return true;

    await initialize();

    try {
      await FlutterForegroundTask.startService(
        serviceId: 256,
        notificationTitle: 'Position active',
        notificationText: 'Micro Emploi suit votre position',
        notificationIcon: null,
        notificationButtons: [],
        callback: _startCallback,
      );

      _isRunning = true;
      print('✅ Foreground service started');
      return true;
    } catch (e) {
      print('❌ Failed to start service: $e');
      return false;
    }
  }

  Future<bool> stop() async {
    if (!_isRunning) return true;

    try {
      await FlutterForegroundTask.stopService();
      _isRunning = false;
      print('🔴 Foreground service stopped');
      return true;
    } catch (e) {
      print('❌ Failed to stop service: $e');
      return false;
    }
  }

  @pragma('vm:entry-point')
  static void _startCallback() {
    FlutterForegroundTask.setTaskHandler(_LocationTaskHandler());
  }
}

class _LocationTaskHandler extends TaskHandler {
  // ✅ التصحيح: إضافة Future و TaskStarter
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    print('🟢 Background tracking started');
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {
    print('🔄 Background update at ${timestamp.hour}:${timestamp.minute}');

    try {
      await locationService.getCurrentLocation(sendToBackend: true);

      FlutterForegroundTask.updateService(
        notificationTitle: 'Position active',
        notificationText:
            'Mise à jour: ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
      );
    } catch (e) {
      print('❌ Background update failed: $e');
    }
  }

  // ✅ التصحيح: إضافة Future
  @override
  Future<void> onDestroy(DateTime timestamp) async {
    print('🔴 Background tracking stopped');
  }
}

final foregroundLocationService = ForegroundLocationService();
