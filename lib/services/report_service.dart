// lib/data/services/report_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/api_config.dart';
import '../models/report_model.dart';
import '../../services/auth_manager.dart';

class ReportService {
  final String _baseUrl = ApiConfig.baseUrl().replaceAll('/users', '/chat');
  final http.Client _client = http.Client();

  // Headers مشتركة
  Future<Map<String, String>> get _headers async {
    String? token = await AuthManager.getValidAccessToken();

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // ==========================================
  // 1. إنشاء تبليغ جديد
  // POST /api/chat/reports/
  // ==========================================
  Future<Map<String, dynamic>> createReport(ReportModel report) async {
    try {
      String endpoint = '$_baseUrl/reports/';

      print('📍 Creating report: $endpoint');

      final headers = await _headers;

      final response = await _client.post(
        Uri.parse(endpoint),
        headers: headers,
        body: json.encode(report.toJson()),
      );

      print('Status: ${response.statusCode}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final createdReport = ReportModel.fromJson(data);

        print('✅ Report created successfully');

        return {
          'ok': true,
          'report': createdReport,
        };
      } else {
        final errorData = json.decode(response.body);
        print('⚠️ Failed: ${response.statusCode}');

        return {
          'ok': false,
          'error': errorData['error'] ?? 'Failed to create report',
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

  // ==========================================
  // 2. جلب تبليغات المستخدم
  // GET /api/chat/reports/my/
  // ==========================================
  Future<Map<String, dynamic>> getUserReports() async {
    try {
      String endpoint = '$_baseUrl/reports/my/';

      print('📍 Fetching user reports: $endpoint');

      final headers = await _headers;

      final response = await _client.get(
        Uri.parse(endpoint),
        headers: headers,
      );

      print('Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        List<ReportModel> reports = data
            .map((item) {
              try {
                return ReportModel.fromJson(item as Map<String, dynamic>);
              } catch (e) {
                print('Report parse error: $e');
                return null;
              }
            })
            .whereType<ReportModel>()
            .toList();

        print('✅ Loaded ${reports.length} reports');

        return {
          'ok': true,
          'reports': reports,
          'count': reports.length,
        };
      } else {
        print('⚠️ Failed: ${response.statusCode}');
        return {
          'ok': false,
          'error': 'Failed to load reports',
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

  // ==========================================
  // 3. إرسال تبليغ سريع (Shortcut)
  // ==========================================
  Future<Map<String, dynamic>> quickReport({
    required int reportedUserId,
    required String reason,
    int? conversationId,
    String? description,
  }) async {
    try {
      print('📍 Quick report: User $reportedUserId, Reason: $reason');

      final report = ReportModel(
        reportedUserId: reportedUserId,
        conversationId: conversationId,
        reason: reason,
        description: description,
      );

      return await createReport(report);
    } catch (e) {
      print('❌ Error: $e');
      return {
        'ok': false,
        'error': 'Error creating quick report: ${e.toString()}',
      };
    }
  }

  void dispose() {
    _client.close();
  }
}

// Singleton instance
final ReportService reportService = ReportService();
