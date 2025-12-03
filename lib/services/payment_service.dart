// lib/services/payment_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../models/payment_model.dart';
import '../models/task_counter_model.dart';
import '../models/subscription_model.dart';
import 'auth_manager.dart';

class PaymentService {
  final String _baseUrl = ApiConfig.baseUrl().replaceAll('/users', '/payments');
  final http.Client _client = http.Client();

  // ====================================================================
  //  NEW: TASK COUNTER / SOFT-LOCK ENDPOINTS
  // ====================================================================

  Future<Map<String, dynamic>> checkTaskLimit() async {
    try {
      final endpoint = '$_baseUrl/check-limit/';
      print('📍 Checking task limit: $endpoint');

      final String? token = await AuthManager.getValidAccessToken();

      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      final response = await _client.get(Uri.parse(endpoint), headers: headers);

      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      final dynamic json = _parseResponse(response);

      if (response.statusCode == 200) {
        TaskCounterModel? counter;
        if (json is Map<String, dynamic>) {
          counter = TaskCounterModel.fromJson(json);
        }

        return {
          'ok': true,
          'counter': counter,
          'json': json,
        };
      }

      final errorMessage =
          _extractError(json) ?? 'Impossible de vérifier la limite';
      return {
        'ok': false,
        'error': errorMessage,
        'json': json,
      };
    } catch (e) {
      print('❌ checkTaskLimit error: $e');
      return {
        'ok': false,
        'error': 'Erreur réseau: ${e.toString()}',
        'json': {},
      };
    }
  }

  Future<Map<String, dynamic>> getMyTaskCounter() async {
    try {
      final endpoint = '$_baseUrl/my-counter/';
      print('📍 Fetching my task counter: $endpoint');

      final String? token = await AuthManager.getValidAccessToken();

      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      final response = await _client.get(Uri.parse(endpoint), headers: headers);

      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      final dynamic json = _parseResponse(response);

      if (response.statusCode == 200) {
        TaskCounterModel? counter;
        if (json is Map<String, dynamic>) {
          counter = TaskCounterModel.fromJson(json);
        }

        return {
          'ok': true,
          'counter': counter,
          'json': json,
        };
      }

      final errorMessage =
          _extractError(json) ?? 'Impossible de charger le compteur';
      return {
        'ok': false,
        'error': errorMessage,
        'json': json,
      };
    } catch (e) {
      print('❌ getMyTaskCounter error: $e');
      return {
        'ok': false,
        'error': 'Erreur réseau: ${e.toString()}',
        'json': {},
      };
    }
  }

  Future<Map<String, dynamic>> subscribe() async {
    try {
      final endpoint = '$_baseUrl/subscribe/';
      print('📍 Calling subscribe endpoint: $endpoint');

      final String? token = await AuthManager.getValidAccessToken();

      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      final response =
          await _client.post(Uri.parse(endpoint), headers: headers);

      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      final dynamic json = _parseResponse(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        SubscriptionModel? subscription;
        if (json is Map<String, dynamic>) {
          subscription = SubscriptionModel.fromJson(json);
        }

        return {
          'ok': true,
          'subscription': subscription,
          'json': json,
        };
      }

      final errorMessage = _extractError(json) ??
          'La fonctionnalité abonnement sera bientôt disponible';
      return {
        'ok': false,
        'error': errorMessage,
        'json': json,
      };
    } catch (e) {
      print('❌ subscribe error: $e');
      return {
        'ok': false,
        'error':
            'Erreur réseau ou fonctionnalité non disponible: ${e.toString()}',
        'json': {},
      };
    }
  }

  void dispose() {
    _client.close();
  }

  dynamic _parseResponse(http.Response response) {
    try {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body);
    } catch (e) {
      print('❌ JSON parse error: $e');
      return {'detail': 'Invalid response format'};
    }
  }

  String? _extractError(dynamic json) {
    if (json is Map<String, dynamic>) {
      return (json['detail'] ??
              json['error'] ??
              json['message'] ??
              json['non_field_errors'])
          ?.toString();
    }
    if (json is List && json.isNotEmpty) {
      return json.first.toString();
    }
    if (json is String && json.isNotEmpty) {
      return json;
    }
    return null;
  }
}

final PaymentService paymentService = PaymentService();
