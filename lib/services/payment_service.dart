// lib/services/payment_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';
import '../models/payment_model.dart';
import 'auth_manager.dart';

class PaymentService {
  final String _baseUrl = ApiConfig.baseUrl().replaceAll('/users', '/payments');
  final http.Client _client = http.Client();

  /// Get my payments (made or received)
  Future<Map<String, dynamic>> getMyPayments({
    int? limit,
    int? offset,
  }) async {
    try {
      String endpoint = '$_baseUrl/my-payments/';
      List<String> params = [];

      if (limit != null) {
        params.add('limit=$limit');
      }
      if (offset != null) {
        params.add('offset=$offset');
      }

      if (params.isNotEmpty) {
        endpoint += '?${params.join('&')}';
      }

      print('📍 Fetching payments: $endpoint');

      String? token = await AuthManager.getValidAccessToken();

      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await _client.get(
        Uri.parse(endpoint),
        headers: headers,
      );

      print('Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        List<dynamic> paymentsData = [];

        if (json is List) {
          paymentsData = json;
        } else if (json is Map && json['results'] != null) {
          paymentsData = json['results'] as List;
        }

        List<PaymentModel> payments = paymentsData
            .map((item) {
              try {
                return PaymentModel.fromJson(item as Map<String, dynamic>);
              } catch (e) {
                print('Payment parse error: $e');
                return null;
              }
            })
            .whereType<PaymentModel>()
            .toList();

        print('✅ Loaded ${payments.length} payments');

        return {
          'ok': true,
          'payments': payments,
          'count': payments.length,
        };
      } else {
        print('⚠️ Failed: ${response.statusCode}');
        return {
          'ok': false,
          'error': 'Failed to load payments',
        };
      }
    } catch (e) {
      print('❌ Error: $e');
      return {
        'ok': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Get payment statistics
  Future<Map<String, dynamic>> getPaymentStatistics() async {
    try {
      String endpoint = '$_baseUrl/statistics/';

      print('📍 Fetching payment statistics: $endpoint');

      String? token = await AuthManager.getValidAccessToken();

      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await _client.get(
        Uri.parse(endpoint),
        headers: headers,
      );

      print('Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        final stats = PaymentStatisticsModel.fromJson(json);

        print('✅ Statistics loaded: ${stats.totalAmount} MRU');

        return {
          'ok': true,
          'statistics': stats,
        };
      } else {
        return {
          'ok': false,
          'error': 'Failed to load statistics',
        };
      }
    } catch (e) {
      print('❌ Error: $e');
      return {
        'ok': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Get payment history with filters
  Future<Map<String, dynamic>> getPaymentHistory({
    String? status,
    String? paymentMethod,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      String endpoint = '$_baseUrl/history/';
      List<String> params = [];

      if (status != null && status.isNotEmpty) {
        params.add('status=$status');
      }

      if (paymentMethod != null && paymentMethod.isNotEmpty) {
        params.add('payment_method=$paymentMethod');
      }

      params.add('limit=$limit');
      params.add('offset=$offset');

      endpoint += '?${params.join('&')}';

      print('📍 Fetching payment history: $endpoint');

      String? token = await AuthManager.getValidAccessToken();

      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await _client.get(
        Uri.parse(endpoint),
        headers: headers,
      );

      print('Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        List<dynamic> paymentsData = json['results'] as List? ?? [];

        List<PaymentModel> payments = paymentsData
            .map((item) {
              try {
                return PaymentModel.fromJson(item as Map<String, dynamic>);
              } catch (e) {
                print('Payment parse error: $e');
                return null;
              }
            })
            .whereType<PaymentModel>()
            .toList();

        print('✅ Loaded ${payments.length} payment history records');

        return {
          'ok': true,
          'payments': payments,
          'count': json['count'] ?? payments.length,
          'total': json['count'] ?? 0,
        };
      } else {
        return {
          'ok': false,
          'error': 'Failed to load payment history',
        };
      }
    } catch (e) {
      print('❌ Error: $e');
      return {
        'ok': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Get received payments (for workers only)
  Future<Map<String, dynamic>> getReceivedPayments({
    int? limit,
    int? offset,
  }) async {
    try {
      String endpoint = '$_baseUrl/received/';
      List<String> params = [];

      if (limit != null) {
        params.add('limit=$limit');
      }
      if (offset != null) {
        params.add('offset=$offset');
      }

      if (params.isNotEmpty) {
        endpoint += '?${params.join('&')}';
      }

      print('📍 Fetching received payments: $endpoint');

      String? token = await AuthManager.getValidAccessToken();

      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await _client.get(
        Uri.parse(endpoint),
        headers: headers,
      );

      print('Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        List<dynamic> paymentsData = [];

        if (json is List) {
          paymentsData = json;
        } else if (json is Map && json['results'] != null) {
          paymentsData = json['results'] as List;
        }

        List<PaymentModel> payments = paymentsData
            .map((item) {
              try {
                return PaymentModel.fromJson(item as Map<String, dynamic>);
              } catch (e) {
                print('Payment parse error: $e');
                return null;
              }
            })
            .whereType<PaymentModel>()
            .toList();

        print('✅ Loaded ${payments.length} received payments');

        return {
          'ok': true,
          'payments': payments,
          'count': payments.length,
        };
      } else {
        return {
          'ok': false,
          'error': 'Failed to load received payments',
        };
      }
    } catch (e) {
      print('❌ Error: $e');
      return {
        'ok': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Initiate Moosyl payment (Bankily, Sedad, Masrivi)
  Future<Map<String, dynamic>> initiateMoosylPayment({
    required int taskId,
    required String paymentMethod,
    required double amount,
  }) async {
    try {
      String endpoint = '$_baseUrl/moosyl/initiate/';

      print('📍 Initiating Moosyl payment: $endpoint');
      print('Task ID: $taskId');
      print('Method: $paymentMethod');
      print('Amount: $amount');

      String? token = await AuthManager.getValidAccessToken();

      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final body = jsonEncode({
        'task_id': taskId,
        'payment_method': paymentMethod,
        'amount': amount,
      });

      final response = await _client.post(
        Uri.parse(endpoint),
        headers: headers,
        body: body,
      );

      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');

      if (response.statusCode == 201) {
        final json = jsonDecode(response.body);

        return {
          'ok': true,
          'payment_id': json['payment_id'],
          'transaction_id': json['transaction_id'],
          'publishable_key': json['publishable_key'],
          'amount': json['amount'],
          'message': json['message'],
        };
      } else {
        final json = jsonDecode(response.body);
        return {
          'ok': false,
          'error': json['error'] ?? 'Échec de l\'initialisation du paiement',
        };
      }
    } catch (e) {
      print('❌ Error: $e');
      return {
        'ok': false,
        'error': 'Erreur réseau: ${e.toString()}',
      };
    }
  }

  /// Verify Moosyl payment status
  Future<Map<String, dynamic>> verifyMoosylPayment({
    required int paymentId,
  }) async {
    try {
      String endpoint = '$_baseUrl/moosyl/verify/$paymentId/';

      print('📍 Verifying payment: $endpoint');

      String? token = await AuthManager.getValidAccessToken();

      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await _client.get(
        Uri.parse(endpoint),
        headers: headers,
      );

      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        return {
          'ok': true,
          'status': json['status'],
          'message': json['message'],
          'payment': json['payment'],
        };
      } else {
        final json = jsonDecode(response.body);
        return {
          'ok': false,
          'error': json['error'] ?? 'Erreur de vérification',
        };
      }
    } catch (e) {
      print('❌ Error: $e');
      return {
        'ok': false,
        'error': 'Erreur réseau: ${e.toString()}',
      };
    }
  }

  void dispose() {
    _client.close();
  }
}

final PaymentService paymentService = PaymentService();
