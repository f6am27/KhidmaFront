import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// استيراد نظام التنقل الجديد للعملاء
import 'package:micro_emploi_app/widgets/client_main_navigation.dart';
import 'package:micro_emploi_app/widgets/worker_main_navigation.dart';
// استيراد واجهة طلب الموقع للعامل
import 'worker_screens/onboarding/worker_location_permission_screen.dart';

class HomeRouter extends StatelessWidget {
  final String? role;
  const HomeRouter({Key? key, this.role}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<dynamic, dynamic>?;
    final raw =
        (role ?? (args?['role'] as String?) ?? 'client').toLowerCase().trim();

    final resolvedRole =
        (raw == 'worker' || raw == 'prestataire') ? 'worker' : 'client';

    // للعاملين نتحقق أولاً من حاجة عرض واجهة طلب الموقع
    if (resolvedRole == 'worker') {
      return FutureBuilder<bool>(
        future: _shouldShowWorkerLocationScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // شاشة تحميل بسيطة أثناء التحقق
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // إذا كان يحتاج لرؤية واجهة طلب الموقع
          if (snapshot.data == true) {
            return WorkerLocationPermissionScreen();
          }

          // وإلا يذهب للتنقل العادي
          return WorkerMainNavigation();
        },
      );
    }

    // للعملاء نستخدم نظام التنقل الجديد ClientMainNavigation (بدون تغيير)
    return ClientMainNavigation();
  }

  Future<bool> _shouldShowWorkerLocationScreen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // التحقق إذا كان العامل قد رأى واجهة طلب الموقع من قبل
      final hasSeenLocationScreen =
          prefs.getBool('worker_location_permission_requested') ?? false;

      // إذا لم يرها من قبل، يجب عرضها
      return !hasSeenLocationScreen;
    } catch (e) {
      // في حالة الخطأ، لا نعرض الواجهة لتجنب التعطيل
      return false;
    }
  }
}
