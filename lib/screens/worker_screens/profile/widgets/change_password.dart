import 'package:flutter/material.dart';
import '../../../../core/theme/theme_colors.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? ThemeColors.darkBackground : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: isDark ? ThemeColors.darkBackground : Colors.grey[50],
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark
                ? ThemeColors.darkTextPrimary
                : ThemeColors.lightTextPrimary,
            size: 20,
          ),
        ),
        title: Text(
          'Changer le mot de passe',
          style: TextStyle(
            color: isDark
                ? ThemeColors.darkTextPrimary
                : ThemeColors.lightTextPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // العنوان والوصف
            Text(
              'Modifier votre mot de passe',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? ThemeColors.darkTextPrimary
                    : ThemeColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Votre nouveau mot de passe doit être différent du mot de passe précédemment utilisé.',
              style: TextStyle(
                fontSize: 14,
                color:
                    isDark ? ThemeColors.darkTextSecondary : Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),

            // حقل كلمة المرور الحالية
            Text(
              'Mot de passe actuel',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? ThemeColors.darkTextPrimary
                    : ThemeColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            _buildPasswordField(
              controller: _currentPasswordController,
              isVisible: _isCurrentPasswordVisible,
              onToggleVisibility: () {
                setState(() {
                  _isCurrentPasswordVisible = !_isCurrentPasswordVisible;
                });
              },
              isDark: isDark,
            ),
            const SizedBox(height: 20),

            // حقل كلمة المرور الجديدة
            Text(
              'Nouveau mot de passe',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? ThemeColors.darkTextPrimary
                    : ThemeColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            _buildPasswordField(
              controller: _newPasswordController,
              isVisible: _isNewPasswordVisible,
              onToggleVisibility: () {
                setState(() {
                  _isNewPasswordVisible = !_isNewPasswordVisible;
                });
              },
              isDark: isDark,
            ),
            const SizedBox(height: 20),

            // حقل تأكيد كلمة المرور
            Text(
              'Confirmer le mot de passe',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? ThemeColors.darkTextPrimary
                    : ThemeColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            _buildPasswordField(
              controller: _confirmPasswordController,
              isVisible: _isConfirmPasswordVisible,
              onToggleVisibility: () {
                setState(() {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                });
              },
              isDark: isDark,
            ),
            const SizedBox(height: 40),

            // زر التأكيد
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _handleChangePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColors.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Changer le mot de passe',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    required bool isDark,
  }) {
    // لون حافة خفيف في الوضعين
    final Color idleBorder =
        (isDark ? Colors.white : Colors.black).withOpacity(0.12);

    return Container(
      child: TextField(
        controller: controller,
        obscureText: !isVisible,
        style: TextStyle(
          color: isDark
              ? ThemeColors.darkTextPrimary
              : ThemeColors.lightTextPrimary,
        ),
        decoration: InputDecoration(
          // إزالة الـ placeholder نهائيًا
          // (لا نمرر hintText أو hintStyle)
          prefixIcon: Icon(
            Icons.lock_outline,
            color: isDark ? ThemeColors.darkTextSecondary : Colors.grey[500],
            size: 20,
          ),
          suffixIcon: IconButton(
            onPressed: onToggleVisibility,
            icon: Icon(
              isVisible
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: isDark ? ThemeColors.darkTextSecondary : Colors.grey[500],
              size: 20,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          // الحواف المضافة
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: idleBorder, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: ThemeColors.primaryColor, width: 1.6),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: idleBorder, width: 1),
          ),
        ),
      ),
    );
  }

  void _handleChangePassword() {
    // التحقق من صحة البيانات
    if (_currentPasswordController.text.isEmpty) {
      _showSnackBar('Veuillez saisir votre mot de passe actuel');
      return;
    }

    if (_newPasswordController.text.isEmpty) {
      _showSnackBar('Veuillez saisir le nouveau mot de passe');
      return;
    }

    if (_newPasswordController.text.length < 6) {
      _showSnackBar('Le mot de passe doit contenir au moins 6 caractères');
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showSnackBar('Les mots de passe ne correspondent pas');
      return;
    }

    // هنا يمكن إضافة منطق تغيير كلمة المرور
    _showSnackBar('Mot de passe modifié avec succès', isSuccess: true);

    // العودة للشاشة السابقة بعد ثانيتين
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
