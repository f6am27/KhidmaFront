import 'dart:io';

class ApiConfig {
  static String baseUrl() {
    // محاكي أندرويد
    if (Platform.isAndroid) return 'http://10.0.2.2:8000/api/auth';
    // iOS Simulator / Web / سطح المكتب
    return 'http://127.0.0.1:8000/api/auth';
  }
}
