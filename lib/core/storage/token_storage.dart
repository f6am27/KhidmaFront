import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  // للتوكنات الحساسة نستخدم Secure Storage
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: true,
    ),
  );

  // باقي الكود يبقى كما هو...

  // للبيانات غير الحساسة نستخدم SharedPreferences (أسرع)
  static const String _accessKey = 'access_token';
  static const String _refreshKey = 'refresh_token';
  static const String _userKey = 'user_data';
  static const String _roleKey = 'user_role';

  /// حفظ JWT tokens بأمان
  static Future<void> save(String accessToken, String refreshToken) async {
    await Future.wait([
      _secureStorage.write(key: _accessKey, value: accessToken),
      _secureStorage.write(key: _refreshKey, value: refreshToken),
    ]);
  }

  /// قراءة Access Token
  static Future<String?> readAccess() async {
    try {
      return await _secureStorage.read(key: _accessKey);
    } catch (e) {
      // في حالة خطأ في Secure Storage، نحذف البيانات ونرجع null
      await _secureStorage.delete(key: _accessKey);
      return null;
    }
  }

  /// قراءة Refresh Token
  static Future<String?> readRefresh() async {
    try {
      return await _secureStorage.read(key: _refreshKey);
    } catch (e) {
      await _secureStorage.delete(key: _refreshKey);
      return null;
    }
  }

  /// حفظ بيانات المستخدم (غير حساسة)
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(userData));
  }

  /// قراءة بيانات المستخدم
  static Future<Map<String, dynamic>?> readUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataStr = prefs.getString(_userKey);
      if (userDataStr == null) return null;

      return jsonDecode(userDataStr) as Map<String, dynamic>;
    } catch (e) {
      // في حالة خطأ، نحذف البيانات التالفة
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      return null;
    }
  }

  /// حفظ نوع المستخدم (role)
  static Future<void> saveUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, role);
  }

  /// قراءة نوع المستخدم (role)
  static Future<String?> readUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_roleKey);
    } catch (e) {
      return null;
    }
  }

  /// مسح جميع البيانات المحفوظة (تسجيل الخروج)
  static Future<void> clear() async {
    await Future.wait([
      _secureStorage.delete(key: _accessKey),
      _secureStorage.delete(key: _refreshKey),
      SharedPreferences.getInstance().then((prefs) => prefs.remove(_userKey)),
      SharedPreferences.getInstance()
          .then((prefs) => prefs.remove(_roleKey)), // ✅ أضف هذا
    ]);
  }

  /// مسح شامل (في حالة وجود مشاكل)
  static Future<void> clearAll() async {
    await Future.wait([
      _secureStorage.deleteAll(),
      SharedPreferences.getInstance().then((prefs) => prefs.clear()),
    ]);
  }

  /// فحص ما إذا كان المستخدم مسجل دخول
  static Future<bool> isLoggedIn() async {
    final accessToken = await readAccess();
    return accessToken != null && accessToken.isNotEmpty;
  }

  /// فحص صحة البيانات المحفوظة
  static Future<bool> validateStoredData() async {
    try {
      final accessToken = await readAccess();
      final userData = await readUserData();

      return accessToken != null &&
          accessToken.isNotEmpty &&
          userData != null &&
          userData.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// تنظيف البيانات في حالة الخطأ
  static Future<void> handleStorageError() async {
    try {
      await clearAll();
    } catch (e) {
      // إذا فشل حتى المسح، نتجاهل الخطأ
    }
  }
}
