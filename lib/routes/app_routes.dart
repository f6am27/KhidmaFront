class AppRoutes {
  static const String splash = '/splash';
  static const String welcome = '/welcome';

  // اختيار نوع التسجيل
  static const String registrationType = '/registration-type';

  // شاشة الدخول العامة
  static const String login = '/login';

  // شاشتا التسجيل
  static const String clientRegistration = '/client-registration';
  static const String workerRegistration = '/worker-registration';

  // (اختياري) الصفحة الموحدة بعد الدخول
  static const String home = '/home';
  static const String otpVerify = '/otp-verify';

  static const String workerOnboarding = '/worker-onboarding';
  static const String registration = '/registration';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  // --------------------------Part2----------------------
  // Client Bottom Tabs (للاستخدام لاحقًا)
  static const String clientHomeTab = '/client/home';
  static const String clientFavoritesTab = '/client/favorites';
  static const String clientAddTaskTab = '/client/add-task';
  static const String clientMessagesTab = '/client/messages';
  static const String clientProfileTab = '/client/profile';
}
