import 'package:flutter/material.dart';
import 'dart:async';
import '../services/email_service.dart';
import '../utils/app_styles.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _codeSent = false;
  bool _codeVerified = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  int _countdown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
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

  Future<void> _sendResetCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await EmailService.sendPasswordResetCode(_emailController.text.trim());
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

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // TODO: 呼叫重設密碼 API
      // await AuthService.resetPassword(...);
      
      if (mounted) {
        Navigator.pop(context);
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
        title: const Text('忘記密碼'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                
                Text(
                  '請輸入您的註冊郵箱，我們將發送驗證碼到您的郵箱',
                  style: TextStyle(
                    color: AppColors.getTextMuted(context),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),

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

                // 驗證碼輸入和驗證按鈕
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
                        : _sendResetCode,
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

                // 新密碼設定
                if (_codeVerified) ...[
                  const SizedBox(height: 24),
                  Text(
                    '請設定新密碼',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 新密碼
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: _obscureNewPassword,
                    decoration: InputDecoration(
                      labelText: '新密碼',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNewPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
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
                        return '請輸入新密碼';
                      }
                      if (value.length < 6) {
                        return '密碼至少 6 個字符';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 確認新密碼
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      labelText: '確認新密碼',
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
                      if (value != _newPasswordController.text) {
                        return '密碼不一致';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // 重設密碼按鈕
                  ElevatedButton(
                    onPressed: _isLoading ? null : _resetPassword,
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
                        : const Text(
                            '重設密碼',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
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

