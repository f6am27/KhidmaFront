import 'package:flutter/material.dart';
import '../../../core/theme/theme_colors.dart';

class LogoutConfirmation extends StatelessWidget {
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const LogoutConfirmation({
    Key? key,
    this.onConfirm,
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent, // ✅ خلفية شفافة بدلاً من black54
      child: Center(
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: (isDark ? ThemeColors.darkCardBackground : Colors.white)
                .withOpacity(0.85), // ✅ شفافية 0.85
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // أيقونة
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: Colors.red,
                  size: 26,
                ),
              ),
              const SizedBox(height: 16),

              // العنوان
              Text(
                'Déconnexion',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? ThemeColors.darkTextPrimary
                      : ThemeColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 8),

              // الرسالة
              Text(
                'Êtes-vous sûr de vouloir\nvous déconnecter ?',
                style: TextStyle(
                  fontSize: 14,
                  color:
                      isDark ? ThemeColors.darkTextSecondary : Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // الأزرار
              Row(
                children: [
                  // زر الإلغاء
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                        onCancel?.call();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: BorderSide(
                          color: isDark
                              ? ThemeColors.darkBorder
                              : Colors.grey[300]!,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        'Annuler',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? ThemeColors.darkTextSecondary
                              : Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // زر تسجيل الخروج
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                        onConfirm?.call();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: BorderSide(
                          color: Colors.red,
                          width: 1.5,
                        ),
                      ),
                      child: const Text(
                        'Se déconnecter',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<bool?> show(
    BuildContext context, {
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.3), // ✅ خلفية شفافة خفيفة
      builder: (context) => LogoutConfirmation(
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  }
}
