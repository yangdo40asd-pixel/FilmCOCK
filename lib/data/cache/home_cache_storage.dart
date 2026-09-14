import 'dart:convert';

import 'package:filmcock_app/data/models/home_prefetch_data.dart';
import 'package:filmcock_app/data/models/movie_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:filmcock_app/data/storage/app_storage_keys.dart';

class HomeCacheStorage {
  static const String _cacheKey = AppStorageKeys.homeLastGood;

  static Future<void> save(
    HomePrefetchData data, {
    SharedPreferences? preferences,
  }) async {
    final prefs = preferences ?? await SharedPreferences.getInstance();
    final payload = {
      'saved_at': DateTime.now().toIso8601String(),
      'popular_movies': _moviesToJson(data.popularMovies),
      'random_movies': _moviesToJson(data.randomMovies),
      'upcoming_movies': _moviesToJson(data.upcomingMovies),
      'now_playing_movies': _moviesToJson(data.nowPlayingMovies),
      'animation_movies': _moviesToJson(data.animationMovies),
      'classic_movies': _moviesToJson(data.classicMovies),
      'korean_actors': _peopleToJson(data.koreanActors),
      'foreign_actors': _peopleToJson(data.foreignActors),
      'korean_directors': _peopleToJson(data.koreanDirectors),
    };
    await prefs.setString(_cacheKey, jsonEncode(payload));
  }

  static Future<HomePrefetchData?> load({
    SharedPreferences? preferences,
  }) async {
    final prefs = preferences ?? await SharedPreferences.getInstance();
    final encoded = prefs.getString(_cacheKey);
    if (encoded == null || encoded.isEmpty) return null;

    try {
      final payload = jsonDecode(encoded) as Map<String, dynamic>;
      return HomePrefetchData(
        popularMovies: _moviesFromJson(payload['popular_movies']),
        randomMovies: _moviesFromJson(payload['random_movies']),
        upcomingMovies: _moviesFromJson(payload['upcoming_movies']),
        nowPlayingMovies: _moviesFromJson(payload['now_playing_movies']),
        animationMovies: _moviesFromJson(payload['animation_movies']),
        classicMovies: _moviesFromJson(payload['classic_movies']),
        koreanActors: _peopleFromJson(payload['korean_actors']),
        foreignActors: _peopleFromJson(payload['foreign_actors']),
        koreanDirectors: _peopleFromJson(payload['korean_directors']),
      );
    } catch (_) {
      await prefs.remove(_cacheKey);
      return null;
    }
  }

  static List<Map<String, dynamic>> _moviesToJson(List<Movie> movies) {
    return movies.map((movie) => movie.toJson()).toList();
  }

  static List<Map<String, dynamic>> _peopleToJson(List<Person> people) {
    return people.map((person) => person.toJson()).toList();
  }

  static List<Movie> _moviesFromJson(dynamic source) {
    if (source is! List) return const [];
    return source
        .whereType<Map>()
        .map((item) => Movie.fromJson(Map<String, dynamic>.from(item)))
        .where((movie) => movie.id != 0)
        .toList();
  }

  static List<Person> _peopleFromJson(dynamic source) {
    if (source is! List) return const [];
    return source
        .whereType<Map>()
        .map((item) => Person.fromJson(Map<String, dynamic>.from(item)))
        .where((person) => person.id != 0)
        .toList();
  }
}
