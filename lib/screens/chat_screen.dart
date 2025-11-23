import 'package:flutter/material.dart';
import '../utils/app_styles.dart';
import '../widgets/app_drawer.dart';
import '../services/auth_service.dart';
import '../services/ai_service.dart';
import '../services/conversation_service.dart';
import 'login_screen.dart';
import 'my_account_screen.dart';
import 'upgrade_pro_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _needsConversationRefresh = false;
  bool _isDrawerOpen = false;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  bool _hasGenerated = false; // 是否已生成過號碼
  int? _currentConversationId; // 當前顯示的對話 ID
  
  // AI 選號配置
  String _selectedAI = 'ChatGPT';
  String _selectedLottery = '大樂透';
  String _selectedStrategy = '冷熱號分析';
  
  // 聊天訊息
  final List<Map<String, dynamic>> _messages = [];
  
  // AI 平台列表
  final List<Map<String, String>> _aiPlatforms = [
    {'name': 'ChatGPT', 'model': 'GPT 5.1', 'logo': 'assets/images/gpt_logo.png'},
    {'name': 'Claude', 'model': 'Sonnet 4.5', 'logo': 'assets/images/claude_logo.png'},
    {'name': 'Gemini', 'model': '3 Pro', 'logo': 'assets/images/gemini_logo.png'},
  ];
  
  // 彩票類型列表
  final List<Map<String, String>> _lotteryTypes = [
    {'name': '大樂透', 'logo': 'assets/images/大樂透.png'},
    {'name': '威力彩', 'logo': 'assets/images/威力彩.png'},
    {'name': '今彩539', 'logo': 'assets/images/539.png'},
  ];
  
  // 策略列表
  final List<Map<String, dynamic>> _strategies = [
    {'name': '冷熱號分析', 'icon': Icons.whatshot_rounded, 'color': Colors.red},
    {'name': '號碼分佈', 'icon': Icons.grid_on_rounded, 'color': Colors.blue},
    {'name': '奇偶搭配', 'icon': Icons.balance_rounded, 'color': Colors.green},
  ];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final loggedIn = await AuthService.isLoggedIn();
    setState(() => _isLoggedIn = loggedIn);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    // 防止重複點擊
    if (_isLoading) return;
    if (_messageController.text.trim().isEmpty) return;
    if (!_hasGenerated) return;
    
    final userMessage = _messageController.text.trim();
    _messageController.clear();
    
    setState(() {
      _messages.add({
        'role': 'user',
        'content': userMessage,
        'timestamp': DateTime.now(),
      });
      _isLoading = true;
    });
    
    _scrollToBottom();
    
    try {
      final aiResponse = await AIService.chatWithAI(
        message: userMessage,
        aiPlatform: _selectedAI,
      );
      
      if (mounted) {
        setState(() {
          _messages.add({
            'role': 'ai',
            'content': aiResponse,
            'timestamp': DateTime.now(),
          });
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  void _clearAndRestart() {
    // 防止重複點擊
    if (_isLoading) return;
    
    // 只有在有真正的對話時才保存（至少有 1 則用戶訊息）
    // 生成號碼的 AI 回覆不算對話，只有用戶主動發送訊息才算
    final hasUserMessages = _messages.any((msg) => msg['role'] == 'user');
    if (_messages.isNotEmpty && hasUserMessages) {
      _saveConversationToHistory();
    }
    
    // 清除狀態，重新開始
    setState(() {
      _messages.clear();
      _hasGenerated = false;
      _currentConversationId = null; // 清除當前對話 ID
    });
  }
  
  Future<void> _saveConversationToHistory() async {
    try {
      // 過濾出有效的訊息（有 content 的訊息）
      final validMessages = _messages.where((msg) => 
        msg['content'] != null && msg['content'].toString().trim().isNotEmpty
      ).toList();
      
      if (validMessages.isEmpty) {
        return;
      }
      
      // 生成包含元數據的標題
      final title = '$_selectedAI - $_selectedLottery ($_selectedStrategy)';
      
      await ConversationService.saveConversation(
        messages: validMessages,
        title: title,
      );
      
      // 觸發側邊欄刷新
      setState(() {
        _needsConversationRefresh = !_needsConversationRefresh;
      });
      
    } catch (e) {
      // 靜默失敗
    }
  }
  
  void _generateNumbers() async {
    // 防止重複點擊
    if (_isLoading) return;
    
    if (!_isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      ).then((_) => _checkLoginStatus());
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final result = await AIService.generateNumbers(
        lotteryType: _selectedLottery,
        strategy: _selectedStrategy,
        aiPlatform: _selectedAI,
      );
      
      if (mounted) {
        setState(() {
          _messages.add({
            'role': 'ai',
            'content': result['analysis'] ?? '已為您生成 $_selectedLottery 號碼',
            'numbers': result['numbers'],
            'specialNumbers': result['special_numbers'],
            'timestamp': DateTime.now(),
          });
          _isLoading = false;
          _hasGenerated = true;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
    });
  }
  
  void _handleConversationDeleted(int deletedConversationId) {
    // 如果刪除的是當前正在顯示的對話，清空畫面
    if (_currentConversationId == deletedConversationId) {
      setState(() {
        _messages.clear();
        _hasGenerated = false;
        _currentConversationId = null;
      });
    }
  }
  
  Future<void> _restoreConversation(int conversationId) async {
    setState(() => _isLoading = true);
    
    try {
      // 獲取對話詳情
      final conversation = await ConversationService.getConversation(conversationId);
      
      if (mounted) {
        setState(() {
          // 清除當前訊息
          _messages.clear();
          
          // 設置當前對話 ID
          _currentConversationId = conversationId;
          
          // 從標題解析配置 (格式: "ChatGPT - 大樂透 (冷熱號分析)")
          final title = conversation['title'] as String?;
          if (title != null && title.contains(' - ') && title.contains('(') && title.contains(')')) {
            try {
              final parts = title.split(' - ');
              if (parts.length >= 2) {
                _selectedAI = parts[0].trim();
                
                final rest = parts[1];
                final openParen = rest.indexOf('(');
                final closeParen = rest.indexOf(')');
                
                if (openParen > 0 && closeParen > openParen) {
                  _selectedLottery = rest.substring(0, openParen).trim();
                  _selectedStrategy = rest.substring(openParen + 1, closeParen).trim();
                }
              }
            } catch (e) {
              // 解析失敗，使用默認值
            }
          }
          
          // 恢復對話訊息
          final messages = conversation['messages'] as List<dynamic>?;
          if (messages != null) {
            for (var msg in messages) {
              _messages.add({
                'role': msg['role'] == 'user' ? 'user' : 'ai',
                'content': msg['content'],
                'timestamp': DateTime.tryParse(msg['created_at'] ?? '') ?? DateTime.now(),
              });
            }
          }
          
          _hasGenerated = _messages.isNotEmpty;
          _isLoading = false;
        });
        
        // 滾動到底部
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final drawerWidth = screenWidth * 0.85;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          // 側邊欄
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            left: _isDrawerOpen ? 0 : -drawerWidth,
            top: 0,
            bottom: 0,
            width: drawerWidth,
            child: AppDrawer(
              onClose: _toggleDrawer,
              onRestoreConversation: _restoreConversation,
              onConversationDeleted: _handleConversationDeleted,
              key: ValueKey(_needsConversationRefresh), // 強制重建以刷新數據
            ),
          ),
          // 主頁面
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            left: _isDrawerOpen ? drawerWidth : 0,
            top: 0,
            bottom: 0,
            right: _isDrawerOpen ? -drawerWidth : 0,
            child: _buildMainContent(context, isDark),
          ),
          // 遮罩層（側邊欄打開時）
          if (_isDrawerOpen)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              left: drawerWidth,
              top: 0,
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _toggleDrawer,
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildMainContent(BuildContext context, bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
      child: SafeArea(
        child: Column(
          children: [
            // 頂部工具列
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.menu,
                      color: AppColors.getTextPrimary(context),
                    ),
                    onPressed: _toggleDrawer,
                  ),
                  const Spacer(),
                  _isLoggedIn
                      ? GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const UpgradeProScreen(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.secondary,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.workspace_premium,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  '升級 PRO',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            ).then((_) => _checkLoginStatus());
                          },
                          child: Text(
                            '登入/註冊',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                  const Spacer(),
                  const SizedBox(width: 48), // 平衡左側按鈕
                ],
              ),
            ),
            
            // 配置選擇區域
            if (!_hasGenerated) _buildConfigSection(isDark),
            
            // 聊天訊息區域
            Expanded(
              child: _messages.isEmpty
                  ? _buildEmptyState(isDark)
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length + (_isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length) {
                          return _buildLoadingMessage(isDark);
                        }
                        return _buildMessage(_messages[index], isDark);
                      },
                    ),
            ),
            
            // 輸入框區域
            _buildInputArea(isDark),
          ],
        ),
      ),
    );
  }
  
  Widget _buildConfigSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI 平台選擇
          Text(
            'AI 平台',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(context),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: _aiPlatforms.map((platform) {
              final isSelected = _selectedAI == platform['name'];
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedAI = platform['name']!),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.1)
                          : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade300),
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Image.asset(
                          platform['logo']!,
                          width: 32,
                          height: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          platform['name']!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.getTextPrimary(context),
                          ),
                        ),
                        Text(
                          platform['model']!,
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.getTextMuted(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          
          // 彩票類型選擇
          Text(
            '彩票類型',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(context),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: _lotteryTypes.map((lottery) {
              final isSelected = _selectedLottery == lottery['name'];
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedLottery = lottery['name']!),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.1)
                          : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade300),
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Image.asset(
                          lottery['logo']!,
                          width: 40,
                          height: 40,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          lottery['name']!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.getTextPrimary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          
          // 策略選擇
          Text(
            '選號策略',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(context),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: _strategies.map((strategy) {
              final isSelected = _selectedStrategy == strategy['name'];
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedStrategy = strategy['name'] as String),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.1)
                          : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade300),
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          strategy['icon'] as IconData,
                          color: isSelected
                              ? AppColors.primary
                              : (strategy['color'] as Color),
                          size: 28,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          strategy['name'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.getTextPrimary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 64,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'AI 智能選號',
            style: TextStyle(
              color: AppColors.getTextPrimary(context),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '選擇 AI 平台、彩票類型和策略\n點擊下方按鈕開始生成號碼',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.getTextMuted(context),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _generateNumbers,
            icon: _isLoading 
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(_isLoading ? '生成中...' : '生成號碼'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey,
              disabledForegroundColor: Colors.white70,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInputArea(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (_hasGenerated)
            Container(
              decoration: BoxDecoration(
                color: isDark 
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.restart_alt_rounded,
                  color: _isLoading ? Colors.grey : AppColors.primary,
                ),
                onPressed: _isLoading ? null : _clearAndRestart,
                tooltip: '重新開始',
              ),
            ),
          if (_hasGenerated) const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(left: 20, right: 4, top: 4, bottom: 4),
              decoration: BoxDecoration(
                color: isDark 
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      enabled: _hasGenerated && !_isLoading,
                      decoration: InputDecoration(
                        hintText: _hasGenerated ? '輸入訊息...' : '請先生成號碼',
                        hintStyle: TextStyle(
                          color: AppColors.getTextMuted(context),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                      style: TextStyle(
                        color: AppColors.getTextPrimary(context),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.8),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                      onPressed: _hasGenerated && !_isLoading
                          ? (_messages.isEmpty ? _generateNumbers : _sendMessage)
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMessage(Map<String, dynamic> message, bool isDark) {
    final isUser = message['role'] == 'user';
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.smart_toy, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.primary
                    : (isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message['content'],
                    style: TextStyle(
                      color: isUser
                          ? Colors.white
                          : AppColors.getTextPrimary(context),
                      fontSize: 14,
                    ),
                  ),
                  if (message['numbers'] != null) ...[
                    const SizedBox(height: 12),
                    _buildNumbersDisplay(message, isDark),
                  ],
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.secondary,
              child: const Icon(Icons.person, size: 18, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildNumbersDisplay(Map<String, dynamic> message, bool isDark) {
    final numbers = message['numbers'] as List<dynamic>?;
    final specialNumbers = message['specialNumbers'] as List<dynamic>?;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '主要號碼',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextMuted(context),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: numbers?.map((num) {
              return Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$num',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              );
            }).toList() ?? [],
          ),
          if (specialNumbers != null && specialNumbers.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              '特別號',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextMuted(context),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: specialNumbers.map((num) {
                return Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$num',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildLoadingMessage(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.smart_toy, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'AI 思考中...',
                  style: TextStyle(
                    color: AppColors.getTextMuted(context),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
