import 'package:flutter/material.dart';
import 'screens/root_screen.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final initialDark = await StorageService.loadIsDarkMode();
  runApp(CineVaultApp(initialDarkMode: initialDark));
}

class CineVaultApp extends StatefulWidget {
  final bool initialDarkMode;
  const CineVaultApp({super.key, required this.initialDarkMode});

  @override
  State<CineVaultApp> createState() => _CineVaultAppState();
}

class _CineVaultAppState extends State<CineVaultApp> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.initialDarkMode;
  }

  void _toggleTheme(bool isDark) {
    setState(() => _isDarkMode = isDark);
    StorageService.saveIsDarkMode(isDark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CineVault',
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      // Светлая тема
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C4DFF),
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
      ),
      // Темная тема
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF12121A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C4DFF),
          brightness: Brightness.dark,
          surface: const Color(0xFF1E1E2C),
        ),
        fontFamily: 'Roboto',
      ),
      home: RootScreen(
        isDarkMode: _isDarkMode,
        onThemeChanged: _toggleTheme,
      ),
    );
  }
}
