import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';
import '../models/actor.dart';

class TMDbService {
  static const String _apiKey = '89fab07002541c57913253a7c5a0050c';
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  Future<List<Movie>> getPopularMovies() async {
    final response = await http.get(Uri.parse('$_baseUrl/movie/popular?api_key=$_apiKey'));
    print('getPopularMovies response status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['results'] as List).map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load popular movies: ${response.statusCode}');
    }
  }

  Future<List<Movie>> getTopRatedMovies() async {
    final response = await http.get(Uri.parse('$_baseUrl/movie/top_rated?api_key=$_apiKey'));
    print('getTopRatedMovies response status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['results'] as List).map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load top rated movies: ${response.statusCode}');
    }
  }

  Future<List<Movie>> getUpcomingMovies() async {
    final response = await http.get(Uri.parse('$_baseUrl/movie/upcoming?api_key=$_apiKey'));
    print('getUpcomingMovies response status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['results'] as List).map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load upcoming movies: ${response.statusCode}');
    }
  }

  Future<List<Movie>> searchMovies(String query) async {
    final response = await http.get(Uri.parse('$_baseUrl/search/movie?api_key=$_apiKey&query=${Uri.encodeQueryComponent(query)}'));
    print('searchMovies response status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['results'] as List).map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search movies: ${response.statusCode}');
    }
  }

  Future<Movie> getMovieDetails(int movieId) async {
    final response = await http.get(Uri.parse('$_baseUrl/movie/$movieId?api_key=$_apiKey'));
    print('getMovieDetails response status: ${response.statusCode}, movieId: $movieId');
    if (response.statusCode == 200) {
      return Movie.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load movie details: ${response.statusCode}');
    }
  }

  Future<List<Actor>> getMovieActors(int movieId) async {
    final response = await http.get(Uri.parse('$_baseUrl/movie/$movieId/credits?api_key=$_apiKey'));
    print('getMovieActors response status: ${response.statusCode}, movieId: $movieId');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['cast'] as List).map((json) => Actor.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load movie actors: ${response.statusCode}');
    }
  }
}