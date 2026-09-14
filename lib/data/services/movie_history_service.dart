import 'dart:convert';

import 'package:filmcock_app/data/models/movie_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:filmcock_app/data/storage/app_storage_keys.dart';

class MovieHistoryService {
  static Future<Set<int>> excludedMovieIds({
    SharedPreferences? preferences,
  }) async {
    final prefs = preferences ?? await SharedPreferences.getInstance();
    final ids = <int>{};

    for (final key in const [
      AppStorageKeys.likedMovies,
      AppStorageKeys.watchedMovies,
    ]) {
      final encodedItems = prefs.getStringList(key) ?? const <String>[];
      for (final encoded in encodedItems) {
        try {
          final item = jsonDecode(encoded) as Map<String, dynamic>;
          final id = int.tryParse(item['id'].toString());
          if (id != null) ids.add(id);
        } catch (_) {
          // 손상된 단일 기록은 제외하고 나머지 기록을 계속 사용한다.
        }
      }
    }
    return ids;
  }

  static Future<List<Movie>> excludeSavedMovies(
    Iterable<Movie> movies, {
    SharedPreferences? preferences,
  }) async {
    final excludedIds = await excludedMovieIds(preferences: preferences);
    return movies.where((movie) => !excludedIds.contains(movie.id)).toList();
  }
}
