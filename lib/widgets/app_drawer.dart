import 'package:flutter/material.dart';
import '../utils/app_styles.dart';
import '../screens/settings_screen.dart';
import '../screens/login_screen.dart';
import '../screens/lottery_results_screen.dart';
import '../screens/records_screen.dart';
import '../screens/my_account_screen.dart';
import '../services/conversation_service.dart';
import '../services/auth_service.dart';

class AppDrawer extends StatefulWidget {
  final VoidCallback? onClose;
  final VoidCallback? onRefreshNeeded;
  final Function(int conversationId)? onRestoreConversation;
  final Function(int conversationId)? onConversationDeleted;
  
  const AppDrawer({
    super.key, 
    this.onClose, 
    this.onRefreshNeeded,
    this.onRestoreConversation,
    this.onConversationDeleted,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _conversations = [];
  bool _isLoadingConversations = false;
  bool _isLoggedIn = false;
  Map<String, dynamic>? _userData;
  
  @override
  void initState() {
    super.initState();
    _checkLoginAndLoadConversations();
  }
  
  @override
  void didUpdateWidget(AppDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 每次側邊欄打開時重新加載對話列表
    if (_isLoggedIn) {
      _loadConversations();
    }
  }
  
  Future<void> _checkLoginAndLoadConversations() async {
    final loggedIn = await AuthService.isLoggedIn();
    setState(() => _isLoggedIn = loggedIn);
    
    if (loggedIn) {
      _loadUserData();
      _loadConversations();
    }
  }
  
  Future<void> _loadUserData() async {
    try {
      final user = await AuthService.getUser();
      setState(() => _userData = user);
    } catch (e) {
      // 靜默失敗
    }
  }
  
  Future<void> _loadConversations() async {
    setState(() => _isLoadingConversations = true);
    
    try {
      final conversations = await ConversationService.getConversations();
      
      if (mounted) {
        setState(() {
          _conversations = conversations;
        });
      }
    } catch (e) {
      // 靜默失敗
    } finally {
      if (mounted) {
        setState(() => _isLoadingConversations = false);
      }
    }
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  List<Map<String, dynamic>> get _filteredConversations {
    if (_searchQuery.isEmpty) return _conversations;
    return _conversations.where((conv) {
      final title = conv['title'] ?? '';
      return title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.8,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // 用戶資訊區域
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  widget.onClose?.call();
                  if (_isLoggedIn) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyAccountScreen(),
                      ),
                    ).then((_) => _checkLoginAndLoadConversations());
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    ).then((_) => _checkLoginAndLoadConversations());
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // 頭像（可點擊更換）
                      Stack(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withOpacity(0.1),
                            ),
                            child: Icon(
                              Icons.person,
                              color: AppColors.primary,
                              size: 32,
                            ),
                          ),
                          if (_isLoggedIn)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // 用戶資訊
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_isLoggedIn && _userData?['username'] != null)
                              Text(
                                _userData!['username'],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.getTextPrimary(context),
                                ),
                              ),
                            if (!_isLoggedIn) ...[
                              Text(
                                '訪客',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.getTextPrimary(context),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '點擊登入',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.getTextMuted(context),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: AppColors.getTextMuted(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Divider(
              height: 1,
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade300,
            ),
            
            // 選單項目
            Expanded(
              child: Column(
                children: [
                  // Logo
                  _buildLogoMenuItem(context),
                  
                  // 智能彩選分組
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      '智能彩選',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.getTextMuted(context),
                      ),
                    ),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.emoji_events,
                    title: '歷屆號碼',
                    onTap: () {
                      widget.onClose?.call();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LotteryResultsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.history,
                    title: '我的選號記錄',
                    onTap: () {
                      widget.onClose?.call();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RecordsScreen(),
                        ),
                      );
                    },
                  ),
                  
                  const Divider(height: 24),
                  
                  // 搜尋框
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: '搜尋對話...',
                        hintStyle: TextStyle(
                          color: AppColors.getTextMuted(context),
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.getTextMuted(context),
                          size: 20,
                        ),
                        filled: true,
                        fillColor: isDark 
                            ? Colors.white.withOpacity(0.05)
                            : Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      style: TextStyle(
                        color: AppColors.getTextPrimary(context),
                        fontSize: 14,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  
                  // 歷史對話列表
                  Expanded(
                    child: _isLoadingConversations
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : !_isLoggedIn
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.lock_outline,
                                      size: 48,
                                      color: AppColors.getTextMuted(context),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      '登入後查看對話記錄',
                                      style: TextStyle(
                                        color: AppColors.getTextMuted(context),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : _filteredConversations.isEmpty
                                ? Center(
                                    child: Text(
                                      _searchQuery.isEmpty ? '暫無對話記錄' : '找不到符合的對話',
                                      style: TextStyle(
                                        color: AppColors.getTextMuted(context),
                                        fontSize: 14,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    itemCount: _filteredConversations.length,
                                    itemBuilder: (context, index) {
                                      final conv = _filteredConversations[index];
                                      return _buildConversationItem(context, conv);
                                    },
                                  ),
                  ),
                  
                  const Divider(height: 1),
                  
                  // 設定
                  _buildMenuItem(
                    context,
                    icon: Icons.settings,
                    title: '設定',
                    onTap: () {
                      widget.onClose?.call();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLogoMenuItem(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            'assets/images/app_icon.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '智能彩選',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(context),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'IntelliLotto',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.getTextMuted(context),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      onTap: () {
        widget.onClose?.call();
      },
    );
  }
  
  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    bool isHighlight = false,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isHighlight ? AppColors.primary : AppColors.getTextSecondary(context),
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
          color: isHighlight ? AppColors.primary : AppColors.getTextPrimary(context),
        ),
      ),
      onTap: onTap,
    );
  }
  
  Widget _buildConversationItem(BuildContext context, Map<String, dynamic> conversation) {
    final formattedDate = ConversationService.formatDate(conversation['updated_at']);
    final title = conversation['title'] ?? '未命名對話';
    
    // 解析標題格式: "ChatGPT - 大樂透 (冷熱號分析)"
    String aiModel = '';
    String lotteryType = '';
    String strategy = '';
    String? aiLogo;
    String? lotteryLogo;
    
    try {
      if (title.contains(' - ') && title.contains('(') && title.contains(')')) {
        // 分離 AI 模型和其他部分
        final parts = title.split(' - ');
        if (parts.length >= 2) {
          aiModel = parts[0].trim();
          
          // 分離彩票類型和策略
          final rest = parts[1];
          final openParen = rest.indexOf('(');
          final closeParen = rest.indexOf(')');
          
          if (openParen > 0 && closeParen > openParen) {
            lotteryType = rest.substring(0, openParen).trim();
            strategy = rest.substring(openParen + 1, closeParen).trim();
            
            // 獲取 AI logo
            if (aiModel == 'ChatGPT') {
              aiLogo = 'assets/images/gpt_logo.png';
            } else if (aiModel == 'Claude') {
              aiLogo = 'assets/images/claude_logo.png';
            } else if (aiModel == 'Gemini') {
              aiLogo = 'assets/images/gemini_logo.png';
            }
            
            // 獲取彩票 logo
            if (lotteryType == '大樂透') {
              lotteryLogo = 'assets/images/大樂透.png';
            } else if (lotteryType == '威力彩') {
              lotteryLogo = 'assets/images/威力彩.png';
            } else if (lotteryType == '今彩539') {
              lotteryLogo = 'assets/images/539.png';
            }
          }
        }
      }
    } catch (e) {
      // 解析失敗，使用默認顯示
    }
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          widget.onClose?.call();
          // 恢復對話記錄
          final conversationId = conversation['id'];
          if (conversationId != null) {
            widget.onRestoreConversation?.call(conversationId);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AI logo (放大)
              if (aiLogo != null)
                Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Image.asset(
                    aiLogo,
                    fit: BoxFit.contain,
                  ),
                )
              else
                Icon(
                  Icons.chat_bubble_outline,
                  size: 48,
                  color: AppColors.getTextMuted(context),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // AI 模型名稱
                    if (aiModel.isNotEmpty)
                      Text(
                        aiModel,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    const SizedBox(height: 6),
                    // 彩票類型 + logo
                    if (lotteryType.isNotEmpty)
                      Row(
                        children: [
                          if (lotteryLogo != null) ...[
                            Image.asset(
                              lotteryLogo,
                              width: 18,
                              height: 18,
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            lotteryType,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.getTextPrimary(context),
                            ),
                          ),
                          if (strategy.isNotEmpty) ...[
                            Text(
                              ' • ',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.getTextMuted(context),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                strategy,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.getTextMuted(context),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    // 如果解析失敗，顯示原始標題
                    if (aiModel.isEmpty)
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextPrimary(context),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 6),
                    // 時間
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: AppColors.getTextMuted(context),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.getTextMuted(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // 刪除按鈕
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                color: AppColors.getTextMuted(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('刪除對話'),
                      content: const Text('確定要刪除這個對話嗎？'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('取消'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('刪除', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true && mounted) {
                    try {
                      final conversationId = conversation['id'];
                      await ConversationService.deleteConversation(conversationId);
                      _loadConversations();
                      
                      // 通知父組件對話已被刪除
                      widget.onConversationDeleted?.call(conversationId);
                    } catch (e) {
                      // 靜默失敗
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

