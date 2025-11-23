import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_styles.dart';
import 'login_screen.dart';
import 'chat_screen.dart';
import 'upgrade_pro_screen.dart';

class MyAccountScreen extends StatefulWidget {
  const MyAccountScreen({super.key});

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  Map<String, dynamic>? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      final user = await AuthService.getUser();
      setState(() => _user = user);
    } catch (e) {
      // 靜默失敗
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認登出'),
        content: const Text('確定要登出嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('登出', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ChatScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: const Text('我的帳戶'),
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_user == null) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: const Text('我的帳戶'),
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_outline,
                size: 80,
                color: AppColors.getTextMuted(context),
              ),
              const SizedBox(height: 24),
              Text(
                '請先登入',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.getTextPrimary(context),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  ).then((_) => _loadUserData());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '立即登入',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('我的帳戶'),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 用戶資訊卡片
            Card(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // 頭像
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withOpacity(0.1),
                      ),
                      child: Icon(
                        Icons.person,
                        color: AppColors.primary,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 用戶名
                    Text(
                      _user!['username'] ?? '用戶',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // 郵箱
                    Text(
                      _user!['email'] ?? '',
                      style: TextStyle(
                        color: AppColors.getTextMuted(context),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 會員資訊
                    _buildInfoItem(
                      context,
                      icon: Icons.card_membership,
                      label: _user!['membership_level'] ?? 'FREE',
                      subtitle: '會員等級',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 功能選項
            Card(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildMenuItem(
                context,
                icon: Icons.workspace_premium,
                title: '升級 PRO',
                subtitle: '解鎖更多功能',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UpgradeProScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            
            // 登出按鈕
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '登出',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 28),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: AppColors.getTextMuted(context),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

