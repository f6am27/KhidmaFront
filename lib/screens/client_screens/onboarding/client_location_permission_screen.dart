import 'package:flutter/material.dart';
import '../../shared_screens/onboarding/location_permission_base_screen.dart';

class ClientLocationPermissionScreen extends StatelessWidget {
  const ClientLocationPermissionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LocationPermissionBaseScreen(
      userType: UserType.client,
      title: 'Où êtes-vous situé ?',
      subtitle:
          'Pour vous connecter avec les prestataires de services les plus proches.',
      primaryButtonText: 'Autoriser l\'accès à la position',
      // لا يوجد زر ثانوي للعميل لأنه سيظهر فقط عند الحاجة
      onLocationGranted: () {
        Navigator.pop(context, true); // إرجاع true عند الموافقة
      },
      onLocationDenied: () {
        Navigator.pop(context, false); // إرجاع false عند الرفض
      },
    );
  }

  // دالة لعرض الشاشة عند الحاجة (للبحث أو النشر)
  static Future<bool?> showWhenNeeded(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ClientLocationPermissionScreen(),
    );
  }
}
