import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:micro_emploi_app/constants/colors.dart';
// import 'package:micro_emploi_app/constants/text_styles.dart';
import 'package:micro_emploi_app/routes/app_routes.dart';
import '../../services/auth_api.dart'; // >>> ADD: imports

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController(); // >>> ADD: state
  bool _loading = false; // >>> ADD: state
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String get _role {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final r = (args?['role'] as String?)?.toLowerCase().trim();
    if (r == 'worker' || r == 'prestataire') return 'prestataire';
    return 'client';
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _phoneController.dispose(); // >>> ADD: dispose
    super.dispose();
  }

// في _sendOtp method، التحديث الكامل:

  void _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = '+222${_phoneController.text.trim()}';

    setState(() => _loading = true);

    try {
      final r = await AuthApi().pwdReset(phone: phone, lang: 'ar');

      if (r['ok'] == true) {
        // نجح إرسال OTP
        Navigator.pushNamed(
          context,
          AppRoutes.otpVerify,
          arguments: {
            'flow': 'pwd',
            'phone': phone,
            'purpose': 'reset_password',
            'role': _role,
          },
        );
      } else {
        // فشل إرسال OTP
        final json = r['json'] ?? {};
        String errorMessage = 'تعذّر إرسال الرمز';

        if (json['detail'] != null) {
          if (json['detail'] is String) {
            errorMessage = json['detail'];
          } else if (json['detail'] is Map) {
            final details = json['detail'] as Map;
            if (details['phone'] != null) {
              errorMessage = details['phone'][0];
            } else if (details['non_field_errors'] != null) {
              errorMessage = details['non_field_errors'][0];
            }
          }
        } else if (json['code'] != null) {
          switch (json['code']) {
            case 'user_not_found':
              errorMessage = 'هذا الرقم غير مسجل';
              break;
            case 'invalid_phone':
              errorMessage = 'رقم الهاتف غير صالح';
              break;
            case 'rate_limited':
              errorMessage = 'انتظر قليلاً قبل المحاولة مرة أخرى';
              break;
            default:
              errorMessage = json['code'];
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ في الاتصال: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // الزخارف أسفل الشاشة
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
                    // Header with close button and title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: AppColors.textPrimary,
                            size: 24,
                          ),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 24),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Title
                    Text(
                      'Mot de passe oublié',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Subtitle
                    Text(
                      'Veuillez entrer votre numéro de téléphone ci-dessous, nous vous enverrons un code pour récupérer votre compte.',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Phone input field
                    Form(
                      key: _formKey,
                      child: _buildPhoneField(),
                    ),
                    const SizedBox(height: 30),

                    // Next button
                    _buildPrimaryButton(
                        label: _loading ? 'Envoi...' : 'Suivant',
                        onTap: _sendOtp),
                    const SizedBox(height: 30),

                    // Sign in link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Je me souviens de mon mot de passe ',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text(
                            'Se connecter',
                            style: TextStyle(
                              color: AppColors.primaryPurple,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildPhoneField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Row(
        children: [
          // Country flag and code
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: SvgPicture.asset(
                    'assets/flags/mr.svg',
                    width: 24,
                    height: 16,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '+222',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 24,
            color: Colors.grey[300],
          ),
          // Phone number input
          Expanded(
            child: TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) => (v == null || v.isEmpty)
                  ? 'Veuillez entrer votre numéro'
                  : null,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              decoration: const InputDecoration(
                hintText: '32333233',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(
      {required String label, required VoidCallback onTap}) {
    return Container(
      height: 55,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          label,
          style: const TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
