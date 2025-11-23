import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_styles.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedTheme = '跟隨系統';
  
  @override
  void initState() {
    super.initState();
    _loadTheme();
  }
  
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedTheme = prefs.getString('theme_mode') ?? '跟隨系統';
    });
  }
  
  Future<void> _saveTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', theme);
    setState(() {
      _selectedTheme = theme;
    });
    
    // 通知 App 更新主題
    if (mounted) {
      final app = MyApp.of(context);
      app?.changeTheme(theme);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: AppColors.getCardBackground(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.getTextPrimary(context),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '設定',
          style: TextStyle(
            color: AppColors.getTextPrimary(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context,
            title: '外觀設定',
            children: [
              _buildThemeOption(context, '跟隨系統', Icons.brightness_auto),
              _buildThemeOption(context, '淺色模式', Icons.light_mode),
              _buildThemeOption(context, '深色模式', Icons.dark_mode),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSection(BuildContext context, {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextMuted(context),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.getCardBackground(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
  
  Widget _buildThemeOption(BuildContext context, String theme, IconData icon) {
    final isSelected = _selectedTheme == theme;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _saveTheme(theme),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.15)
                      : AppColors.getTextMuted(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.getTextSecondary(context),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  theme,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.getTextPrimary(context),
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

