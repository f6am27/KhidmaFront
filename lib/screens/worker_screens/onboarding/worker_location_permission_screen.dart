import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared_screens/onboarding/location_permission_base_screen.dart';

class WorkerLocationPermissionScreen extends StatelessWidget {
  const WorkerLocationPermissionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LocationPermissionBaseScreen(
      userType: UserType.worker,
      title: 'Quelle est votre position ?',
      subtitle: 'Pour trouver les missions les plus proches de vous.',
      primaryButtonText: 'Autoriser l\'accès à la position',
      secondaryButtonText: 'Entrer la position manuellement',
      onLocationGranted: () async {
        // حفظ الحالة وتفعيل السويتش
        await _saveLocationState(true);
        // العودة للتطبيق الرئيسي
        _navigateToHome(context);
      },
      onLocationDenied: () async {
        // حفظ الحالة بدون تفعيل السويتش
        await _saveLocationState(false);
        _navigateToHome(context);
      },
      onManualEntry: () async {
        // حفظ الحالة بدون تفعيل السويتش
        await _saveLocationState(false);
        _navigateToHome(context);
      },
    );
  }

  // حفظ حالة الموقع
  Future<void> _saveLocationState(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('worker_location_permission_requested', true);
      await prefs.setBool('worker_location_enabled', enabled);
    } catch (e) {
      print('Error saving location state: $e');
    }
  }

  // التنقل للشاشة الرئيسية
  void _navigateToHome(BuildContext context) {
    // إعادة بناء HomeRouter ليعرض WorkerMainNavigation
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false,
      arguments: {'role': 'worker'},
    );
  }

  // دالة للتحقق من الحاجة لعرض الشاشة
  static Future<bool> shouldShow() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return !(prefs.getBool('worker_location_permission_requested') ?? false);
    } catch (e) {
      print('Error checking location permission state: $e');
      return false;
    }
  }
}
