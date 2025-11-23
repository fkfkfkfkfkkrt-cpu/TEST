import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/chat_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
  
  static MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<MyAppState>();
}

class MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isFirstLaunch = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString('theme_mode') ?? '跟隨系統';
    final hasLaunched = prefs.getBool('has_launched') ?? false;
    
    setState(() {
      _themeMode = _getThemeModeFromString(themeName);
      _isFirstLaunch = !hasLaunched;
      _isLoading = false;
    });
    
    if (!hasLaunched) {
      await prefs.setBool('has_launched', true);
    }
  }

  ThemeMode _getThemeModeFromString(String themeName) {
    switch (themeName) {
      case '淺色模式':
        return ThemeMode.light;
      case '深色模式':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  void changeTheme(String themeName) {
    setState(() {
      _themeMode = _getThemeModeFromString(themeName);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
    
    return MaterialApp(
      title: '智能彩選',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      home: _isFirstLaunch ? const LoginScreen() : const ChatScreen(),
    );
  }
}

