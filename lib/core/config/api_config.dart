import 'dart:io';

class ApiConfig {
  static String baseUrl() {
    // محاكي أندرويد
    if (Platform.isAndroid) return 'http://10.0.2.2:8000/api/users';
    // iOS Simulator / Web / سطح المكتب
    return 'http://127.0.0.1:8000/api/users';
  }

  static String getFullMediaUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) {
      return '';
    }

    if (relativePath.startsWith('http')) {
      return relativePath;
    }

    String baseMedia = Platform.isAndroid
        ? 'http://10.0.2.2:8000'
        : 'http://192.168.1.11:8000';

    return '$baseMedia$relativePath';
  }
}
