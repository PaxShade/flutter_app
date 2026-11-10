import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RootScreen(),
    ),
  );
}

// --- МОДЕЛЬ ДАННЫХ ФИЛЬМА ---
class Movie {
  final String id;
  final String title;
  final String category;
  final int year;
  final double rating;

  const Movie({
    required this.id,
    required this.title,
    required this.category,
    required this.year,
    required this.rating,
  });
}

// --- ЛОКАЛЬНАЯ БАЗА ДАННЫХ ФИЛЬМОВ ---
const List<Movie> dummyMovies = [
  Movie(id: '1', title: 'Интерстеллар', category: 'Фантастика', year: 2014, rating: 8.6),
  Movie(id: '2', title: 'Начало', category: 'Фантастика', year: 2010, rating: 8.7),
  Movie(id: '3', title: 'Зеленая миля', category: 'Драма', year: 1999, rating: 9.1),
  Movie(id: '4', title: 'Побег из Шоушенка', category: 'Драма', year: 1994, rating: 9.2),
  Movie(id: '5', title: 'Темный рыцарь', category: 'Боевик', year: 2008, rating: 8.5),
  Movie(id: '6', title: 'Джентльмены', category: 'Комедия', year: 2019, rating: 8.5),
  Movie(id: '7', title: '1+1', category: 'Комедия', year: 2011, rating: 8.8),
];

// --- КОРНЕВОЙ ЭКРАН (Управление авторизацией и загрузкой) ---
class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  bool _isAuthorized = false;
  List<String> _favoriteIds = [];
  bool _isLoadingFavorites = true;

  @override
  void initState() {
    super.initState();
    _loadFavoritesFromFile();
  }

  // Получение пути к файлу
  Future<File> _getFavoritesFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/favorites_movies.json');
  }

  // Чтение избранного из файла
  Future<void> _loadFavoritesFromFile() async {
    try {
      final file = await _getFavoritesFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(content);
        setState(() {
          _favoriteIds = jsonList.map((e) => e.toString()).toList();
        });
      }
    } catch (e) {
      debugPrint("Ошибка чтения файла избранного: $e");
    } finally {
      setState(() {
        _isLoadingFavorites = false;
      });
    }
  }

  // Сохранение избранного в файл
  Future<void> _saveFavoritesToFile(List<String> updatedFavorites) async {
    try {
      final file = await _getFavoritesFile();
      await file.writeAsString(jsonEncode(updatedFavorites));
    } catch (e) {
      debugPrint("Ошибка записи файла избранного: $e");
    }
  }

  void _toggleFavorite(String movieId) {
    setState(() {
      if (_favoriteIds.contains(movieId)) {
        _favoriteIds.remove(movieId);
      } else {
        _favoriteIds.add(movieId);
      }
    });
    _saveFavoritesToFile(_favoriteIds);
  }

  void _login() => setState(() => _isAuthorized = true);
  void _logout() => setState(() => _isAuthorized = false);

  @override
  Widget build(BuildContext context) {
    if (_isLoadingFavorites) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_isAuthorized) {
      return MainScreen(
        onLogout: _logout,
        favoriteIds: _favoriteIds,
        onToggleFavorite: _toggleFavorite,
      );
    }
    return LoginScreen(onLogin: _login);
  }
}

