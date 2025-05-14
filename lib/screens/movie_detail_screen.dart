import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/tmdb_service.dart';
import '../services/database_service.dart';
import '../models/movie.dart';
import '../models/actor.dart';

// Import AppTheme
class AppTheme {
  // Define our theme colors
  static const Color primaryYellow = Color(0xFFFFD700);
  static const Color accentYellow = Color(0xFFFFC107);
  static const Color darkBackground = Color(0xFF121212);
  static const Color surfaceColor = Color(0xFF1E1E1E);

  // App theme data
  static ThemeData get themeData => ThemeData(
    scaffoldBackgroundColor: darkBackground,
    primaryColor: primaryYellow,
    colorScheme: const ColorScheme.dark().copyWith(
      primary: primaryYellow,
      secondary: accentYellow,
      surface: surfaceColor,
      background: darkBackground,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackground,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: primaryYellow,
        fontWeight: FontWeight.bold,
        fontSize: 20,
        letterSpacing: 1.2,
      ),
      iconTheme: IconThemeData(color: primaryYellow),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surfaceColor,
      selectedItemColor: primaryYellow,
      unselectedItemColor: Colors.grey,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white),
      bodyLarge: TextStyle(color: Colors.white),
    ),
  );
}

class MovieDetailScreen extends StatefulWidget {
  final int movieId;

  const MovieDetailScreen({super.key, required this.movieId});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final TMDbService _tmdbService = TMDbService();
  final DatabaseService _dbService = DatabaseService();
  Movie? _movie;
  List<Actor> _actors = [];
  bool _isFavorite = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMovieDetails();
  }

  Future<void> _loadMovieDetails() async {
    try {
      final movie = await _tmdbService.getMovieDetails(widget.movieId);
      final actors = await _tmdbService.getMovieActors(widget.movieId);
      final isFavorite = await _dbService.isFavorite(widget.movieId);

      if (mounted) {
        setState(() {
          _movie = movie;
          _actors = actors;
          _isFavorite = isFavorite;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load movie details'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (_movie == null) return;
    try {
      if (_isFavorite) {
        await _dbService.removeFavorite(widget.movieId);
      } else {
        await _dbService.addFavorite(_movie!);
      }
      setState(() {
        _isFavorite = !_isFavorite;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite ? 'Added to favorites' : 'Removed from favorites',
          ),
          backgroundColor: AppTheme.surfaceColor,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'OK',
            textColor: AppTheme.primaryYellow,
            onPressed: () {},
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update favorite'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.darkBackground.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: AppTheme.primaryYellow),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: AppTheme.darkBackground.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : AppTheme.primaryYellow,
              ),
              onPressed: _toggleFavorite,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryYellow),
        ),
      )
          : _movie == null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.movie,
              color: AppTheme.primaryYellow,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to load movie details',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryYellow,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                setState(() => _isLoading = true);
                _loadMovieDetails();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                if (_movie!.backdropPath.isNotEmpty)
                  ShaderMask(
                    shaderCallback: (rect) {
                      return LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.1),
                          Colors.black.withOpacity(0.9),
                        ],
                      ).createShader(rect);
                    },
                    blendMode: BlendMode.darken,
                    child: CachedNetworkImage(
                      height: 300,
                      width: double.infinity,
                      imageUrl: 'https://image.tmdb.org/t/p/w780${_movie!.backdropPath}',
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Container(
                        height: 300,
                        color: AppTheme.surfaceColor,
                        child: const Icon(Icons.broken_image, color: Colors.grey, size: 50),
                      ),
                      placeholder: (context, url) => Container(
                        height: 300,
                        color: AppTheme.surfaceColor,
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryYellow),
                          ),
                        ),
                      ),
                    ),
                  ),
                // Movie info overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _movie!.title,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 10.0,
                                color: Colors.black,
                                offset: Offset(2.0, 2.0),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryYellow,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star, color: Colors.black, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    _movie!.voteAverage.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Movie details section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overview
                  const Text(
                    'Overview',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryYellow,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _movie!.overview,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Cast section
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Cast',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryYellow,
                        ),
                      ),
                      Text(
                        'See all',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.accentYellow,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Cast horizontal list
            SizedBox(
              height: 150,
              child: _actors.isEmpty
                  ? const Center(
                child: Text(
                  'No cast information available',
                  style: TextStyle(color: Colors.grey),
                ),
              )
                  : ListView.builder(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _actors.length,
                itemBuilder: (context, index) {
                  final actor = _actors[index];
                  return Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 12),
                    child: Column(
                      children: [
                        // Actor profile image
                        Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.surfaceColor, width: 2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: actor.profilePath.isNotEmpty
                                ? CachedNetworkImage(
                              imageUrl: 'https://image.tmdb.org/t/p/w200${actor.profilePath}',
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: AppTheme.surfaceColor,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentYellow),
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: AppTheme.surfaceColor,
                                child: const Icon(Icons.person, color: Colors.grey),
                              ),
                            )
                                : Container(
                              color: AppTheme.surfaceColor,
                              child: const Icon(Icons.person, color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Actor name
                        Text(
                          actor.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Add other info based on available movie data
                    const Text(
                      'Additional Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryYellow,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Any other info we can display
                    Row(
                      children: [
                        const Icon(Icons.thumb_up_outlined,
                            color: Colors.grey, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'User Rating: ${_movie!.voteAverage}/10',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}