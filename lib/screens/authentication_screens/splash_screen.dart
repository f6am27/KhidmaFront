import 'package:flutter/material.dart';
import 'dart:async';
import 'package:lottie/lottie.dart';
import '../../constants/colors.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // أنيميشنات اللوجو (اختياري جمالياً)
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();

    // نجهّز الانتقال: ننتظر 3 ثواني + تحميل مسبق لأصول Welcome
    final splashDelay = Future.delayed(const Duration(seconds: 3));
    final warmUp = _precacheWelcomeAssets();

    // ننتظر الاثنين معاً لضمان عدم التعليق عند فتح Welcome
    Future.wait([splashDelay, warmUp]).then((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) =>
              WelcomeScreen(), // بدون const إن لم تكن const
          transitionDuration:
              Duration.zero, // انتقال فوري → لا تفتيح لون الخلفية
          reverseTransitionDuration: Duration.zero,
        ),
      );
    });
  }

  /// تحميل مسبق لأصول تظهر في WelcomeScreen
  Future<void> _precacheWelcomeAssets() async {
    // مهم: ننتظر أول فريم لامتلاك context صالح للـ precache
    await Future<void>.delayed(Duration.zero);

    final futures = <Future<void>>[];

    // اللوجو المستخدم في WelcomeScreen (صحّحي المسار هناك أيضاً)
    futures
        .add(precacheImage(const AssetImage('assets/images/kk.png'), context));

    // لو لديكِ صور إضافية في WelcomeScreen، أضيفيها هنا بنفس طريقتها:
    // futures.add(precacheImage(const AssetImage('assets/images/welcome_bg.png'), context));
    // futures.add(precacheImage(const AssetImage('assets/images/hero.png'), context));

    await Future.wait(futures);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // لون ثابت لا يتغير (لا تأثيرات مزج على الانتقال)
      backgroundColor: AppColors.primaryPurple,
      body: Stack(
        children: [
          // اللوجو في المنتصف مع أنيميشن
          Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Image.asset(
                      'assets/images/kk.png',
                      width: 250,
                      height: 250,
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),
          ),

          // لودر Lottie أبيض أسفل الشاشة
          Positioned(
            left: 0,
            right: 0,
            bottom: 28,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: ColorFiltered(
                  // يلوّن اللوتي بالأبيض ليظهر واضحاً على البنفسجي
                  colorFilter:
                      const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  child: Lottie.asset(
                    'assets/animations/loader.json',
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                    repeat: true,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
