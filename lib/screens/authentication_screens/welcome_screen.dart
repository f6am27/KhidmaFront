import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import '../../constants/colors.dart';
// حذفت: import '../widgets/custom_button.dart';
import 'registration_type_screen.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _floatingController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _slideAnimation = Tween<double>(begin: 60.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuart),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.25, 1.0, curve: Curves.easeIn),
      ),
    );

    _floatingAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  void _navigateToRegistration() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            RegistrationTypeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Widget _buildDecorativeCircle({
    required double size,
    required Color color,
    double? top,
    double? left,
    double? right,
    double? bottom,
    bool animate = false,
  }) {
    Widget circle = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );

    if (animate) {
      circle = AnimatedBuilder(
        animation: _floatingAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatingAnimation.value),
            child: child,
          );
        },
        child: circle,
      );
    }

    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: circle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double logoSize = math.min(size.width * 0.75, 280.0);

    // 👇 تحكّم سريع في تقوّس وارتفاع الزر
    const double kButtonRadius =
        40; // ← عدّليه كما تشائين (مثال: 999 لحبّة دواء)
    const double kButtonHeight = 55;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Stack(
              children: [
                // العناصر الديكورية في الخلفية
                _buildDecorativeCircle(
                  size: 80,
                  color: AppColors.primaryPurple.withOpacity(0.08),
                  top: 60,
                  left: -20,
                  animate: true,
                ),
                _buildDecorativeCircle(
                  size: 120,
                  color: AppColors.primaryPurple.withOpacity(0.05),
                  top: 40,
                  right: -40,
                ),
                _buildDecorativeCircle(
                  size: 60,
                  color: AppColors.primaryPurple.withOpacity(0.1),
                  top: 200,
                  right: 20,
                  animate: true,
                ),
                _buildDecorativeCircle(
                  size: 40,
                  color: const Color(0xFF6366F1).withOpacity(0.12),
                  top: 320,
                  left: 30,
                ),
                _buildDecorativeCircle(
                  size: 100,
                  color: AppColors.primaryPurple.withOpacity(0.06),
                  bottom: 120,
                  left: -30,
                ),
                _buildDecorativeCircle(
                  size: 70,
                  color: AppColors.primaryPurple.withOpacity(0.09),
                  bottom: 80,
                  right: -10,
                  animate: true,
                ),
                _buildDecorativeCircle(
                  size: 35,
                  color: AppColors.primaryPurple.withOpacity(0.15),
                  bottom: 200,
                  left: 50,
                ),

                // المحتوى الرئيسي
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 44, 22, 0),
                  child: Column(
                    children: [
                      // ===== أعلى: اللوجو + الجملة تحته مباشرة =====
                      Expanded(
                        flex: 5,
                        child: Transform.translate(
                          offset: Offset(0, _slideAnimation.value),
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Align(
                              alignment: const Alignment(0, 0.15),
                              child: Stack(
                                alignment: Alignment.center,
                                clipBehavior: Clip.none,
                                children: [
                                  // اللوجو
                                  Image.asset(
                                    'assets/images/kh.png',
                                    width: logoSize,
                                    height: logoSize,
                                    fit: BoxFit.contain,
                                  ),
                                  // العبارة موضوعة أسفل اللوجو مباشرة
                                  Positioned(
                                    bottom: 30,
                                    child: Text(
                                      'CLOSEST WORKER, FASTEST SERVICE, ANYTIME',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontSize: 9.0,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 1.5,
                                        height: 1.0,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ===== أسفل: العنوان، الوصف، والزر =====
                      Expanded(
                        flex: 4,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Bienvenue sur Khidma',
                                    maxLines: 1,
                                    softWrap: false,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      height: 1.18,
                                      color:
                                          const Color.fromARGB(192, 26, 23, 23),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 14),
                                child: Text(
                                  'Avec nous, votre service est plus proche que vous ne l\'imaginez.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14.5,
                                    height: 1.55,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black.withOpacity(.62),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 22),

                              // ===== الزر الجديد القابل للتحكّم في التقوّس =====
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: _ActionButton(
                                  text: 'Commencer',
                                  onPressed: _navigateToRegistration,
                                  radius:
                                      kButtonRadius, // 👈 غيّري هذا الرقم بحرّية
                                  height: kButtonHeight,
                                  fullWidth: true,
                                  // gradient: true, // فعّليه لو حابة تدرّج
                                ),
                              ),

                              const SizedBox(height: 26),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// زر داخلي مرن — يدعم التقوّس، الارتفاع، العرض الكامل، واختيار التدرّج.
class _ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double radius;
  final double height;
  final bool fullWidth;
  final bool gradient;

  const _ActionButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.radius = 16,
    this.height = 55,
    this.fullWidth = true,
    this.gradient = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonChild = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor:
            gradient ? Colors.transparent : AppColors.primaryPurple,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius), // 👈 التقوّس هنا
        ),
        minimumSize: Size(fullWidth ? double.infinity : 0, height),
        padding: const EdgeInsets.symmetric(horizontal: 18),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: .2,
        ),
      ),
    );

    if (!gradient) return buttonChild;

    // حال أردتِ تدرّجًا لونيًا جميلًا
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryPurple.withOpacity(.95),
            AppColors.primaryPurple,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: buttonChild,
    );
  }
}
