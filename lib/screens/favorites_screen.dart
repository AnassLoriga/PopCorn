import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/movie.dart';
import 'movie_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final DatabaseService _dbService = DatabaseService();
  List<Movie> _favorites = [];
  final bool _isDatabaseSupported = !kIsWeb;

  @override
  void initState() {
    super.initState();
    if (_isDatabaseSupported) {
      _loadFavorites();
    }
  }

  Future<void> _loadFavorites() async {
    final favorites = await _dbService.getFavorites();
    setState(() {
      _favorites = favorites;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor: Colors.black,
      ),
      body: !_isDatabaseSupported
          ? const Center(
        child: Text(
          'Favorites not supported on this platform',
          style: TextStyle(color: Colors.white),
        ),
      )
          : _favorites.isEmpty
          ? const Center(
        child: Text(
          'No favorites yet',
          style: TextStyle(color: Colors.white),
        ),
      )
          : ListView.builder(
        itemCount: _favorites.length,
        itemBuilder: (context, index) {
          final movie = _favorites[index];
          return ListTile(
            leading: movie.posterPath.isNotEmpty
                ? Image.network(
              'https://image.tmdb.org/t/p/w92${movie.posterPath}',
              width: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.error, color: Colors.white),
            )
                : const Icon(Icons.movie, color: Colors.white),
            title: Text(movie.title, style: const TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MovieDetailScreen(movieId: movie.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}