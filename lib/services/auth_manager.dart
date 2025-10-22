// lib/services/auth_manager.dart
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';
import '../core/storage/token_storage.dart';
import '../services/location_service.dart';

class AuthManager {
  static final AuthManager _instance = AuthManager._internal();
  factory AuthManager() => _instance;
  AuthManager._internal();

  static final http.Client _client = http.Client();
  static bool _isRefreshing = false;
  static final List<Completer<String?>> _waitingRequests = [];

  /// Get valid access token with automatic refresh
  static Future<String?> getValidAccessToken() async {
    try {
      final accessToken = await TokenStorage.readAccess();

      if (accessToken == null || accessToken.isEmpty) {
        return null;
      }

      // Check if token is expired (5 minutes before actual expiration)
      if (_isTokenExpired(accessToken)) {
        return await _refreshToken();
      }

      return accessToken;
    } catch (e) {
      print('Error getting valid token: $e');
      return null;
    }
  }

  /// Check if JWT token is expired
  static bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = parts[1];
      final normalizedPayload =
          payload.padRight((payload.length + 3) & ~3, '=');

      final decoded = base64Decode(normalizedPayload);
      final payloadMap = jsonDecode(utf8.decode(decoded));

      final exp = payloadMap['exp'];
      if (exp == null) return true;

      final expirationTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now = DateTime.now();

