import 'dart:math';

import 'package:filmcock_app/data/models/movie_model.dart';
import 'package:filmcock_app/data/services/api_service.dart';

class HomePrefetchData {
  final List<Movie> popularMovies;
  final List<Movie> randomMovies;
  final List<Movie> upcomingMovies;
  final List<Movie> nowPlayingMovies;
  final List<Movie> animationMovies;
  final List<Movie> classicMovies;
  final List<Person> koreanActors;
  final List<Person> foreignActors;
  final List<Person> koreanDirectors;

  const HomePrefetchData({
    required this.popularMovies,
    required this.randomMovies,
    required this.upcomingMovies,
    required this.nowPlayingMovies,
    required this.animationMovies,
    required this.classicMovies,
    required this.koreanActors,
    required this.foreignActors,
    required this.koreanDirectors,
  });
}

class HomePrefetchService {
  static Future<HomePrefetchData>? _cachedLoad;
  static HomePrefetchData? _cachedData;

  static HomePrefetchData? get cachedData => _cachedData;

  static Future<HomePrefetchData> load() {
    return _cachedLoad ??= _loadAll().then((data) {
      _cachedData = data;
      return data;
    });
  }

  static Future<HomePrefetchData> _loadAll() async {
    final results = await Future.wait<dynamic>([
      _safe(ApiService.getPopularMovies),
      _safe(ApiService.getUpcomingMovies),
      _safe(ApiService.getNowPlayingMovies),
      _safe(() => ApiService.getMoviesByGenre(16)),
      _safe(ApiService.getClassicMovies),
      _safe(ApiService.getPopularPeopleFromKofic),
      _safe(ApiService.getPopularPeople),
    ]);

    final popularMovies = results[0] as List<Movie>;
    final randomMovies = [...popularMovies]..shuffle(Random());
    final people = results[5] as Map<String, List<Person>>;

    return HomePrefetchData(
      popularMovies: popularMovies,
      randomMovies: randomMovies,
      upcomingMovies: results[1] as List<Movie>,
      nowPlayingMovies: results[2] as List<Movie>,
      animationMovies: results[3] as List<Movie>,
      classicMovies: results[4] as List<Movie>,
      koreanActors: people['actors'] ?? const [],
      foreignActors: results[6] as List<Person>,
      koreanDirectors: people['directors'] ?? const [],
    );
  }

  static Future<T> _safe<T>(Future<T> Function() request) async {
    try {
      return await request();
    } catch (_) {
      if (T == List<Movie>) return <Movie>[] as T;
      if (T == List<Person>) return <Person>[] as T;
      if (T == Map<String, List<Person>>) {
        return <String, List<Person>>{} as T;
      }
      rethrow;
    }
  }
}
