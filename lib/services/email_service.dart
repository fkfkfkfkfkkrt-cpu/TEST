import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class EmailService {
  /// 發送註冊驗證碼
  static Future<Map<String, dynamic>> sendVerificationCode(String email) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.sendVerification),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? '發送驗證碼失敗');
      }
    } catch (e) {
      throw Exception('網路錯誤: $e');
    }
  }

  /// 驗證驗證碼
  static Future<bool> verifyCode(String email, String code) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.verifyCode),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'code': code,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? '驗證碼錯誤');
      }
    } catch (e) {
      throw Exception('驗證失敗: $e');
    }
  }

  /// 發送密碼重設驗證碼
  static Future<Map<String, dynamic>> sendPasswordResetCode(String email) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.sendPasswordReset),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? '發送驗證碼失敗');
      }
    } catch (e) {
      throw Exception('網路錯誤: $e');
    }
  }
}

