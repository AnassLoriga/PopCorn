import 'package:flutter/material.dart';
import '../services/tmdb_service.dart';
import '../models/movie.dart';
import 'movie_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final TMDbService _tmdbService = TMDbService();
  List<Movie> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSearchChanged);
  }

  void _onSearchChanged() async {
    final query = _controller.text;
    if (query.isNotEmpty) {
      final results = await _tmdbService.searchMovies(query);
      setState(() {
        _searchResults = results;
      });
    } else {
      setState(() {
        _searchResults = [];
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          decoration: const InputDecoration(
            hintText: 'Search movies...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          style: const TextStyle(color: Colors.white),
          autofocus: true,
        ),
        backgroundColor: Colors.black,
      ),
      body: _searchResults.isEmpty && _controller.text.isNotEmpty
          ? const Center(child: Text('No results found', style: TextStyle(color: Colors.white)))
          : ListView.builder(
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final movie = _searchResults[index];
          return ListTile(
            leading: movie.posterPath.isNotEmpty
                ? Image.network(
              'https://image.tmdb.org/t/p/w92${movie.posterPath}',
              width: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, color: Colors.white),
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