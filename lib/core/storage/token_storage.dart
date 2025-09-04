import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _s = FlutterSecureStorage();

  // مفاتيح موحّدة
  static const _kAccess = 'access';
  static const _kRefresh = 'refresh';

  /// حفظ التوكنات
  static Future<void> save(String access, String refresh) async {
    await _s.write(key: _kAccess, value: access);
    await _s.write(key: _kRefresh, value: refresh);
  }

  /// القراءة — الأسماء الجديدة المتوقعة في auth_api.dart
  static Future<String?> readAccess() => _s.read(key: _kAccess);
  static Future<String?> readRefresh() => _s.read(key: _kRefresh);

  /// مرادفات (توافقًا مع الشيفرة القديمة)
  static Future<String?> access() => readAccess();
  static Future<String?> refresh() => readRefresh();

  /// مسح التوكنات فقط (أفضل من deleteAll)
  static Future<void> clear() async {
    await _s.delete(key: _kAccess);
    await _s.delete(key: _kRefresh);
  }
}
