import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class LotteryService {
  /// 獲取歷屆開獎號碼
  static Future<List<dynamic>> getHistoricalResults({
    required String lotteryType,
    int? limit,
  }) async {
    try {
      var url = '${ApiConfig.lotteryHistorical}/$lotteryType';
      if (limit != null) {
        url += '?limit=$limit';
      }
      
      final uri = Uri.parse(url);

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['draws'] ?? [];
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? '獲取歷史開獎失敗');
      }
    } catch (e) {
      throw Exception('網路錯誤: $e');
    }
  }

  /// 獲取最新開獎號碼
  static Future<Map<String, dynamic>> getLatestResult(String lotteryType) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.lotteryLatest}/$lotteryType'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? '獲取最新開獎失敗');
      }
    } catch (e) {
      throw Exception('網路錯誤: $e');
    }
  }

  /// 樂透類型列表
  static const Map<String, String> lotteryTypes = {
    'lotto649': '大樂透',
    'superlotto638': '威力彩',
    'dailycash': '今彩539',
  };
  
  /// 樂透 LOGO 圖片路徑
  static const Map<String, String> lotteryLogos = {
    'lotto649': 'assets/images/大樂透.png',
    'superlotto638': 'assets/images/威力彩.png',
    'dailycash': 'assets/images/539.png',
  };

  /// 獲取樂透類型顯示名稱
  static String getLotteryDisplayName(String type) {
    return lotteryTypes[type] ?? type;
  }
  
  /// 獲取樂透 LOGO 路徑
  static String? getLotteryLogo(String type) {
    return lotteryLogos[type];
  }
}

