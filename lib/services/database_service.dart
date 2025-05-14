import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../models/movie.dart';

class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'movies.db';
  static const String _tableName = 'favorites';

  Future<Database?> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database;
  }

  Future<Database?> _initDatabase() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = join(directory.path, _databaseName);
      print('Database path: $path');
      return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE $_tableName (
              id INTEGER PRIMARY KEY,
              title TEXT,
              poster_path TEXT,
              backdrop_path TEXT,
              overview TEXT,
              vote_average REAL
            )
          ''');
        },
      );
    } catch (e) {
      print('Failed to initialize database: $e');
      return null; // Return null instead of throwing
    }
  }

  Future<bool> addFavorite(Movie movie) async {
    try {
      final db = await database;
      if (db == null) return false;
      await db.insert(
        _tableName,
        {
          'id': movie.id,
          'title': movie.title,
          'poster_path': movie.posterPath,
          'backdrop_path': movie.backdropPath,
          'overview': movie.overview,
          'vote_average': movie.voteAverage,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return true;
    } catch (e) {
      print('Failed to add favorite: $e');
      return false;
    }
  }

  Future<bool> removeFavorite(int movieId) async {
    try {
      final db = await database;
      if (db == null) return false;
      await db.delete(_tableName, where: 'id = ?', whereArgs: [movieId]);
      return true;
    } catch (e) {
      print('Failed to remove favorite: $e');
      return false;
    }
  }

  Future<bool> isFavorite(int movieId) async {
    try {
      final db = await database;
      if (db == null) return false;
      final result = await db.query(_tableName, where: 'id = ?', whereArgs: [movieId]);
      return result.isNotEmpty;
    } catch (e) {
      print('Failed to check favorite: $e');
      return false;
    }
  }

  Future<List<Movie>> getFavorites() async {
    try {
      final db = await database;
      if (db == null) return [];
      final result = await db.query(_tableName);
      return result.map((map) => Movie(
        id: map['id'] as int,
        title: map['title'] as String,
        posterPath: map['poster_path'] as String? ?? '',
        backdropPath: map['backdrop_path'] as String? ?? '',
        overview: map['overview'] as String? ?? '',
        voteAverage: map['vote_average'] as double,
      )).toList();
    } catch (e) {
      print('Failed to get favorites: $e');
      return [];
    }
  }
}