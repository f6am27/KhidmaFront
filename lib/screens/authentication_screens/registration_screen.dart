import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_api.dart';

class RegistrationScreen extends StatefulWidget {
  // اختياري لدعم التمرير عبر arguments أو عبر الـconstructor
  final String? role; // 'client' | 'worker' | 'prestataire'
  const RegistrationScreen({Key? key, this.role}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;

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
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // قراءة الدور من الـarguments أو من الـconstructor وتطبيع "prestataire" إلى "worker"
    final args = (ModalRoute.of(context)?.settings.arguments as Map?) ?? {};
    final String roleRaw = ((args['role'] ?? widget.role ?? 'client') as String)
        .toLowerCase()
        .trim();
    final String role = (roleRaw == 'prestataire') ? 'worker' : roleRaw;

    const double cardRadius = 25;
    String title = (role == 'client')
        ? 'Inscription du client'
        : 'Inscription du prestataire';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // زخارف أسفل الشاشة
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
                      title,
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
                                controller: _nameController,
                                hint: 'Nom complet',
                                icon: Icons.person_outline,
                                validator: (v) => (v == null || v.isEmpty)
                                    ? 'Veuillez entrer votre nom'
                                    : null,
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                controller: _phoneController,
                                hint: 'Mobile',
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                validator: (v) => (v == null || v.isEmpty)
                                    ? 'Veuillez entrer votre numéro'
                                    : null,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                controller: _passwordController,
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
                                  onPressed: () => setState(() =>
                                      _obscurePassword = !_obscurePassword),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Veuillez entrer un mot de passe';
                                  }
                                  if (v.length < 6) {
                                    return 'Au moins 6 caractères';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 35),
                              _buildSubmitButton(role),
                              const SizedBox(height: 20),
                              Center(
                                child: TextButton(
                                  onPressed: () => Navigator.pushNamed(
                                    context,
                                    AppRoutes.login,
                                    arguments: {'role': role},
                                  ),
                                  child: RichText(
                                    text: TextSpan(
                                      text: 'Vous avez déjà un compte ? ',
                                      style: AppTextStyles.bodyText.copyWith(
                                        color: AppColors.mediumGray,
                                        fontSize: 14,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'Se connecter',
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
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppColors.white, width: 1),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        inputFormatters: inputFormatters,
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

  Widget _buildSubmitButton(String role) {
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
// في _buildSubmitButton method، استبدال onPressed:

        onPressed: _loading
            ? null
            : () async {
                if (!_formKey.currentState!.validate()) return;

                setState(() => _loading = true);

                try {
                  final response = await AuthApi().register(
                    username: _nameController.text.trim(),
                    phone: _phoneController.text.trim(),
                    password: _passwordController.text,
                    lang: 'ar',
                    role: role,
                  );

                  if (response['ok'] == true) {
                    // نجح التسجيل، الانتقال لصفحة التحقق
                    if (!mounted) return;
                    Navigator.pushNamed(
                      context,
                      AppRoutes.otpVerify,
                      arguments: {
                        'phone': _phoneController.text.trim(),
                        'flow': 'register',
                        'role': role,
                      },
                    );
                  } else {
                    // فشل التسجيل، عرض رسالة الخطأ
                    final json = response['json'] ?? {};
                    String errorMessage = 'حدث خطأ أثناء التسجيل';

                    // معالجة أنواع مختلفة من الأخطاء
                    if (json['detail'] != null) {
                      if (json['detail'] is String) {
                        errorMessage = json['detail'];
                      } else if (json['detail'] is Map) {
                        final details = json['detail'] as Map;
                        // معالجة أخطاء الحقول المختلفة
                        if (details['phone'] != null) {
                          errorMessage = details['phone'][0];
                        } else if (details['username'] != null) {
                          errorMessage = details['username'][0];
                        } else if (details['password'] != null) {
                          errorMessage = details['password'][0];
                        } else if (details['non_field_errors'] != null) {
                          errorMessage = details['non_field_errors'][0];
                        }
                      }
                    } else if (json['code'] != null) {
                      switch (json['code']) {
                        case 'user_exists':
                          errorMessage = 'هذا الرقم مسجل مسبقاً';
                          break;
                        case 'invalid_phone':
                          errorMessage = 'رقم الهاتف غير صالح';
                          break;
                        default:
                          errorMessage = json['code'];
                      }
                    }

                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(errorMessage)),
                    );
                  }
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('حدث خطأ في الاتصال: ${e.toString()}')),
                  );
                } finally {
                  if (mounted) setState(() => _loading = false);
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: _loading
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.white),
              )
            : const Text(
                "S'inscrire",
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
