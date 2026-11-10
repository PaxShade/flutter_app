import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../widgets/movie_card.dart';
import 'movie_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  final List<String> favoriteIds;
  final Function(String) onToggleFavorite;

  const HomeScreen({super.key, required this.favoriteIds, required this.onToggleFavorite});

  @override
  Widget build(BuildContext context) {
    final topMovies = List<Movie>.from(dummyMovies)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    final featuredMovie = topMovies.first;
    final recommendations = topMovies.skip(1).take(5).toList();
    final isFeaturedFav = favoriteIds.contains(featuredMovie.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Главная', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- ЯРКИЙ БАННЕР "ЛИДЕР РЕЙТИНГА" ---
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MovieDetailScreen(
                    movie: featuredMovie,
                    isFavorite: isFeaturedFav,
                    onFavoriteToggle: () => onToggleFavorite(featuredMovie.id),
                  ),
                ),
              );
            },
            child: Container(
              height: 230,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: LinearGradient(
                  colors: featuredMovie.gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  // Яркое цветное свечение вокруг постера
                  BoxShadow(
                    color: featuredMovie.gradientColors.first.withValues(alpha: 0.55),
                    blurRadius: 24,
                    spreadRadius: 2,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: featuredMovie.gradientColors.last.withValues(alpha: 0.4),
                    blurRadius: 18,
                    offset: const Offset(4, 6),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35),
                  width: 1.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Фоновая картинка фильма
                    if (featuredMovie.imageUrl.isNotEmpty)
                      Image.network(
                        featuredMovie.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    // Яркий полупрозрачный цветовой оверлей для сочности и контраста текста
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                            featuredMovie.gradientColors.last.withValues(alpha: 0.45),
                            featuredMovie.gradientColors.first.withValues(alpha: 0.85),
                            const Color(0xFF0F0F1A).withValues(alpha: 0.92),
                          ],
                          stops: const [0.0, 0.55, 1.0],
                        ),
                      ),
                    ),
                    // Контент внутри постера
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Светящийся бейдж лидера
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFFF8F00), Color(0xFFFFD54F)],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.amber.withValues(alpha: 0.5),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  '🔥 ЛИДЕР РЕЙТИНГА',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black87,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              // Кнопка лайка прямо на баннере
                              GestureDetector(
                                onTap: () => onToggleFavorite(featuredMovie.id),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isFeaturedFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                    color: isFeaturedFav ? const Color(0xFFFF4081) : Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            featuredMovie.title,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              shadows: [
                                Shadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 2)),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  featuredMovie.category,
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${featuredMovie.year} • ${featuredMovie.duration} • ',
                                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                              const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                              Text(
                                ' ${featuredMovie.rating}',
                                style: const TextStyle(color: Colors.amber, fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            featuredMovie.description,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12.5),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 26),
          const Text(
            'Рекомендуем посмотреть',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          ...recommendations.map((movie) => MovieCard(
            movie: movie,
            isFavorite: favoriteIds.contains(movie.id),
            onFavoriteToggle: () => onToggleFavorite(movie.id),
          )),
        ],
      ),
    );
  }
}
