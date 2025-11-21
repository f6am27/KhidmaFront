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
      color: Colors.black54,
      child: Center(
        child: Container(
          width: 280, // ✅ عرض ثابت أصغر
          padding: const EdgeInsets.all(20), // ✅ padding أصغر
          decoration: BoxDecoration(
            color: isDark ? ThemeColors.darkCardBackground : Colors.white,
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
              // أيقونة أصغر
              Container(
                width: 50, // ✅ أصغر
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1), // ✅ أحمر
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: Colors.red, // ✅ أحمر
                  size: 26,
                ),
              ),
              const SizedBox(height: 16), // ✅ مسافة أصغر

              // العنوان
              Text(
                'Déconnexion',
                style: TextStyle(
                  fontSize: 20, // ✅ أصغر
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
                  fontSize: 14, // ✅ أصغر
                  color:
                      isDark ? ThemeColors.darkTextSecondary : Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20), // ✅ مسافة أصغر

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
                        padding:
                            const EdgeInsets.symmetric(vertical: 12), // ✅ أصغر
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
                          fontSize: 14, // ✅ أصغر
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? ThemeColors.darkTextSecondary
                              : Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // ✅ زر أحمر بدون خلفية
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
                          color: Colors.red, // ✅ نص أحمر
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
      barrierColor: Colors.black54,
      builder: (context) => LogoutConfirmation(
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  }
}
