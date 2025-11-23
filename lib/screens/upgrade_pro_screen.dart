import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

class UpgradeProScreen extends StatelessWidget {
  const UpgradeProScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
            // Logo
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Image.asset(
                'assets/images/app_icon.png',
                width: 100,
                height: 100,
                fit: BoxFit.contain,
              ),
            ),
            
            // 標題
            const Text(
              '取得 IntelliLotto PRO',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '解鎖所有進階功能，讓 AI 助您一臂之力',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.getTextMuted(context),
              ),
            ),
            const SizedBox(height: 40),
            
            // 功能對比表格（統一圓框）
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // 標題行：功能 | 免費版 | PRO版
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              '功能',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.getTextPrimary(context),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  '免費版',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '目前方案',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  'PRO 版',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Icon(
                                  Icons.workspace_premium,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
                    
                    // 功能列表
                    _buildFeatureItem(context, feature: 'AI 選號次數', free: '每日 5 次', pro: '無限次', isDark: isDark),
                    _buildFeatureItem(context, feature: 'AI 模型選擇', free: '僅 ChatGPT', pro: '全部模型', isDark: isDark),
                    _buildFeatureItem(context, feature: '對話記錄保存', free: '最近 10 筆', pro: '無限保存', isDark: isDark),
                    _buildFeatureItem(context, feature: '歷屆號碼分析', free: '基礎分析', pro: '深度分析', isDark: isDark),
                    _buildFeatureItem(context, feature: '號碼趨勢圖表', free: '✕', pro: '✓', isDark: isDark, isLast: false),
                    _buildFeatureItem(context, feature: '專屬客服支援', free: '✕', pro: '✓', isDark: isDark, isLast: false),
                    _buildFeatureItem(context, feature: '無廣告體驗', free: '✕', pro: '✓', isDark: isDark, isLast: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 100), // 留空間給底部按鈕
                ],
              ),
            ),
          ),
          
          // 固定在底部的按鈕區域
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 價格顯示
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NT\$ ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          'XXX',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            height: 1.0,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            ' / 月',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.getTextMuted(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '* 價格尚未確定，敬請期待',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.getTextMuted(context),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 升級按鈕
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          _showComingSoonDialog(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.workspace_premium,
                              color: Colors.white,
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Text(
                              '立即升級 PRO',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildFeatureItem(
    BuildContext context, {
    required String feature,
    required String free,
    required String pro,
    required bool isDark,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  feature,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.getTextPrimary(context),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  free,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: free == '✕'
                        ? Colors.red.withOpacity(0.6)
                        : AppColors.getTextSecondary(context),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  pro,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: pro == '✓' ? Colors.green : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 20,
            endIndent: 20,
            color: Colors.grey.withOpacity(0.2),
          ),
      ],
    );
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('即將推出'),
        content: const Text('PRO 會員功能正在開發中，敬請期待！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }
}

