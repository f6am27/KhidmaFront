import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:micro_emploi_app/constants/colors.dart';
import 'package:micro_emploi_app/constants/text_styles.dart';
import 'package:micro_emploi_app/routes/app_routes.dart';

// >>> ADD: imports
import '../../services/auth_api.dart';
import '../../core/storage/token_storage.dart'; // <<< NEW
// <<< END ADD

class OtpVerifyScreen extends StatefulWidget {
  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final int _otpLength = 6;
  late List<TextEditingController> _controllers;
  late List<FocusNode> _nodes;

  Timer? _timer;
  int _secondsRemaining = 30;
  bool get _canResend => _secondsRemaining == 0;

  // >>> ADD: state
  final _codeController = TextEditingController();
  bool _loadingVerify = false;
  bool _loadingResend = false;
  // <<< END ADD

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_otpLength, (_) => TextEditingController());
    _nodes = List.generate(_otpLength, (_) => FocusNode());

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();

    _startTimer();
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (final c in _controllers) c.dispose();
    for (final n in _nodes) n.dispose();
    // >>> ADD: dispose code
    _codeController.dispose();
    // <<< END ADD
    _timer?.cancel();
    super.dispose();
  }

  // ===== Timer =====
  void _startTimer([int seconds = 60]) {
    _secondsRemaining = seconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_secondsRemaining > 0) {
          _seconds_remaining_decrement:
          _secondsRemaining--;
        } else {
          t.cancel();
        }
      });
    });
  }

  // ===== Helpers =====
  void _onChanged(int index, String value) {
    if (value.length == 1) {
      if (index < _otpLength - 1) {
        _nodes[index + 1].requestFocus();
      } else {
        _nodes[index].unfocus();
      }
    }
    if (value.isEmpty && index > 0) {
      _nodes[index - 1].requestFocus();
    }
    setState(() {
      _codeController.text = _controllers.map((c) => c.text).join();
    });
  }

  @override
  Widget build(BuildContext context) {
    const double cardRadius = 25;

    // >>> ADD: read args
    final args = (ModalRoute.of(context)?.settings.arguments as Map?) ?? {};
    final String phone = (args['phone'] ?? '') as String;

    // ✅ استنتاج آمن للتدفّق
    final String flow = (() {
      final f = args['flow'];
      if (f == 'pwd' || f == 'register') return f as String;
      final p = (args['purpose'] ?? '') as String;
      if (p == 'reset_password') return 'pwd';
      return 'register'; // الافتراضي
    })();

    // ✅ قراءة الدور وتطبيع prestataire -> worker
    final String roleRaw =
        ((args['role'] ?? 'client') as String).toLowerCase().trim();
    final String role = (roleRaw == 'prestataire') ? 'worker' : roleRaw;
    // <<< END ADD

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/otp.png',
                    height: 250,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 18),
                const Divider(height: 28),
                Text(
                  'Entrez le code de vérification',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyText.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Nous détectons automatiquement le SMS\n"
                  "envoyé à votre numéro $phone",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyText.copyWith(
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(cardRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(_otpLength, (i) {
                          return _OtpBox(
                            controller: _controllers[i],
                            focusNode: _nodes[i],
                            onChanged: (v) => _onChanged(i, v),
                          );
                        }),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _canResend
                            ? 'Vous pouvez renvoyer le code.'
                            : 'Restant: 00:${_secondsRemaining.toString().padLeft(2, '0')}s',
                        style: AppTextStyles.bodyText.copyWith(
                          color: AppColors.mediumGray,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Center(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        "Vous n’avez pas reçu le code ? ",
                        style: AppTextStyles.bodyText.copyWith(
                          color: AppColors.mediumGray,
                        ),
                      ),
                      GestureDetector(
                        // >>> ADD: resend button onPressed
                        onTap: _loadingResend
                            ? null
                            : () async {
                                if (!_canResend) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'انتظري انتهاء العدّاد قبل إعادة الإرسال')),
                                  );
                                  return;
                                }

                                setState(() => _loadingResend = true);
                                final api = AuthApi();
                                final r = (flow == 'register')
                                    ? await api.resendRegister(
                                        phone: phone, lang: 'ar')
                                    : await api.pwdResend(
                                        phone: phone, lang: 'ar');
                                setState(() => _loadingResend = false);

                                if (r['ok'] == true) {
                                  final json = r['json'] ?? {};
                                  final sec =
                                      (json['resend_after_sec'] as int?) ?? 60;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'تم الإرسال. أعِدي المحاولة بعد $sec ث')),
                                  );
                                  _startTimer(
                                      sec); // ✅ ابدئي العدّاد بما أعاده الخادم
                                } else {
                                  final err = (r['json']?['detail'] ??
                                          'تعذّر إعادة الإرسال')
                                      .toString();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(err)));
                                }
                              },

                        child: Text(
                          'Renvoyer le code',
                          style: AppTextStyles.bodyText.copyWith(
                            color: _canResend
                                ? AppColors.primaryPurple
                                : AppColors.mediumGray.withOpacity(.6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Container(
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
                        color: AppColors.primaryPurple.withOpacity(0.28),
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    // >>> REPLACE: verify button onPressed (إضافة حفظ التوكن فقط + التوجيه)
                    onPressed: _loadingVerify
                        ? null
                        : () async {
                            final code = _codeController.text.trim();
                            if (code.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('أدخلي الرمز')));
                              return;
                            }

                            if (flow == 'register') {
                              setState(() => _loadingVerify = true);
                              final r = await AuthApi()
                                  .verify(phone: phone, code: code);
                              setState(() => _loadingVerify = false);

                              if (r['ok'] == true) {
                                // <<< NEW: حفظ التوكنات من ردّ verify (فقط هذا الإضافة)
                                final json = r['json'] ?? {};
                                final access = json['access']?.toString();
                                final refresh = json['refresh']?.toString();
                                if (access != null && refresh != null) {
                                  await TokenStorage.save(access, refresh);
                                }
                                // >>> END NEW

                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('تم التحقق.')));

                                if (role == 'worker') {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    AppRoutes.workerOnboarding,
                                    arguments: {'role': 'worker'},
                                  );
                                } else {
                                  Navigator.pushReplacementNamed(
                                      context, AppRoutes.login);
                                }
                              } else {
                                final err =
                                    (r['json']?['detail'] ?? 'الرمز غير صحيح')
                                        .toString();
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(content: Text(err)));
                              }
                            } else {
                              // استرجاع كلمة المرور
                              debugPrint(
                                  'OTP flow=pwd → navigate to reset with phone=$phone, code=${_codeController.text.trim()}');
                              Navigator.pushNamed(
                                context,
                                AppRoutes.resetPassword,
                                arguments: {
                                  'phone': phone,
                                  'code': code,
                                  'role': role
                                }, // <<< role
                              );
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
                      'Vérifier et continuer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: AppColors.primaryPurple, width: 1.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      'Annuler',
                      style: AppTextStyles.bodyText.copyWith(
                        color: AppColors.primaryPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _OtpBox({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final baseDecoration = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE9E9F1), width: 1.2),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );

    return Container(
      width: 46,
      height: 56,
      alignment: Alignment.center,
      decoration: baseDecoration,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
        onChanged: onChanged,
        decoration: const InputDecoration(
          border: InputBorder.none,
          isCollapsed: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
