import 'package:flutter/material.dart';
// import 'client_screens/home/home_screen.dart';
import 'worker_screens/worker_home_screen.dart';
// استيراد نظام التنقل الجديد للعملاء
import 'package:micro_emploi_app/widgets/client_main_navigation.dart';

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

    // للعاملين نعرض WorkerHomeScreen كما هو (مؤقتاً)
    if (resolvedRole == 'worker') return WorkerHomeScreen();

    // للعملاء نستخدم نظام التنقل الجديد ClientMainNavigation
    return ClientMainNavigation();
  }
}
