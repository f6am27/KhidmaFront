import 'package:flutter/material.dart';
import 'package:micro_emploi_app/constants/colors.dart';
import 'package:micro_emploi_app/constants/text_styles.dart';
import 'package:micro_emploi_app/routes/app_routes.dart';
// >>> ADD: imports
import '../../services/auth_api.dart';
import '../../core/storage/token_storage.dart';
// <<< END ADD

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final _formKey = GlobalKey<FormState>();

  // >>> ADD: state
  final _idController = TextEditingController(); // اسم المستخدم أو الهاتف
  final _passController = TextEditingController();
  bool _loading = false;
  // <<< END ADD

  bool _obscurePassword = true;

  String get _role {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final r = (args?['role'] as String?)?.toLowerCase().trim();
    if (r == 'worker' || r == 'prestataire') return 'prestataire';
    return 'client';
  }

  String get _title => _role == 'prestataire'
      ? 'Connexion du prestataire'
      : 'Connexion du client';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    // >>> ADD: dispose
    _idController.dispose();
    _passController.dispose();
    // <<< END ADD
    super.dispose();
  }

  void _goToRegistration() {
    Navigator.pushReplacementNamed(
      context,
      '/registration',
      arguments: {'role': _role},
    );
  }

  void _goToForgotPassword() {
    Navigator.pushNamed(
      context,
      AppRoutes.forgotPassword,
      arguments: {'role': _role},
    );
  }

  @override
  Widget build(BuildContext context) {
    const double cardRadius = 25;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
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
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      _title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 50),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(cardRadius),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 25,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(25, 30, 25, 30),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildTextField(
                                controller: _idController,
                                hint: 'Téléphone ou Nom d’utilisateur',
                                icon: Icons.person_outline,
                                keyboardType: TextInputType.text,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Veuillez entrer votre téléphone ou nom d’utilisateur';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                controller: _passController,
                                hint: 'Mot de passe',
                                icon: Icons.lock_outline,
                                obscureText: _obscurePassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: AppColors.mediumGray,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Veuillez entrer votre mot de passe';
                                  }
                                  if (v.length < 6) {
                                    return 'Au moins 6 caractères';
                                  }
                                  return null;
                                },
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: _goToForgotPassword,
                                  child: Text(
                                    'Mot de passe oublié ?',
                                    style: AppTextStyles.bodyText.copyWith(
                                      color: AppColors.primaryPurple,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const SizedBox(height: 35),
                              _buildSubmitButton(),
                              const SizedBox(height: 20),
                              Center(
                                child: TextButton(
                                  onPressed: _goToRegistration,
                                  child: RichText(
                                    text: TextSpan(
                                      text: 'Vous n’avez pas de compte ? ',
                                      style: AppTextStyles.bodyText.copyWith(
                                        color: AppColors.mediumGray,
                                        fontSize: 14,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'Créer un compte',
                                          style:
                                              AppTextStyles.bodyText.copyWith(
                                            color: AppColors.primaryPurple,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        style: AppTextStyles.bodyText.copyWith(fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodyText.copyWith(
            color: AppColors.mediumGray,
            fontSize: 14,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 20, right: 15),
            child: Icon(icon, color: AppColors.mediumGray, size: 20),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 55),
          suffixIcon: suffixIcon != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 15), child: suffixIcon)
              : null,
          suffixIconConstraints: const BoxConstraints(minWidth: 45),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: AppColors.primaryPurple, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: AppColors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: AppColors.red, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        // >>> REPLACE: onPressed of "تسجيل الدخول"
        onPressed: _loading
            ? null
            : () async {
                setState(() => _loading = true);
                final r = await AuthApi().login(
                  id: _idController.text.trim(),
                  password: _passController.text,
                );
                setState(() => _loading = false);

                if (r['ok'] == true) {
                  final json = r['json'] ?? {};
                  final user = (json['user'] ?? {}) as Map;

                  // دور الحساب الذي رجع من الخادم
                  final serverRole = (user['role'] ?? 'client')
                      .toString()
                      .toLowerCase()
                      .trim();

                  // دور البوابة الحالية (واجهة العميل أم العامل؟)
                  final portalRole =
                      (_role == 'prestataire') ? 'worker' : 'client';

                  // ✅ بوابة الدخول: منع دخول العامل من واجهة العميل والعكس
                  if (serverRole != portalRole) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('هذا الحساب غير موجود')),
                    );
                    return; // لا نحفظ توكنات ولا ننتقل
                  }

                  // حفظ التوكنات بعد نجاح البوابة
                  await TokenStorage.save(json['access'], json['refresh']);

                  // التوجيه حسب حالة الـ onboarding
                  final onboardingDone = user['onboarding_completed'] == true;
                  if (serverRole == 'worker' && !onboardingDone) {
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.workerOnboarding,
                      arguments: {'role': 'worker'},
                    );
                  } else {
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.home,
                      arguments: {'role': serverRole},
                    );
                  }
                } else {
                  final err =
                      (r['json']?['detail'] ?? 'بيانات الدخول غير صحيحة')
                          .toString();
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(err)));
                }
              },

        // <<< END REPLACE
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: const Text(
          "Se connecter",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
