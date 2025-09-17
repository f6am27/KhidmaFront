import 'package:flutter/material.dart';
import 'package:micro_emploi_app/constants/colors.dart';
import 'package:micro_emploi_app/constants/text_styles.dart';
import '../../services/auth_api.dart'; // <<< KEEP
import 'package:micro_emploi_app/routes/app_routes.dart'; // <<< NEW

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // state
  final _pass1 = TextEditingController();
  final _pass2 = TextEditingController();
  bool _loading = false;
  bool _showConfirmWarningRed = false;
  bool _obscure1 = true;
  bool _obscure2 = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _animationController.forward();

    _pass1.addListener(_syncConfirmWarning);
    _pass2.addListener(_syncConfirmWarning);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pass1.dispose();
    _pass2.dispose();
    super.dispose();
  }

  void _syncConfirmWarning() {
    final mismatch = _pass1.text.isNotEmpty &&
        _pass2.text.isNotEmpty &&
        _pass1.text != _pass2.text;
    setState(() => _showConfirmWarningRed = mismatch);
  }

  String? _passVal(String? v) {
    if (v == null || v.isEmpty) return 'Veuillez entrer un mot de passe';
    if (v.length < 8) return 'Au moins 8 caractères';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    const double radius = 32;

    // READ ARGS (phone, code, role)
    final args = (ModalRoute.of(context)?.settings.arguments as Map?) ?? {};
    final String phone = (args['phone'] ?? '') as String;
    final String code = (args['code'] ?? '') as String;

    // <<< NEW: role with normalization (default client)
    final String roleRaw =
        ((args['role'] ?? 'client') as String).toLowerCase().trim();
    final String role = (roleRaw == 'prestataire') ? 'worker' : roleRaw;
    // >>> END NEW

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // decorations
            IgnorePointer(
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Transform.translate(
                      offset: const Offset(-30, 40),
                      child: _decorCircle(150, const [
                        Color(0xFF8B7CF6),
                        Color(0xFFA78BFA),
                      ]),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Transform.translate(
                      offset: const Offset(0, 20),
                      child: _decorCircle(95, const [
                        Color(0xFFC4B5FD),
                        Color(0xFFDDD6FE),
                      ]),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Transform.translate(
                      offset: const Offset(20, 35),
                      child: _decorCircle(120, const [
                        Color(0xFFA78BFA),
                        Color(0xFFC4B5FD),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
            // content
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: Icon(Icons.close, color: AppColors.textPrimary),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Parfait!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Créons un nouveau mot de passe pour votre compte.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 34),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _outlinedPasswordField(
                            controller: _pass1,
                            obscure: _obscure1,
                            toggle: () =>
                                setState(() => _obscure1 = !_obscure1),
                            radius: radius,
                            hint: 'Nouveau mot de passe',
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Le mot de passe doit contenir au moins 8 caractères.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 20),
                          _outlinedPasswordField(
                            controller: _pass2,
                            obscure: _obscure2,
                            toggle: () =>
                                setState(() => _obscure2 = !_obscure2),
                            radius: radius,
                            hint: 'Confirmez mot de passe',
                            forceError: _showConfirmWarningRed,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Les deux mots de passe doivent correspondre.',
                            style: TextStyle(
                              fontSize: 12,
                              color: _showConfirmWarningRed
                                  ? AppColors.red
                                  : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 32),
                          _primaryButton(
                            label:
                                _loading ? '...' : 'Confirmer le mot de passe ',
                            // في onTap للزر الرئيسي، التحديث:

                            onTap: _loading
                                ? null
                                : () async {
                                    if (!_formKey.currentState!.validate())
                                      return;

                                    if (_pass1.text != _pass2.text) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'كلمتا المرور غير متطابقتين')),
                                      );
                                      return;
                                    }

                                    setState(() => _loading = true);

                                    try {
                                      final r = await AuthApi().pwdConfirm(
                                        phone: phone,
                                        code: code,
                                        newPassword: _pass1.text,
                                        newPasswordConfirm: _pass2.text,
                                      );

                                      if (r['ok'] == true) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'تم تغيير كلمة المرور بنجاح')),
                                        );

                                        // العودة إلى شاشة الدخول المناسبة حسب الدور
                                        Navigator.pushReplacementNamed(
                                          context,
                                          AppRoutes.login,
                                          arguments: {'role': role},
                                        );
                                      } else {
                                        // فشل تغيير كلمة المرور
                                        final json = r['json'] ?? {};
                                        String errorMessage =
                                            'تعذّر تغيير كلمة المرور';

                                        if (json['detail'] != null) {
                                          if (json['detail'] is String) {
                                            errorMessage = json['detail'];
                                          } else if (json['detail'] is Map) {
                                            final details =
                                                json['detail'] as Map;
                                            if (details['code'] != null) {
                                              errorMessage = details['code'][0];
                                            } else if (details[
                                                    'new_password'] !=
                                                null) {
                                              errorMessage =
                                                  details['new_password'][0];
                                            } else if (details[
                                                    'non_field_errors'] !=
                                                null) {
                                              errorMessage =
                                                  details['non_field_errors']
                                                      [0];
                                            }
                                          }
                                        } else if (json['code'] != null) {
                                          switch (json['code']) {
                                            case 'invalid_code':
                                              errorMessage =
                                                  'رمز التحقق غير صالح';
                                              break;
                                            case 'expired_code':
                                              errorMessage =
                                                  'انتهت صلاحية رمز التحقق';
                                              break;
                                            case 'user_not_found':
                                              errorMessage =
                                                  'المستخدم غير موجود';
                                              break;
                                            default:
                                              errorMessage = json['code'];
                                          }
                                        }

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(content: Text(errorMessage)),
                                        );
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'حدث خطأ في الاتصال: ${e.toString()}')),
                                      );
                                    } finally {
                                      if (mounted)
                                        setState(() => _loading = false);
                                    }
                                  },
                            radius: radius,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // UI helpers
  Widget _decorCircle(double size, List<Color> colors) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: colors),
      ),
    );
  }

  Widget _outlinedPasswordField({
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback toggle,
    required double radius,
    String? hint,
    bool forceError = false,
  }) {
    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
    );

    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: _passVal,
      style: AppTextStyles.bodyText.copyWith(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        filled: false,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16, right: 10),
          child:
              Icon(Icons.lock_outline, color: AppColors.mediumGray, size: 20),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 52),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton(
            onPressed: toggle,
            icon: Icon(
              obscure
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.mediumGray,
              size: 20,
            ),
          ),
        ),
        suffixIconConstraints: const BoxConstraints(minWidth: 45),
        border: baseBorder,
        enabledBorder: baseBorder,
        focusedBorder: baseBorder.copyWith(
          borderSide: BorderSide(color: AppColors.primaryPurple, width: 2),
        ),
        errorBorder: baseBorder.copyWith(
          borderSide: BorderSide(color: AppColors.red, width: 1.5),
        ),
        focusedErrorBorder: baseBorder.copyWith(
          borderSide: BorderSide(color: AppColors.red, width: 2),
        ),
      ),
      autovalidateMode:
          forceError ? AutovalidateMode.always : AutovalidateMode.disabled,
    );
  }

  Widget _primaryButton({
    required String label,
    required VoidCallback? onTap,
    required double radius,
  }) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
