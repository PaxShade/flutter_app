import 'package:flutter/material.dart';
import '../models/user.dart';
import 'home_screen.dart';
import 'all_movies_screen.dart';
import 'favorites_screen.dart';
import 'account_screen.dart';

class MainScreen extends StatefulWidget {
  final User user;
  final VoidCallback onLogout;
  final List<String> favoriteIds;
  final Function(String) onToggleFavorite;
  final bool isDarkMode;
  final Function(bool) onThemeChanged;
  final Function(String) onAvatarChanged;

  const MainScreen({
    super.key,
    required this.user,
    required this.onLogout,
    required this.favoriteIds,
    required this.onToggleFavorite,
    required this.isDarkMode,
    required this.onThemeChanged,
    required this.onAvatarChanged,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(favoriteIds: widget.favoriteIds, onToggleFavorite: widget.onToggleFavorite),
      AllMoviesScreen(favoriteIds: widget.favoriteIds, onToggleFavorite: widget.onToggleFavorite),
      FavoritesScreen(favoriteIds: widget.favoriteIds, onToggleFavorite: widget.onToggleFavorite),
      AccountScreen(
        user: widget.user,
        onLogout: widget.onLogout,
        favoritesCount: widget.favoriteIds.length,
        isDarkMode: widget.isDarkMode,
        onThemeChanged: widget.onThemeChanged,
        onAvatarChanged: widget.onAvatarChanged,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        indicatorColor: const Color(0xFF7C4DFF).withValues(alpha: 0.25),
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: Color(0xFF7C4DFF)),
            label: 'Главная',
          ),
          NavigationDestination(
            icon: Icon(Icons.movie_outlined),
            selectedIcon: Icon(Icons.movie_rounded, color: Color(0xFF7C4DFF)),
            label: 'Каталог',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline_rounded),
            selectedIcon: Icon(Icons.favorite_rounded, color: Color(0xFFFF4081)),
            label: 'Избранное',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: Color(0xFF7C4DFF)),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}
