import 'package:flutter/material.dart';
// استيراد نظام التنقل الجديد للعملاء
import 'package:micro_emploi_app/widgets/client_main_navigation.dart';
import 'package:micro_emploi_app/widgets/worker_main_navigation.dart';

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

    // للعاملين نستخدم نظام التنقل الجديد WorkerMainNavigation
    if (resolvedRole == 'worker') return WorkerMainNavigation();

    // للعملاء نستخدم نظام التنقل الجديد ClientMainNavigation
    return ClientMainNavigation();
  }
}
