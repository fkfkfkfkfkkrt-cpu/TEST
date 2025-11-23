import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io';
import '../utils/app_styles.dart';
import '../services/auth_service.dart';
import 'chat_screen.dart';
import 'register_screen.dart';
import 'email_login_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isLoading = false;

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      final String? idToken = auth.idToken;

      if (idToken == null) {
        throw Exception('無法獲取 Google 登入憑證');
      }

      await AuthService.loginWithGoogle(idToken);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google 登入成功！'), backgroundColor: Colors.green),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ChatScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google 登入失敗: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAppleLogin() async {
    setState(() => _isLoading = true);

    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final String? identityToken = credential.identityToken;
      if (identityToken == null) {
        throw Exception('無法獲取 Apple 登入憑證');
      }

      await AuthService.loginWithApple(identityToken);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Apple 登入成功！'), backgroundColor: Colors.green),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ChatScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Apple 登入失敗: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: AppColors.getTextPrimary(context),
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              // 首次安裝，導航到聊天頁面
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChatScreen(),
                ),
              );
            }
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/app_icon.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // App 名稱
                const Text(
                  'IntelliLotto',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '智能彩選 AI 助手',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.getTextMuted(context),
                  ),
                ),
                const SizedBox(height: 48),
                
                // Apple 登入 (僅 iOS/macOS)
                if (Platform.isIOS || Platform.isMacOS) ...[
                  _buildSocialButton(
                    context,
                    icon: Icons.apple,
                    label: '使用 Apple 登入',
                    color: isDark ? Colors.white : Colors.black,
                    textColor: isDark ? Colors.black : Colors.white,
                    onTap: _isLoading ? () {} : _handleAppleLogin,
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Google 登入
                _buildSocialButton(
                  context,
                  icon: Icons.g_mobiledata,
                  label: '使用 Google 登入',
                  color: Colors.white,
                  textColor: Colors.black87,
                  borderColor: Colors.grey.shade300,
                  onTap: _isLoading ? () {} : _handleGoogleLogin,
                ),
                const SizedBox(height: 32),
                
                // 分隔線
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: AppColors.getTextMuted(context).withOpacity(0.3),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '或',
                        style: TextStyle(
                          color: AppColors.getTextMuted(context),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: AppColors.getTextMuted(context).withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // 註冊按鈕
                _buildButton(
                  context,
                  label: '註冊新帳號',
                  isPrimary: false,
                  onTap: _isLoading
                      ? () {}
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                ),
                const SizedBox(height: 16),
                
                // 登入按鈕
                _buildButton(
                  context,
                  label: '登入',
                  isPrimary: true,
                  onTap: _isLoading
                      ? () {}
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EmailLoginScreen(),
                            ),
                          );
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSocialButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
    Color? borderColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: borderColor != null
                ? Border.all(color: borderColor, width: 1)
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: textColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildButton(
    BuildContext context, {
    required String label,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isPrimary ? AppColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isPrimary
                ? null
                : Border.all(
                    color: AppColors.primary,
                    width: 2,
                  ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isPrimary ? Colors.white : AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

