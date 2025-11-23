import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  /// 註冊新用戶
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.register),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'username': username,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await _saveToken(data['access_token']);
        await _saveUser(data['user']);
        return data;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? '註冊失敗');
      }
    } catch (e) {
      throw Exception('註冊錯誤: $e');
    }
  }

  /// 登入
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveToken(data['access_token']);
        // 登入後獲取用戶資料
        await getUserProfile();
        return data;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? '登入失敗');
      }
    } catch (e) {
      print('❌ 登入錯誤詳情: $e');
      throw Exception('登入錯誤: $e');
    }
  }

  /// Google 登入
  static Future<Map<String, dynamic>> loginWithGoogle(String idToken) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.socialLogin),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_token': idToken,
          'provider': 'google',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveToken(data['access_token']);
        await _saveUser(data['user']);
        return data;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Google 登入失敗');
      }
    } catch (e) {
      throw Exception('Google 登入錯誤: $e');
    }
  }

  /// Apple 登入
  static Future<Map<String, dynamic>> loginWithApple(String identityToken) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.socialLogin),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_token': identityToken,
          'provider': 'apple',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveToken(data['access_token']);
        await _saveUser(data['user']);
        return data;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Apple 登入失敗');
      }
    } catch (e) {
      throw Exception('Apple 登入錯誤: $e');
    }
  }

  /// 獲取用戶資料
  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('未登入');

      final response = await http.get(
        Uri.parse(ApiConfig.userProfile),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveUser(data);
        return data;
      } else {
        throw Exception('獲取用戶資料失敗');
      }
    } catch (e) {
      throw Exception('錯誤: $e');
    }
  }

  /// 登出
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  /// 檢查是否已登入
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  /// 獲取 Token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// 獲取用戶資料
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson == null) return null;
    return jsonDecode(userJson);
  }

  /// 保存 Token
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// 保存用戶資料
  static Future<void> _saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user));
  }
}

