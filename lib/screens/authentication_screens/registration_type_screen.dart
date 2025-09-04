import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import 'registration_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../routes/app_routes.dart';

/// مؤشر صفحات خفيف بدون حزم خارجية
class DotsIndicator extends StatelessWidget {
  final int count;
  final int activeIndex;
  final Color activeColor;
  final Color inactiveColor;

  const DotsIndicator({
    super.key,
    required this.count,
    required this.activeIndex,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final bool isActive = i == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: isActive ? 22 : 8, // كبسولة للنقطة النشطة
          decoration: BoxDecoration(
            color: isActive ? activeColor : inactiveColor.withOpacity(0.35),
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }
}

class RegistrationTypeScreen extends StatefulWidget {
  @override
  _RegistrationTypeScreenState createState() => _RegistrationTypeScreenState();
}

class _RegistrationTypeScreenState extends State<RegistrationTypeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    // تأخير بسيط قبل بدء الأنيميشن
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _selectRole(String role) {
    // نُطَبِّع "prestataire" إلى "worker" لتوافق الباك
    final normalized = (role.toLowerCase().trim() == 'prestataire')
        ? 'worker'
        : role.toLowerCase().trim();

    Navigator.pushNamed(
      context,
      AppRoutes.registration,
      arguments: {'role': normalized},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  // زر الرجوع في الأعلى
                  Transform.translate(
                    offset: Offset(-_slideAnimation.value, 0),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back_ios,
                              color: AppColors.textPrimary),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 1),

                  // الصورة في المنتصف
                  Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Transform.scale(
                        scale: 1.3, // تكبير بنسبة 30%
                        child: Image.asset(
                          'assets/images/welc.png',
                          width: 280,
                          height: 250,
                          fit:
                              BoxFit.cover, // أو BoxFit.fill لملء المساحة كاملة
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // مؤشر الصفحات (آخر صفحة قبل التسجيل)
                  Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: DotsIndicator(
                        count: 3,
                        activeIndex: 2, // هذه الصفحة هي الأخيرة
                        activeColor: AppColors.gradientStart,
                        inactiveColor: AppColors.mediumGray,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // النص الترحيبي
                  Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        "Hello!",
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // السؤال
                  Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        "Que recherchez-vous ?",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: AppColors.mediumGray,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 1),

                  // الأزرار في الأسفل
                  Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          // الزر الأول
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: () => _selectRole("client"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.gradientStart,
                                foregroundColor: Colors.white,
                                elevation: 3,
                                shadowColor:
                                    AppColors.gradientStart.withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(27),
                                ),
                              ),
                              child: const Text(
                                "Recherche d'un prestataire",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // الزر الثاني
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: OutlinedButton(
                              onPressed: () => _selectRole("worker"),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                side: BorderSide(
                                  color: AppColors.gradientStart,
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(27),
                                ),
                              ),
                              child: Text(
                                "Recherche d'un travail",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.gradientStart,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
