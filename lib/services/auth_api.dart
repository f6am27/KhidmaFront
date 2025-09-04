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
    bool withAuth = false, // <<< NEW
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

    final res = await _client.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    Map<String, dynamic> json = {};
    if (res.body.isNotEmpty) {
      try {
        json = jsonDecode(res.body) as Map<String, dynamic>;
      } catch (_) {}
    }
    final ok = res.statusCode >= 200 && res.statusCode < 300;
    return {'ok': ok, 'status': res.statusCode, 'json': json};
  }

  // — التسجيل — //
  Future<Map<String, dynamic>> register({
    required String username,
    required String phone,
    required String password,
    String lang = 'ar',
    String role = 'client',
  }) =>
      _post('/register', {
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
      _post('/resend', {'phone': phone, 'lang': lang});

  Future<Map<String, dynamic>> verify({
    required String phone,
    required String code,
  }) =>
      _post('/verify', {'phone': phone, 'code': code});

  // — الدخول — //
  Future<Map<String, dynamic>> login({
    required String id,
    required String password,
  }) =>
      _post('/login', {'phone_or_username': id, 'password': password});

  // — استرجاع كلمة المرور — //
  Future<Map<String, dynamic>> pwdReset({
    required String phone,
    String lang = 'ar',
  }) =>
      _post('/pwd/reset', {'phone': phone, 'lang': lang});

  Future<Map<String, dynamic>> pwdResend({
    required String phone,
    String lang = 'ar',
  }) =>
      _post('/pwd/resend', {'phone': phone, 'lang': lang});

  Future<Map<String, dynamic>> pwdConfirm({
    required String phone,
    required String code,
    required String newPassword,
    required String newPasswordConfirm,
  }) =>
      _post('/pwd/confirm', {
        'phone': phone,
        'code': code,
        'new_password': newPassword,
        'new_password_confirm': newPasswordConfirm,
      });

  // — إتمام Onboarding للعامل — //
  Future<Map<String, dynamic>> completeWorkerOnboarding() =>
      _post('/onboarding/complete', {}, withAuth: true); // <<< ONLY here
}
