import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class AIService {
  /// 生成彩票號碼
  static Future<Map<String, dynamic>> generateNumbers({
    required String lotteryType,
    required String strategy,
    required String aiPlatform,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('請先登入');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/ai/generate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'lottery_type': lotteryType,
          'strategy': strategy,
          'ai_platform': aiPlatform,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? '生成號碼失敗');
      }
    } catch (e) {
      throw Exception('網路錯誤: $e');
    }
  }

  /// 與 AI 對話
  static Future<String> chatWithAI({
    required String message,
    required String aiPlatform,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('請先登入');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/ai/chat'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'message': message,
          'ai_platform': aiPlatform,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ?? '';
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'AI 對話失敗');
      }
    } catch (e) {
      throw Exception('網路錯誤: $e');
    }
  }
}

