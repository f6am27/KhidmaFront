import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';
import '../core/storage/token_storage.dart';

class AuthApi {
  final String _base = ApiConfig.baseUrl();
  final http.Client _client = http.Client();

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body, {
    bool withAuth = false,
  }) async {
    final uri = Uri.parse('$_base$path');

    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (withAuth) {
      final access = await TokenStorage.readAccess();
      if (access != null && access.isNotEmpty) {
        headers['Authorization'] = 'Bearer $access';
      }
    }

    try {
      final res = await _client.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );

      Map<String, dynamic> json = {};
      if (res.body.isNotEmpty) {
        try {
          json = jsonDecode(res.body) as Map<String, dynamic>;
        } catch (_) {
          json = {'detail': 'Invalid response format'};
        }
      }

      final ok = res.statusCode >= 200 && res.statusCode < 300;
      return {'ok': ok, 'status': res.statusCode, 'json': json};
    } catch (e) {
      return {
        'ok': false,
        'status': 0,
        'json': {'detail': 'Network error: ${e.toString()}'}
      };
    }
  }

  // — التسجيل — //
  Future<Map<String, dynamic>> register({
    required String username,
    required String phone,
    required String password,
    String lang = 'ar',
    String role = 'client',
  }) =>
      _post('/register/', {
        'username': username,
        'phone': phone,
        'password': password,
        'lang': lang,
        'role': role,
      });

  Future<Map<String, dynamic>> resendRegister({
    required String phone,
    String lang = 'ar',
  }) =>
      _post('/resend/', {'phone': phone, 'lang': lang});

  Future<Map<String, dynamic>> verify({
    required String phone,
    required String code,
  }) =>
      _post('/verify/', {'phone': phone, 'code': code});

  // — الدخول — //
  Future<Map<String, dynamic>> login({
    required String id,
    required String password,
  }) =>
      _post('/login/', {'phone_or_username': id, 'password': password});

  // — استرجاع كلمة المرور — //
  Future<Map<String, dynamic>> pwdReset({
    required String phone,
    String lang = 'ar',
  }) =>
      _post('/password/reset/', {'phone': phone, 'lang': lang});

  Future<Map<String, dynamic>> pwdResend({
    required String phone,
    String lang = 'ar',
  }) =>
      _post('/password/resend/', {'phone': phone, 'lang': lang});

  Future<Map<String, dynamic>> pwdConfirm({
    required String phone,
    required String code,
    required String newPassword,
    required String newPasswordConfirm,
  }) =>
      _post('/password/confirm/', {
        'phone': phone,
        'code': code,
        'new_password': newPassword,
        'new_password_confirm': newPasswordConfirm,
      });

  // — إتمام Onboarding للعامل — //
  Future<Map<String, dynamic>> completeWorkerOnboarding() =>
      _post('/onboarding/complete/', {}, withAuth: true);

  // — ملف المستخدم — //
  Future<Map<String, dynamic>> getUserProfile() async {
    final uri = Uri.parse('$_base/profile/');
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    final access = await TokenStorage.readAccess();
    if (access != null && access.isNotEmpty) {
      headers['Authorization'] = 'Bearer $access';
    }

    try {
      final res = await _client.get(uri, headers: headers);

      Map<String, dynamic> json = {};
      if (res.body.isNotEmpty) {
        try {
          json = jsonDecode(res.body) as Map<String, dynamic>;
        } catch (_) {
          json = {'detail': 'Invalid response format'};
        }
      }

      final ok = res.statusCode >= 200 && res.statusCode < 300;
      return {'ok': ok, 'status': res.statusCode, 'json': json};
    } catch (e) {
      return {
        'ok': false,
        'status': 0,
        'json': {'detail': 'Network error: ${e.toString()}'}
      };
    }
  }

  // — تغيير كلمة المرور — //
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirm,
  }) =>
      _post(
        '/change-password/',
        {
          'old_password': oldPassword,
          'new_password': newPassword,
          'new_password_confirm': newPasswordConfirm,
        },
        withAuth: true,
      );

  // — تسجيل الخروج — //
  Future<Map<String, dynamic>> logout() =>
      _post('/logout/', {}, withAuth: true);
}
