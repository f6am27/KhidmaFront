import 'package:flutter/material.dart';
import '../screens/shared_screens/dialogs/success_dialog.dart';
import '../screens/shared_screens/dialogs/subscription_prompt_dialog.dart';

void handleApplyResult(
  BuildContext context,
  Map<String, dynamic> result, {
  VoidCallback? onSuccessDone,
}) {
  print('🔎 handleApplyResult called with: $result');

  // ═══════════════════════════════════════════════════════════
  // ✅ 1. تحقق من النجاح أولاً
  // ═══════════════════════════════════════════════════════════
  if (result['ok'] == true || result['ok'] == 'true') {
    print('✅ Success condition matched!');
    SuccessDialog.show(
      context,
      title: 'SUCCESS!',
      message: 'Votre candidature a été envoyée avec succès.',
      isSuccess: true,
      onDone: onSuccessDone,
    );
    return;
  }

  // ═══════════════════════════════════════════════════════════
  // 🔒 2. تحقق من Soft Lock - **أولوية قصوى!**
  // ═══════════════════════════════════════════════════════════

  // ✅ التحقق المباشر من subscriptionRequired (الطريقة الأساسية)
  if (result['subscriptionRequired'] == true) {
    print('🔒 Soft Lock detected via subscriptionRequired flag!');

    // استخراج معلومات العداد
    final counter = result['counter'];
    final errorType = result['errorType']?.toString() ?? 'worker_limit_reached';
    final message = result['message']?.toString() ??
        result['error']?.toString() ??
        'Limite atteinte, abonnement requis';

    int tasksUsed = 5;
    int tasksRemaining = 0;

    if (counter != null && counter is Map) {
      tasksUsed = counter['tasks_used'] ?? counter['applicationsUsed'] ?? 5;
      tasksRemaining =
          counter['tasks_remaining'] ?? counter['applicationsRemaining'] ?? 0;
    }

    SubscriptionPromptDialog.show(
      context,
      role: 'worker', // ← مهم جداً!
      tasksUsed: tasksUsed,
      tasksRemaining: tasksRemaining,
      errorMessage: message,
    );
    return;
  }

  // ✅ Fallback: التحقق من النص (للتوافق مع إصدارات قديمة من Backend)
  final errorMsg =
      (result['error'] ?? result['message'] ?? '').toString().toLowerCase();
  print('🔎 Parsed errorMsg: "$errorMsg"');

  if (errorMsg.contains('limite') ||
      errorMsg.contains('limit') ||
      errorMsg.contains('abonnement') ||
      errorMsg.contains('subscription') ||
      errorMsg.contains('5 candidatures gratuites') ||
      errorMsg.contains('5 free applications') ||
      errorMsg.contains('maximum') ||
      errorMsg.contains('atteint') ||
      errorMsg.contains('dépassé') ||
      errorMsg.contains('exceeded')) {
    print('🔒 Soft Lock detected via error message!');

    // استخراج معلومات العداد من الـ response
    final counter = result['counter'];
    int tasksUsed = 5;
    int tasksRemaining = 0;

    if (counter != null && counter is Map) {
      tasksUsed = counter['tasks_used'] ?? counter['applicationsUsed'] ?? 5;
      tasksRemaining =
          counter['tasks_remaining'] ?? counter['applicationsRemaining'] ?? 0;
    }

    SubscriptionPromptDialog.show(
      context,
      role: 'worker',
      tasksUsed: tasksUsed,
      tasksRemaining: tasksRemaining,
      errorMessage: result['error']?.toString(),
    );
    return;
  }

  // ═══════════════════════════════════════════════════════════
  // ✅ 3. تقديم سابق
  // ═══════════════════════════════════════════════════════════
  if (errorMsg.contains('déjà') ||
      errorMsg.contains('already') ||
      errorMsg.contains('existe') ||
      errorMsg.contains('exists') ||
      errorMsg.contains('postulé') ||
      errorMsg.contains('applied') ||
      errorMsg.contains('application')) {
    print('✅ Already applied condition matched!');
    SuccessDialog.show(
      context,
      title: 'Déjà postulé',
      message: 'Vous avez déjà postulé pour cette mission.',
      isSuccess: false,
    );
    return;
  }

  // ═══════════════════════════════════════════════════════════
  // ✅ 4. تصنيف خاطئ
  // ═══════════════════════════════════════════════════════════
  if (errorMsg.contains('category') ||
      errorMsg.contains('catégorie') ||
      errorMsg.contains('not allowed') ||
      errorMsg.contains('mismatch') ||
      errorMsg.contains('incompatible') ||
      errorMsg.contains('ne correspond pas') ||
      errorMsg.contains("you don't offer this type of service") ||
      errorMsg.contains("you dont offer this type of service") ||
      errorMsg.contains("don't offer") ||
      errorMsg.contains("dont offer")) {
    print('✅ Category mismatch condition matched!');
    SuccessDialog.show(
      context,
      title: 'Catégorie incompatible',
      message:
          'Vous ne pouvez pas postuler à cette mission car sa catégorie ne correspond pas à votre profil.',
      isSuccess: false,
    );
    return;
  }

  // ═══════════════════════════════════════════════════════════
  // ⚠️ 5. أخطاء عامة أخرى
  // ═══════════════════════════════════════════════════════════
  print('⚠️ No specific condition matched - showing generic error');
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        errorMsg.isNotEmpty ? errorMsg : 'Erreur inconnue',
      ),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.all(16),
      duration: Duration(seconds: 4),
    ),
  );
}
