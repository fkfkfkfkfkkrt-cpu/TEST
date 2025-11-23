import 'package:flutter/material.dart';
import 'dart:async';
import '../services/email_service.dart';
import '../services/auth_service.dart';
import '../utils/app_styles.dart';
import 'chat_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _codeController = TextEditingController();

  bool _isLoading = false;
  bool _codeSent = false;
  bool _codeVerified = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int _countdown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    setState(() => _countdown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _sendVerificationCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await EmailService.sendVerificationCode(_emailController.text.trim());
      _startCountdown();
      setState(() => _codeSent = true);
    } catch (e) {
      // 靜默失敗
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyCode() async {
    if (_codeController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await EmailService.verifyCode(
        _emailController.text.trim(),
        _codeController.text.trim(),
      );
      setState(() => _codeVerified = true);
    } catch (e) {
      // 靜默失敗
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_codeVerified) return;

    setState(() => _isLoading = true);

    try {
      await AuthService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        username: _usernameController.text.trim(),
      );

      if (mounted) {
        // 導航到聊天頁面
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ChatScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      // 靜默失敗
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
          icon: Icon(Icons.arrow_back, color: AppColors.getTextPrimary(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('註冊新帳號'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 郵箱
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_codeVerified,
                  decoration: InputDecoration(
                    labelText: '郵箱地址',
                    prefixIcon: const Icon(Icons.email_outlined),
                    suffixIcon: _codeVerified
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                    filled: true,
                    fillColor: isDark ? Colors.grey[900] : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '請輸入郵箱';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return '請輸入有效的郵箱地址';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 驗證碼輸入和發送按鈕
                if (_codeSent) ...[
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _codeController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          enabled: !_codeVerified,
                          decoration: InputDecoration(
                            labelText: '驗證碼',
                            prefixIcon: const Icon(Icons.lock_outline),
                            counterText: '',
                            filled: true,
                            fillColor: isDark ? Colors.grey[900] : Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _codeVerified || _isLoading
                              ? null
                              : _verifyCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _codeVerified
                              ? const Icon(Icons.check, color: Colors.white)
                              : const Text('驗證', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // 發送/重發驗證碼按鈕
                if (!_codeVerified)
                  ElevatedButton(
                    onPressed: _countdown > 0 || _isLoading
                        ? null
                        : _sendVerificationCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _codeSent ? Colors.grey : AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _countdown > 0
                          ? '重新發送 ($_countdown秒)'
                          : _codeSent
                              ? '重新發送驗證碼'
                              : '發送驗證碼',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),

                if (_codeVerified) ...[
                  const SizedBox(height: 16),
                  // 用戶名
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: '用戶名',
                      prefixIcon: const Icon(Icons.person_outline),
                      filled: true,
                      fillColor: isDark ? Colors.grey[900] : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '請輸入用戶名';
                      }
                      if (value.length < 2) {
                        return '用戶名至少 2 個字符';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 密碼
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: '密碼',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.grey[900] : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '請輸入密碼';
                      }
                      if (value.length < 6) {
                        return '密碼至少 6 個字符';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 確認密碼
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      labelText: '確認密碼',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.grey[900] : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return '密碼不一致';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // 註冊按鈕
                  ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('註冊', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

