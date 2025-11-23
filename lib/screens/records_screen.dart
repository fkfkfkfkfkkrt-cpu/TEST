import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_styles.dart';
import 'login_screen.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  bool _isLoggedIn = false;
  bool _isLoading = true;
  List<Map<String, dynamic>> _records = [];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final loggedIn = await AuthService.isLoggedIn();
    setState(() {
      _isLoggedIn = loggedIn;
      _isLoading = false;
    });

    if (loggedIn) {
      _loadRecords();
    }
  }

  Future<void> _loadRecords() async {
    setState(() => _isLoading = true);

    try {
      // TODO: 從後端 API 獲取選號記錄
      // final records = await ConversationService.getSelectionHistory();
      // setState(() => _records = records);
      
      // 目前沒有選號記錄，顯示空狀態
      setState(() {
        _records = [];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('載入失敗: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: const Text('我的選號記錄'),
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isLoggedIn) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: const Text('我的選號記錄'),
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 80,
                color: AppColors.getTextMuted(context),
              ),
              const SizedBox(height: 24),
              Text(
                '請先登入查看選號記錄',
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
                  ).then((_) => _checkLoginStatus());
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
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
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
        title: const Text('我的選號記錄'),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
      ),
      body: _records.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 80,
                    color: AppColors.getTextMuted(context),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '還沒有選號記錄',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.getTextPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '開始使用 AI 選號吧！',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.getTextMuted(context),
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadRecords,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _records.length,
                itemBuilder: (context, index) {
                  final record = _records[index];
                  return _buildRecordCard(record, isDark);
                },
              ),
            ),
    );
  }

  Widget _buildRecordCard(Map<String, dynamic> record, bool isDark) {
    final numbers = List<int>.from(record['numbers'] ?? []);
    final specialNumbers = record['special_numbers'] != null
        ? List<int>.from(record['special_numbers'])
        : <int>[];

    return Card(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 樂透類型和日期
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    record['lottery_type'] ?? '',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  record['created_at'] ?? '',
                  style: TextStyle(
                    color: AppColors.getTextMuted(context),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 選號策略
            if (record['strategy'] != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.psychology_outlined,
                    size: 16,
                    color: AppColors.getTextMuted(context),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    record['strategy'],
                    style: TextStyle(
                      color: AppColors.getTextMuted(context),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // 選號
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...numbers.map((num) => _buildNumberBall(num, false)),
                if (specialNumbers.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text('+', style: TextStyle(fontSize: 16)),
                  ),
                  ...specialNumbers.map((num) => _buildNumberBall(num, true)),
                ],
              ],
            ),
            const SizedBox(height: 12),

            // 操作按鈕
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    // TODO: 分享功能
                  },
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('分享'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.getTextMuted(context),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {
                    // TODO: 刪除功能
                  },
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('刪除'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberBall(int number, bool isSpecial) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSpecial ? Colors.red : AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: (isSpecial ? Colors.red : AppColors.primary).withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          number.toString().padLeft(2, '0'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

