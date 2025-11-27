import 'package:flutter/material.dart';
import '../screens/shared_screens/dialogs/success_dialog.dart';

void handleApplyResult(
  BuildContext context,
  Map<String, dynamic> result, {
  VoidCallback? onSuccessDone,
}) {
  print('🔎 handleApplyResult called with: $result');

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

  final errorMsg = (result['error'] ?? '').toString().toLowerCase();
  print('🔎 Parsed errorMsg in handleApplyResult: "$errorMsg"');

  // ✅ تقديم سابق
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

  // ✅ تصنيف خاطئ
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

  // ⚠️ أخطاء أخرى
  print('⚠️ No condition matched - showing snackbar');
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        errorMsg.isNotEmpty ? errorMsg : 'Erreur inconnue',
      ),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 3),
    ),
  );
}