// --- ЭКРАН АВТОРИЗАЦИИ (Вход: admin / admin) ---
class LoginScreen extends StatefulWidget {
  final VoidCallback onLogin;
  const LoginScreen({super.key, required this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';

  void _submit() {
    if (_loginController.text == 'admin' && _passwordController.text == 'admin') {
      setState(() => _errorMessage = '');
      widget.onLogin();
    } else {
      setState(() => _errorMessage = 'Неверный логин или пароль!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Авторизация'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _loginController,
                decoration: const InputDecoration(labelText: 'Логин (admin)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Пароль (admin)'),
              ),
              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(_errorMessage, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Войти'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- ГЛАВНЫЙ ЭКРАН С НАВИГАЦИЕЙ (4 вкладки) ---
class MainScreen extends StatefulWidget {
  final VoidCallback onLogout;
  final List<String> favoriteIds;
  final Function(String) onToggleFavorite;

  const MainScreen({
    super.key,
    required this.onLogout,
    required this.favoriteIds,
    required this.onToggleFavorite,
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
      AccountScreen(onLogout: widget.onLogout),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Главная"),
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: "Все фильмы"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Избранное"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Аккаунт"),
        ],
      ),
    );
  }
}

// --- 1. ГЛАВНАЯ СТРАНИЦА (Рекомендации / Топ) ---
class HomeScreen extends StatelessWidget {
  final List<String> favoriteIds;
  final Function(String) onToggleFavorite;

  const HomeScreen({super.key, required this.favoriteIds, required this.onToggleFavorite});

  @override
  Widget build(BuildContext context) {
    final topMovies = List<Movie>.from(dummyMovies)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    final recommendations = topMovies.take(3).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Главная'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Лучшие фильмы для вас:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: recommendations.length,
                itemBuilder: (context, index) {
                  final movie = recommendations[index];
                  final isFav = favoriteIds.contains(movie.id);
                  return Card(
                    child: ListTile(
                      title: Text(movie.title),
                      subtitle: Text('${movie.category} • ${movie.year} • ⭐ ${movie.rating}'),
                      trailing: IconButton(
                        icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.red : null),
                        onPressed: () => onToggleFavorite(movie.id),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 2. СТРАНИЦА ВСЕХ ФИЛЬМОВ (С фильтрацией и сортировкой) ---
class AllMoviesScreen extends StatefulWidget {
  final List<String> favoriteIds;
  final Function(String) onToggleFavorite;

  const AllMoviesScreen({super.key, required this.favoriteIds, required this.onToggleFavorite});

  @override
  State<AllMoviesScreen> createState() => _AllMoviesScreenState();
}

class _AllMoviesScreenState extends State<AllMoviesScreen> {
String _selectedCategory = 'Все';
String _selectedSort = 'По названию';

@override
Widget build(BuildContext context) {
// 1. Фильтрация
List<Movie> filteredMovies = dummyMovies.where((movie) {
if (_selectedCategory == 'Все') return true;
return movie.category == _selectedCategory;
}).toList();

// 2. Сортировка
if (_selectedSort == 'По названию') {
filteredMovies.sort((a, b) => a.title.compareTo(b.title));
} else if (_selectedSort == 'По рейтингу') {
filteredMovies.sort((a, b) => b.rating.compareTo(a.rating));
} else if (_selectedSort == 'По году') {
filteredMovies.sort((a, b) => b.year.compareTo(a.year));
}

return Scaffold(
appBar: AppBar(title: const Text('Все фильмы'), centerTitle: true),
body: Column(
  children: [
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DropdownButton(
            value: _selectedCategory,
            onChanged: (value) => setState(() => _selectedCategory = value!),
            items: ['Все', 'Фантастика', 'Драма', 'Боевик', 'Комедия']
                .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                .toList(),
          ),
          DropdownButton(
            value: _selectedSort,
            onChanged: (value) => setState(() => _selectedSort = value!),
            items: ['По названию', 'По рейтингу', 'По году']
                .map((sort) => DropdownMenuItem(value: sort, child: Text(sort)))
                .toList(),
          ),
        ],
      ),
    ),
    Expanded(
      child: ListView.builder(
        itemCount: filteredMovies.length,
        itemBuilder: (context, index) {
          final movie = filteredMovies[index];
          final isFav = widget.favoriteIds.contains(movie.id);
          return ListTile(
            title: Text(movie.title),
            subtitle: Text('${movie.category} • ${movie.year} • ⭐ ${movie.rating}'),
            trailing: IconButton(
              icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.red : null),
              onPressed: () => widget.onToggleFavorite(movie.id),
            ),
          );
        },
      ),
    ),
  ],
),
);
}
}
// --- 3. СТРАНИЦА ИЗБРАННОГО ---
class FavoritesScreen extends StatelessWidget {
  final List favoriteIds;
  final Function(String) onToggleFavorite;
  const FavoritesScreen({super.key, required this.favoriteIds, required this.onToggleFavorite});
  @override
  Widget build(BuildContext context) {
    final favMovies = dummyMovies.where((m) => favoriteIds.contains(m.id)).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Избранное'), centerTitle: true),
      body: favMovies.isEmpty
          ? const Center(child: Text('У вас пока нет избранных фильмов.'))
          : ListView.builder(
        itemCount: favMovies.length,
        itemBuilder: (context, index) {
          final movie = favMovies[index];
          return ListTile(
            title: Text(movie.title),
            subtitle: Text('${movie.category} • ${movie.year}'),
            trailing: IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: () => onToggleFavorite(movie.id),
            ),
          );
        },
      ),
    );
  }
}
// --- 4. ЭКРАН АККАУНТА И ВЫХОДА ---
class AccountScreen extends StatelessWidget {
  final VoidCallback onLogout;
  const AccountScreen({super.key, required this.onLogout});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Аккаунт'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
              const SizedBox(height: 20),
              const Text('Имя пользователя: admin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Text('Роль: Администратор', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: onLogout,
                icon: const Icon(Icons.logout),
                label: const Text('Выйти из аккаунта'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}