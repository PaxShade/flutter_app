import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/movie.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const MovieDetailScreen({
    super.key,
    required this.movie,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late bool _isFav;

  @override
  void initState() {
    super.initState();
    _isFav = widget.isFavorite;
  }

  void _handleToggle() {
    setState(() => _isFav = !_isFav);
    widget.onFavoriteToggle();
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  movie.imageUrl.isNotEmpty
                      ? Image.network(
                    movie.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildGradientHeader(movie),
                  )
                      : _buildGradientHeader(movie),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.2),
                          Theme.of(context).scaffoldBackgroundColor,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                onPressed: _handleToggle,
                icon: CircleAvatar(
                  backgroundColor: Colors.black45,
                  child: Icon(
                    _isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: _isFav ? const Color(0xFFFF4081) : Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C4DFF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          movie.category,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 22),
                      const SizedBox(width: 4),
                      Text(
                        '${movie.rating} / 10',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    movie.title,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 16,
                    runSpacing: 6,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.public_rounded, size: 16, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(movie.country, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 16, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text('${movie.year} г.', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time_rounded, size: 16, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(movie.duration, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Сюжет',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    movie.description,
                    style: const TextStyle(fontSize: 15, height: 1.5),
                  ),
                  const SizedBox(height: 36),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => VkVideoPlayerScreen(
                              title: movie.title,
                              embedUrl: movie.videoUrl,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.play_arrow_rounded, size: 28),
                      label: const Text('Смотреть фильм', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C4DFF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientHeader(Movie movie) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: movie.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

// --- ПЛЕЕР ДЛЯ ВК ВИДЕО НА БАЗЕ WEBVIEW ---
class VkVideoPlayerScreen extends StatefulWidget {
  final String title;
  final String embedUrl;

  const VkVideoPlayerScreen({
    super.key,
    required this.title,
    required this.embedUrl,
  });

  @override
  State<VkVideoPlayerScreen> createState() => _VkVideoPlayerScreenState();
}

class _VkVideoPlayerScreenState extends State<VkVideoPlayerScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Подменяем User-Agent на актуальный Google Chrome (Android),
    // чтобы убрать метку "; wv" и обойти ошибку "Your browser is out of date"
    const String modernChromeUserAgent =
        'Mozilla/5.0 (Linux; Android 14; SM-A225F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Mobile Safari/537.36';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(modernChromeUserAgent)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
        ),
      )
    // Загружаем саму ссылку плеера напрямую с передачей правильного Referer
      ..loadRequest(
        Uri.parse(widget.embedUrl),
        headers: {
          'Referer': 'https://vk.ru/',
        },
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF7C4DFF)),
            ),
        ],
      ),
    );
  }
}
