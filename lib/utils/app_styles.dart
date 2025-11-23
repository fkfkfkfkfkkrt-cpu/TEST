import 'package:flutter/material.dart';

class AppColors {
  // 主色調
  static const Color primary = Color(0xFF6366F1);
  static const Color secondary = Color(0xFF8B5CF6);
  
  // 文字顏色
  static Color getTextPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : const Color(0xFF1F2937);
  }
  
  static Color getTextSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withOpacity(0.7)
        : const Color(0xFF4B5563);
  }
  
  static Color getTextMuted(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withOpacity(0.5)
        : const Color(0xFF9CA3AF);
  }
  
  // 背景顏色
  static Color getCardBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF1E1E1E)
        : Colors.white;
  }
  
  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
}

