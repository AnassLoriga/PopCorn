import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/tmdb_service.dart';
import '../services/database_service.dart';
import '../models/movie.dart';
import '../models/actor.dart';

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
      print('Loading details for movieId: ${widget.movieId}');
      final movie = await _tmdbService.getMovieDetails(widget.movieId);
      final actors = await _tmdbService.getMovieActors(widget.movieId);
      final isFavorite = await _dbService.isFavorite(widget.movieId);
      setState(() {
        _movie = movie;
        _actors = actors;
        _isFavorite = isFavorite;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading movie details: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load movie details: $e')),
      );
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update favorite: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_movie?.title ?? 'Movie Details'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _movie == null
          ? const Center(
        child: Text(
          'Unable to load movie details. Please try again later.',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      )
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_movie!.backdropPath.isNotEmpty)
              CachedNetworkImage(
                imageUrl:
                'https://image.tmdb.org/t/p/w500${_movie!.backdropPath}',
                fit: BoxFit.cover,
                errorWidget: (context, url, error) =>
                const Icon(Icons.error, color: Colors.white),
                placeholder: (context, url) =>
                const CircularProgressIndicator(),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _movie!.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rating: ${_movie!.voteAverage.toStringAsFixed(1)}/10',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _movie!.overview,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Cast',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _actors.length,
                      itemBuilder: (context, index) {
                        final actor = _actors[index];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundImage: actor.profilePath.isNotEmpty
                                    ? CachedNetworkImageProvider(
                                  'https://image.tmdb.org/t/p/w200${actor.profilePath}',
                                )
                                    : null,
                                child: actor.profilePath.isEmpty
                                    ? const Icon(Icons.person, color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(height: 4),
                              SizedBox(
                                width: 80,
                                child: Text(
                                  actor.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}