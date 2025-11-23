import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class ConversationService {
  /// 獲取所有對話列表
  static Future<List<Map<String, dynamic>>> getConversations() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('未登入');

      final response = await http.get(
        Uri.parse('${ApiConfig.conversations}/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => e as Map<String, dynamic>).toList();
      } else {
        throw Exception('獲取對話列表失敗');
      }
    } catch (e) {
      throw Exception('錯誤: $e');
    }
  }

  /// 獲取單個對話詳情（含所有訊息）
  static Future<Map<String, dynamic>> getConversation(int conversationId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('未登入');

      final response = await http.get(
        Uri.parse('${ApiConfig.conversations}/$conversationId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('獲取對話詳情失敗');
      }
    } catch (e) {
      throw Exception('錯誤: $e');
    }
  }

  /// 創建新對話
  static Future<Map<String, dynamic>> createConversation({
    String title = '新對話',
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('未登入');

      final response = await http.post(
        Uri.parse(ApiConfig.conversations),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'title': title}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('創建對話失敗');
      }
    } catch (e) {
      throw Exception('錯誤: $e');
    }
  }
  
  /// 保存完整對話（包含所有訊息）
  static Future<void> saveConversation({
    required List<Map<String, dynamic>> messages,
    String? title,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('未登入');

      // 使用傳入的標題，如果沒有則自動生成
      String conversationTitle = title ?? 'AI 選號對話';
      
      // 只有在沒有傳入標題時才從訊息生成
      if (title == null || title.isEmpty) {
        if (messages.isNotEmpty) {
          final firstUserMessage = messages.firstWhere(
            (msg) => msg['role'] == 'user',
            orElse: () => {'content': ''},
          );
          if (firstUserMessage['content'] != null && firstUserMessage['content'].toString().isNotEmpty) {
            conversationTitle = firstUserMessage['content'].toString().substring(0, 
              firstUserMessage['content'].toString().length > 20 ? 20 : firstUserMessage['content'].toString().length
            ) + '...';
          }
        }
      }
      
      final response = await http.post(
        Uri.parse('${ApiConfig.conversations}/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': conversationTitle,
          'messages': messages.map((msg) => {
            'role': msg['role'] == 'user' ? 'user' : 'assistant',
            'content': msg['content'],
          }).toList(),
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('保存對話失敗');
      }
    } catch (e) {
      throw Exception('錯誤: $e');
    }
  }

  /// 添加訊息到對話
  static Future<Map<String, dynamic>> addMessage({
    required int conversationId,
    required String role, // 'user' 或 'assistant'
    required String content,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('未登入');

      final response = await http.post(
        Uri.parse('${ApiConfig.conversations}/$conversationId/messages'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'role': role,
          'content': content,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('添加訊息失敗');
      }
    } catch (e) {
      throw Exception('錯誤: $e');
    }
  }

  /// 更新對話標題
  static Future<Map<String, dynamic>> updateConversation({
    required int conversationId,
    required String title,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('未登入');

      final response = await http.put(
        Uri.parse('${ApiConfig.conversations}/$conversationId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'title': title}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('更新對話失敗');
      }
    } catch (e) {
      throw Exception('錯誤: $e');
    }
  }

  /// 刪除對話
  static Future<void> deleteConversation(int conversationId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('未登入');

      final response = await http.delete(
        Uri.parse('${ApiConfig.conversations}/$conversationId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('刪除對話失敗');
      }
    } catch (e) {
      throw Exception('錯誤: $e');
    }
  }

  /// 格式化日期顯示
  static String formatDate(String? isoDate) {
    if (isoDate == null) return '';
    
    try {
      final date = DateTime.parse(isoDate);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return '今天 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays == 1) {
        return '昨天 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}天前';
      } else {
        return '${date.month}/${date.day}';
      }
    } catch (e) {
      return isoDate;
    }
  }
}

