import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import 'login_screen.dart';
import 'main_screen.dart';

class RootScreen extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const RootScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  User? _currentUser;
  List<String> _favoriteIds = [];
  bool _isCheckingSession = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreSession();
    });
  }

  Future<void> _restoreSession() async {
    final savedUser = await AuthService.getSavedUser();
    if (savedUser != null) {
      final favs = await StorageService.loadFavorites(savedUser.id);
      if (mounted) {
        setState(() {
          _currentUser = savedUser;
          _favoriteIds = favs;
          _isCheckingSession = false;
        });
        return;
      }
    }
    if (mounted) {
      setState(() => _isCheckingSession = false);
    }
  }

  Future<void> _handleLoginSuccess(User user) async {
    final favs = await StorageService.loadFavorites(user.id);
    if (mounted) {
      setState(() {
        _currentUser = user;
        _favoriteIds = favs;
      });
    }
  }

  Future<void> _handleLogout() async {
    await AuthService.clearSession();
    if (mounted) {
      setState(() {
        _currentUser = null;
        _favoriteIds = [];
      });
    }
  }

  void _toggleFavorite(String movieId) {
    if (_currentUser == null) return;
    setState(() {
      if (_favoriteIds.contains(movieId)) {
        _favoriteIds.remove(movieId);
      } else {
        _favoriteIds.add(movieId);
      }
    });
    StorageService.saveFavorites(_currentUser!.id, _favoriteIds);
  }

  Future<void> _handleAvatarChanged(String newUrl) async {
    if (_currentUser == null) return;
    await AuthService.updateAvatar(_currentUser!.id, newUrl);
    setState(() {
      _currentUser!.avatarUrl = newUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingSession) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_currentUser != null) {
      return MainScreen(
        user: _currentUser!,
        onLogout: _handleLogout,
        favoriteIds: _favoriteIds,
        onToggleFavorite: _toggleFavorite,
        isDarkMode: widget.isDarkMode,
        onThemeChanged: widget.onThemeChanged,
        onAvatarChanged: _handleAvatarChanged,
      );
    }

    return LoginScreen(onLoginSuccess: _handleLoginSuccess);
  }
}
