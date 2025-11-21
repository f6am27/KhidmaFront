import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:moosyl/moosyl.dart'; // ✅
import 'package:flutter_localizations/flutter_localizations.dart'; // ✅

// الثيم والألوان
import 'core/theme/theme_provider.dart';
import 'core/theme/app_themes.dart';

// استيراد Firebase Service
import 'services/firebase_service.dart';

// الشاشات
import 'screens/authentication_screens/splash_screen.dart';
import 'screens/authentication_screens/welcome_screen.dart';
import 'screens/authentication_screens/registration_type_screen.dart';
import 'screens/authentication_screens/login_screen.dart';
import 'screens/home_router.dart';
import 'screens/authentication_screens/otp_verify_screen.dart';
import 'screens/authentication_screens/worker_onboarding_screen.dart';
import 'screens/authentication_screens/forgot_password_screen.dart';
import 'screens/authentication_screens/reset_password_screen.dart';
import 'screens/authentication_screens/registration_screen.dart';

// الويدجتس والطرق
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ← تهيئة Firebase
  try {
    await Firebase.initializeApp();
    print('✅ Firebase initialized successfully');

    // ← تهيئة Firebase Messaging Service
    await FirebaseService.initialize();
    print('✅ Firebase Messaging initialized successfully');
  } catch (e) {
    print('❌ Firebase initialization error: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: MicroEmploiApp(),
    ),
  );
}

class MicroEmploiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Micro Emploi - Partial Work Platform',

          // استخدام الثيمات الجديدة
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: themeProvider.themeMode,

          // ✅ إضافة Localization Delegates
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          // ✅ اللغات المدعومة
          supportedLocales: [
            Locale('en', ''), // English
            Locale('fr', ''), // French
            Locale('ar', ''), // Arabic
          ],

          // البداية والطرق
          initialRoute: AppRoutes.splash,
          routes: {
            // الشاشات الأساسية
            AppRoutes.splash: (context) => SplashScreen(),
            AppRoutes.welcome: (context) => WelcomeScreen(),
            AppRoutes.registrationType: (context) => RegistrationTypeScreen(),

            // الدخول العام
            AppRoutes.login: (context) => LoginScreen(),

            // التسجيل والتحقق
            AppRoutes.otpVerify: (context) => OtpVerifyScreen(),
            AppRoutes.workerOnboarding: (context) => WorkerOnboardingScreen(),
            AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),
            AppRoutes.resetPassword: (_) => const ResetPasswordScreen(),

            // راوتر الصفحة الرئيسية
            AppRoutes.home: (context) => HomeRouter(),

            // تسجيل موحد حسب الدور
            AppRoutes.registration: (context) {
              final args = ModalRoute.of(context)!.settings.arguments
                  as Map<dynamic, dynamic>?;
              final role = (args?['role'] as String?) ?? 'client';
              return RegistrationScreen(role: role);
            },
          },

          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
