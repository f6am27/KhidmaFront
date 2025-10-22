// lib/data/services/chat_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/api_config.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../../services/auth_manager.dart';

class ChatService {
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
  // 1. جلب قائمة المحادثات
  // GET /api/chat/conversations/
  // ==========================================
  Future<Map<String, dynamic>> getConversations() async {
    try {
      String endpoint = '$_baseUrl/conversations/';

      print('📍 Fetching conversations: $endpoint');

      final headers = await _headers;

      final response = await _client.get(
        Uri.parse(endpoint),
        headers: headers,
      );

      print('Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        List<ConversationModel> conversations = data
            .map((item) {
              try {
                return ConversationModel.fromJson(item as Map<String, dynamic>);
              } catch (e) {
                print('Conversation parse error: $e');
                return null;
              }
            })
            .whereType<ConversationModel>()
            .toList();

        print('✅ Loaded ${conversations.length} conversations');

        return {
          'ok': true,
          'conversations': conversations,
          'count': conversations.length,
        };
      } else {
        print('⚠️ Failed: ${response.statusCode}');
        return {
          'ok': false,
          'error': 'Failed to load conversations',
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
  // 2. جلب رسائل محادثة معينة
  // GET /api/chat/conversations/{conversation_id}/messages/
  // ==========================================
  Future<Map<String, dynamic>> getMessages(int conversationId,
      {int page = 1}) async {
    try {
      String endpoint =
          '$_baseUrl/conversations/$conversationId/messages/?page=$page';

      print('📍 Fetching messages: $endpoint');

      final headers = await _headers;

      final response = await _client.get(
        Uri.parse(endpoint),
        headers: headers,
      );

      print('Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'] ?? data;

        List<MessageModel> messages = results
            .map((item) {
              try {
                return MessageModel.fromJson(item as Map<String, dynamic>);
              } catch (e) {
                print('Message parse error: $e');
                return null;
              }
            })
            .whereType<MessageModel>()
            .toList();

        print('✅ Loaded ${messages.length} messages');

        return {
          'ok': true,
          'messages': messages,
          'count': messages.length,
        };
      } else {
        print('⚠️ Failed: ${response.statusCode}');
        return {
          'ok': false,
          'error': 'Failed to load messages',
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
  // 3. إرسال رسالة جديدة
  // POST /api/chat/conversations/{conversation_id}/send/
  // ==========================================
  Future<Map<String, dynamic>> sendMessage(
      int conversationId, String content) async {
    try {
      String endpoint = '$_baseUrl/conversations/$conversationId/send/';

      print('📍 Sending message: $endpoint');

      final headers = await _headers;

      final response = await _client.post(
        Uri.parse(endpoint),
        headers: headers,
        body: json.encode({'content': content}),
      );

      print('Status: ${response.statusCode}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final message = MessageModel.fromJson(data);

        print('✅ Message sent successfully');

        return {
          'ok': true,
          'message': message,
        };
      } else {
        print('⚠️ Failed: ${response.statusCode}');
        return {
          'ok': false,
          'error': 'Failed to send message',
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
  // 4. بدء محادثة جديدة
  // POST /api/chat/start-conversation/
  // ==========================================
  Future<Map<String, dynamic>> startConversation(int otherUserId,
      {String? initialMessage}) async {
    try {
      String endpoint = '$_baseUrl/start-conversation/';

      final body = {
        'other_user_id': otherUserId,
        if (initialMessage != null && initialMessage.isNotEmpty)
          'initial_message': initialMessage,
      };

      print('📍 Starting conversation: $endpoint');

      final headers = await _headers;

      final response = await _client.post(
        Uri.parse(endpoint),
        headers: headers,
        body: json.encode(body),
      );

      print('Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        print('✅ Conversation started: ${data['conversation_id']}');

        return {
          'ok': true,
          ...data,
        };
      } else {
        print('⚠️ Failed: ${response.statusCode}');
        return {
          'ok': false,
          'error': 'Failed to start conversation',
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
  // 5. حذف محادثة
  // DELETE /api/chat/conversations/{conversation_id}/
  // ==========================================
  Future<Map<String, dynamic>> deleteConversation(int conversationId) async {
    try {
      String endpoint = '$_baseUrl/conversations/$conversationId/';

      print('📍 Deleting conversation: $endpoint');

      final headers = await _headers;

      final response = await _client.delete(
        Uri.parse(endpoint),
        headers: headers,
      );

      print('Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ Conversation deleted');

        return {
          'ok': true,
          'message': 'Conversation deleted successfully',
        };
      } else {
        print('⚠️ Failed: ${response.statusCode}');
        return {
          'ok': false,
          'error': 'Failed to delete conversation',
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
  // 6. عدد الرسائل غير المقروءة الإجمالي
  // GET /api/chat/unread-count/
  // ==========================================
  Future<Map<String, dynamic>> getUnreadCount() async {
    try {
      String endpoint = '$_baseUrl/unread-count/';

      print('📍 Fetching unread count: $endpoint');

      final headers = await _headers;

      final response = await _client.get(
        Uri.parse(endpoint),
        headers: headers,
      );

      print('Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final count = data['unread_count'] ?? 0;

        print('✅ Unread messages: $count');

        return {
          'ok': true,
          'unread_count': count,
        };
      } else {
        print('⚠️ Failed: ${response.statusCode}');
        return {
          'ok': false,
          'error': 'Failed to load unread count',
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
  // 7. حظر مستخدم
  // POST /api/chat/block/{user_id}/
  // ==========================================
  Future<Map<String, dynamic>> blockUser(int userId, {String? reason}) async {
    try {
      String endpoint = '$_baseUrl/block/$userId/';

      final body = {
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      };

      print('📍 Blocking user: $endpoint');

      final headers = await _headers;

      final response = await _client.post(
        Uri.parse(endpoint),
        headers: headers,
        body: json.encode(body),
      );

      print('Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ User blocked');

        return {
          'ok': true,
          'message': 'User blocked successfully',
        };
      } else {
        print('⚠️ Failed: ${response.statusCode}');
        return {
          'ok': false,
          'error': 'Failed to block user',
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
  // 8. إلغاء حظر مستخدم
  // DELETE /api/chat/unblock/{user_id}/
  // ==========================================
  Future<Map<String, dynamic>> unblockUser(int userId) async {
    try {
      String endpoint = '$_baseUrl/unblock/$userId/';

      print('📍 Unblocking user: $endpoint');

      final headers = await _headers;

      final response = await _client.delete(
        Uri.parse(endpoint),
        headers: headers,
      );

      print('Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ User unblocked');

        return {
          'ok': true,
          'message': 'User unblocked successfully',
        };
      } else {
        print('⚠️ Failed: ${response.statusCode}');
        return {
          'ok': false,
          'error': 'Failed to unblock user',
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
  // 9. قائمة المستخدمين المحظورين
  // GET /api/chat/blocked-users/
  // ==========================================
  Future<Map<String, dynamic>> getBlockedUsers() async {
    try {
      String endpoint = '$_baseUrl/blocked-users/';

      print('📍 Fetching blocked users: $endpoint');

      final headers = await _headers;

      final response = await _client.get(
        Uri.parse(endpoint),
        headers: headers,
      );

      print('Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> blockedUsers = data['blocked_users'] ?? [];

        print('✅ Loaded ${blockedUsers.length} blocked users');

        return {
          'ok': true,
          'blocked_users': blockedUsers,
          'count': blockedUsers.length,
        };
      } else {
        print('⚠️ Failed: ${response.statusCode}');
        return {
          'ok': false,
          'error': 'Failed to load blocked users',
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

  void dispose() {
    _client.close();
  }
}

// Singleton instance
final ChatService chatService = ChatService();