      // Consider expired if less than 5 minutes remaining
      return expirationTime.isBefore(now.add(Duration(minutes: 5)));
    } catch (e) {
      return true;
    }
  }

  /// Refresh access token using refresh token
  static Future<String?> _refreshToken() async {
    // If already refreshing, wait for completion
    if (_isRefreshing) {
      final completer = Completer<String?>();
      _waitingRequests.add(completer);
      return completer.future;
    }

    _isRefreshing = true;

    try {
      final refreshToken = await TokenStorage.readRefresh();
      if (refreshToken == null || refreshToken.isEmpty) {
        _isRefreshing = false;
        _completeWaitingRequests(null);
        return null;
      }

      final baseUrl = ApiConfig.baseUrl();
      final response = await _client.post(
        Uri.parse('$baseUrl/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );

      print('Refresh response status: ${response.statusCode}');
      print('Refresh response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccessToken = data['access'];

        if (newAccessToken != null) {
          // Save new access token (keep same refresh token)
          await TokenStorage.save(newAccessToken, refreshToken);

          _isRefreshing = false;
          _completeWaitingRequests(newAccessToken);

          return newAccessToken;
        }
      }

      // Refresh failed
      print('Token refresh failed: ${response.body}');
      _isRefreshing = false;
      await TokenStorage.clear();
      _completeWaitingRequests(null);
      return null;
    } catch (e) {
      print('Token refresh error: $e');
      _isRefreshing = false;
      _completeWaitingRequests(null);
      return null;
    }
  }

  /// Complete all waiting requests
  static void _completeWaitingRequests(String? token) {
    for (final completer in _waitingRequests) {
      completer.complete(token);
    }
    _waitingRequests.clear();
  }

  /// Make authenticated HTTP request with auto token refresh
  static Future<http.Response> authenticatedRequest({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
    int maxRetries = 1,
  }) async {
    int retries = 0;

    while (retries <= maxRetries) {
      final accessToken = await getValidAccessToken();

      if (accessToken == null) {
        throw AuthException('Authentication required', needsLogin: true);
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };

      try {
        http.Response response;
        final uri = Uri.parse(endpoint);

        switch (method.toUpperCase()) {
          case 'GET':
            response = await _client.get(uri, headers: headers);
            break;
          case 'POST':
            response = await _client.post(
              uri,
              headers: headers,
              body: body != null ? jsonEncode(body) : null,
            );
            break;
          case 'PUT':
            response = await _client.put(
              uri,
              headers: headers,
              body: body != null ? jsonEncode(body) : null,
            );
            break;
          case 'DELETE':
            response = await _client.delete(uri, headers: headers);
            break;
          default:
            throw Exception('Unsupported HTTP method: $method');
        }

        // If token is invalid and we haven't retried yet
        if (response.statusCode == 401 && retries == 0) {
          print('Got 401, forcing token refresh...');
          await TokenStorage.clear(); // Force refresh on next call
          retries++;
          continue;
        }

        return response;
      } catch (e) {
        if (retries >= maxRetries) rethrow;
        retries++;
      }
    }

    throw Exception('Max retries exceeded');
  }

  /// Make multipart request (for file uploads) with auth
  static Future<http.Response> authenticatedMultipartRequest({
    required String endpoint,
    required String fileFieldName,
    required String filePath,
    Map<String, String>? fields,
  }) async {
    final accessToken = await getValidAccessToken();

    if (accessToken == null) {
      throw AuthException('Authentication required', needsLogin: true);
    }

    final request = http.MultipartRequest('POST', Uri.parse(endpoint));
    request.headers['Authorization'] = 'Bearer $accessToken';

    // Add file
    request.files
        .add(await http.MultipartFile.fromPath(fileFieldName, filePath));

    // Add fields
    if (fields != null) {
      request.fields.addAll(fields);
    }

    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  /// Check if user is authenticated with valid token
  static Future<bool> isAuthenticated() async {
    final token = await getValidAccessToken();
    return token != null;
  }

  /// Logout and clear all tokens
  static Future<void> logout() async {
    await TokenStorage.clear();
    _isRefreshing = false;
    _waitingRequests.clear();
  }

  /// Logout with backend call
  /// Logout with backend call
  static Future<Map<String, dynamic>> logoutWithBackend() async {
    try {
      String? userRole;

// 1. Try to read the role
      try {
        final userData = await TokenStorage.readUserData();
        userRole = userData?['role'] as String?;

        if (userRole == null) {
          final accessToken = await TokenStorage.readAccess();
          if (accessToken != null) {
            final parts = accessToken.split('.');
            if (parts.length == 3) {
              final payload = parts[1];
              final normalizedPayload =
                  payload.padRight((payload.length + 3) & ~3, '=');
              final decoded = base64Decode(normalizedPayload);
              final payloadMap = jsonDecode(utf8.decode(decoded));
              userRole = payloadMap['role'] as String?;
            }
          }
        }

        print('🔍 Detected user role: $userRole');

        if (userRole != null) {
          await TokenStorage.saveUserRole(userRole);
        }
      } catch (e) {
        print('⚠️ Error detecting role: $e');
      }

// 2. Stop Location Tracking Locally (for workers only)
      if (userRole == 'worker') {
        try {
          print('🔴 Setting worker offline');
// Stop local tracking only - no Backend calls
          final LocationService locationService = LocationService();
          locationService.dispose();
        } catch (e) {
          print('⚠️ Error stopping location tracking: $e');
        }
      }

// 3. Call the backend (it will stop the location in the database)
      final baseUrl = ApiConfig.baseUrl();
      final accessToken = await getValidAccessToken();

      if (accessToken != null) {
        try {
          final response = await _client.post(
            Uri.parse('$baseUrl/logout/'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
          );

          print('✅ Logout backend response: ${response.statusCode}');
        } catch (e) {
          print('⚠️ Logout backend error: $e');
        }
      }

// 4. Clear Tokens
      await logout();

      return {
        'ok': true,
        'message': 'Successfully logged out',
        'role': userRole
      };
    } catch (e) {
      print('❌ Logout error: $e');
      await logout();
      return {'ok': false, 'error': 'An error occurred while logging out'};
    }
  }

  /// Dispose resources
  static void dispose() {
    _client.close();
  }
}

/// Exception for authentication errors
class AuthException implements Exception {
  final String message;
  final bool needsLogin;

  AuthException(this.message, {this.needsLogin = false});

  @override
  String toString() => 'AuthException: $message';
}
