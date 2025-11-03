import 'dart:io';

class ApiConfig {
  // ========================================
  // 🔧 الإعدادات - غيّر IP كمبيوترك هنا فقط
  // ========================================
  static const String _realDeviceIp = 'http://172.20.10.3:8000';
// ← IP كمبيوترك على WiFi
  static const String _emulatorIp = 'http://10.0.2.2:8000'; // للمحاكي Android
  static const String _localhostIp = 'http://127.0.0.1:8000'; // لـ iOS/Web

  // ========================================
  // 🤖 الكشف التلقائي عن نوع الجهاز
  // ========================================
  static bool get _isPhysicalDevice {
    if (!Platform.isAndroid) return false;

    // طرق الكشف:
    // 1. التحقق من MODEL الجهاز
    final model = Platform.environment['ANDROID_MODEL'] ?? '';
    final product = Platform.environment['ANDROID_PRODUCT'] ?? '';

    // المحاكي عادة يحتوي على هذه الكلمات
    final emulatorKeywords = [
      'sdk',
      'emulator',
      'gphone',
      'goldfish',
      'ranchu',
      'vbox'
    ];

    final deviceInfo = '$model $product'.toLowerCase();

    for (var keyword in emulatorKeywords) {
      if (deviceInfo.contains(keyword)) {
        print('🤖 محاكي مكتشف: $deviceInfo');
        return false; // محاكي
      }
    }

    print('📱 جهاز حقيقي مكتشف: $deviceInfo');
    return true; // جهاز حقيقي
  }

  // ========================================
  // 🌐 الحصول على Base URL الصحيح
  // ========================================
  static String baseUrl() {
    String baseIp;

    if (Platform.isAndroid) {
      baseIp = _isPhysicalDevice ? _realDeviceIp : _emulatorIp;
      print(
          '📡 استخدام Base URL: $baseIp (${_isPhysicalDevice ? "جهاز حقيقي" : "محاكي"})');
    } else if (Platform.isIOS) {
      baseIp = _localhostIp;
      print('📡 استخدام Base URL: $baseIp (iOS)');
    } else {
      baseIp = _localhostIp;
      print('📡 استخدام Base URL: $baseIp (Web/Desktop)');
    }

    return '$baseIp/api/users';
  }

  // ========================================
  // 🖼️ الحصول على Media URL الصحيح
  // ========================================
  static String getFullMediaUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) {
      return '';
    }

    // إذا كان رابط كامل، أرجعه كما هو
    if (relativePath.startsWith('http')) {
      return relativePath;
    }

    String baseMedia;

    if (Platform.isAndroid) {
      baseMedia = _isPhysicalDevice ? _realDeviceIp : _emulatorIp;
    } else if (Platform.isIOS) {
      baseMedia = _localhostIp;
    } else {
      baseMedia = _localhostIp;
    }

    // تأكد من أن المسار يبدأ بـ /
    if (!relativePath.startsWith('/')) {
      relativePath = '/$relativePath';
    }

    return '$baseMedia$relativePath';
  }

  // ========================================
  // 🔍 وظائف مساعدة للـ debugging
  // ========================================

  /// طباعة معلومات الاتصال الحالية
  static void printConnectionInfo() {
    print('=================================');
    print('📱 نوع الجهاز: ${_isPhysicalDevice ? "جهاز حقيقي" : "محاكي"}');
    print('🌐 Base URL: ${baseUrl()}');
    print('🖼️ Media Base: ${_isPhysicalDevice ? _realDeviceIp : _emulatorIp}');
    print('=================================');
  }

  /// للتبديل اليدوي في حالات الاختبار
  static String getUrlForTesting({bool forceRealDevice = false}) {
    if (forceRealDevice) {
      return '$_realDeviceIp/api/users';
    }
    return baseUrl();
  }
}
