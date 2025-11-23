import 'package:flutter/material.dart';
import '../services/lottery_service.dart';
import '../utils/app_styles.dart';

class LotteryResultsScreen extends StatefulWidget {
  const LotteryResultsScreen({super.key});

  @override
  State<LotteryResultsScreen> createState() => _LotteryResultsScreenState();
}

class _LotteryResultsScreenState extends State<LotteryResultsScreen> {
  String _selectedType = 'lotto649';
  List<dynamic> _results = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    setState(() => _isLoading = true);

    try {
      final results = await LotteryService.getHistoricalResults(
        lotteryType: _selectedType,
        limit: 20,
      );
      setState(() => _results = results);
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

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('歷屆開獎號碼'),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 樂透類型選擇
          Container(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: LotteryService.lotteryTypes.entries.map((entry) {
                final isSelected = _selectedType == entry.key;
                final logoPath = LotteryService.getLotteryLogo(entry.key);
                
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => _selectedType = entry.key);
                        _loadResults();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected
                            ? AppColors.primary
                            : (isDark ? Colors.grey[800] : Colors.grey[200]),
                        foregroundColor: isSelected
                            ? Colors.white
                            : AppColors.getTextPrimary(context),
                        elevation: isSelected ? 2 : 0,
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (logoPath != null)
                            Image.asset(
                              logoPath,
                              width: 32,
                              height: 32,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.image_not_supported, size: 32);
                              },
                            ),
                          if (logoPath != null) const SizedBox(height: 4),
                          Text(
                            entry.value,
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // 開獎結果列表
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 64,
                              color: AppColors.getTextMuted(context),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '暫無開獎資料',
                              style: TextStyle(
                                color: AppColors.getTextMuted(context),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadResults,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _results.length,
                          itemBuilder: (context, index) {
                            final result = _results[index];
                            return _buildResultCard(result, isDark);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> result, bool isDark) {
    final numbers = List<int>.from(result['numbers'] ?? []);
    final specialNumbers = result['special_numbers'] != null
        ? List<int>.from(result['special_numbers'])
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
            // 期號和日期
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '第 ${result['draw_number'] ?? ''} 期',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  result['draw_date'] ?? '',
                  style: TextStyle(
                    color: AppColors.getTextMuted(context),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 開獎號碼
            Row(
              children: [
                Text(
                  '開獎號碼：',
                  style: TextStyle(
                    color: AppColors.getTextMuted(context),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...numbers.map((num) => _buildNumberBall(num, false)),
                      if (specialNumbers.isNotEmpty) ...[
                        const Text('+', style: TextStyle(fontSize: 16)),
                        ...specialNumbers.map((num) => _buildNumberBall(num, true)),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            // 頭獎資訊（如果有）
            if (result['jackpot'] != null) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '頭獎金額',
                    style: TextStyle(
                      color: AppColors.getTextMuted(context),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    result['jackpot'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              if (result['winners'] != null) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '頭獎人數',
                      style: TextStyle(
                        color: AppColors.getTextMuted(context),
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${result['winners']} 人',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.getTextPrimary(context),
                      ),
                    ),
                  ],
                ),
              ],
            ],
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

