import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../widgets/movie_card.dart';

class FavoritesScreen extends StatefulWidget {
  final List<String> favoriteIds;
  final Function(String) onToggleFavorite;

  const FavoritesScreen({super.key, required this.favoriteIds, required this.onToggleFavorite});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'Все';
  String _selectedSort = 'По названию';
  final _searchController = TextEditingController();
  final List<String> _categories = allCategories;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final boxColor = isDark ? const Color(0xFF1E1E2C) : Colors.grey.shade200;

    // Берем только избранные фильмы + применяем поиск и категорию
    List<Movie> favMovies = dummyMovies.where((m) {
      final isFav = widget.favoriteIds.contains(m.id);
      final matchesCategory = _selectedCategory == 'Все' || m.category == _selectedCategory;
      final matchesSearch = m.title.toLowerCase().contains(_searchQuery.toLowerCase());
      return isFav && matchesCategory && matchesSearch;
    }).toList();

    // Сортировка
    if (_selectedSort == 'По названию') {
      favMovies.sort((a, b) => a.title.compareTo(b.title));
    } else if (_selectedSort == 'По рейтингу') {
      favMovies.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (_selectedSort == 'По году') {
      favMovies.sort((a, b) => b.year.compareTo(a.year));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Избранное', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: widget.favoriteIds.isEmpty
          ? const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border_rounded, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Список избранного пуст', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          ],
        ),
      )
          : Column(
        children: [
          // Поиск в избранном
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Поиск в избранном...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
                    : null,
                filled: true,
                fillColor: boxColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // Чипы категорий
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: const Color(0xFFFF4081),
                    backgroundColor: boxColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    side: BorderSide.none,
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                  ),
                );
              },
            ),
          ),
          // Сортировка
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Фильмов: ${favMovies.length}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: boxColor, borderRadius: BorderRadius.circular(12)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedSort,
                      icon: const Icon(Icons.sort_rounded, size: 18, color: Color(0xFFFF4081)),
                      style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black87),
                      onChanged: (value) => setState(() => _selectedSort = value!),
                      items: ['По названию', 'По рейтингу', 'По году']
                          .map((sort) => DropdownMenuItem(value: sort, child: Text(sort)))
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: favMovies.isEmpty
                ? const Center(child: Text('Нет фильмов по выбранным фильтрам', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount: favMovies.length,
              itemBuilder: (context, index) {
                final movie = favMovies[index];
                return MovieCard(
                  movie: movie,
                  isFavorite: true,
                  onFavoriteToggle: () => widget.onToggleFavorite(movie.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
