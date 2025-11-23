class ApiConfig {
  // 測試環境（選擇你的設備）：
  // iOS 模擬器用：
  // static const String baseUrl = 'http://127.0.0.1:1457/api';
  
  // Android 模擬器用（10.0.2.2 指向宿主機 Windows）：
  //static const String baseUrl = 'http://10.0.2.2:1457/api';
  
  // 生產環境：
  static const String baseUrl = 'http://220.133.94.228:1457/api';
  
  // Auth endpoints
  static const String register = '$baseUrl/auth/register';
  static const String login = '$baseUrl/auth/login';
  static const String socialLogin = '$baseUrl/auth/social-login';
  
  // Email endpoints
  static const String sendVerification = '$baseUrl/email/send-verification';
  static const String verifyCode = '$baseUrl/email/verify-code';
  static const String sendPasswordReset = '$baseUrl/email/send-password-reset';
  
  // Lottery endpoints
  static const String lotteryHistorical = '$baseUrl/lottery/historical';
  static const String lotteryLatest = '$baseUrl/lottery/latest';
  
  // Conversation endpoints
  static const String conversations = '$baseUrl/conversations';
  
  // User endpoints
  static const String userProfile = '$baseUrl/user/profile';
}

