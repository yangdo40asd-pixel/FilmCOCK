import 'dart:async';
import 'package:filmcock_app/data/cache/home_cache_storage.dart';
import 'package:filmcock_app/data/cache/search_cache.dart';
import 'package:filmcock_app/data/models/home_prefetch_data.dart';
import 'package:filmcock_app/data/models/movie_model.dart';
import 'package:filmcock_app/data/services/api_service.dart';
import 'package:filmcock_app/data/services/daily_recommendation_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeLoadSession {
  final Future<List<Movie>> popularMovies;
  final Future<List<Movie>> randomMovies;
  final Future<List<Movie>> upcomingMovies;
  final Future<List<Movie>> nowPlayingMovies;
  final Future<List<Movie>> animationMovies;
  final Future<List<Movie>> classicMovies;
  final Future<List<Person>> koreanActors;
  final Future<List<Person>> foreignActors;
  final Future<List<Person>> koreanDirectors;
  late final Future<HomePrefetchData> completed;

  HomeLoadSession({
    required this.popularMovies,
    required this.randomMovies,
    required this.upcomingMovies,
    required this.nowPlayingMovies,
    required this.animationMovies,
    required this.classicMovies,
    required this.koreanActors,
    required this.foreignActors,
    required this.koreanDirectors,
    bool Function()? hasExternalFailure,
  }) {
    completed =
        Future.wait<_HomeSectionResult<dynamic>>([
          HomePrefetchService._capture(popularMovies),
          HomePrefetchService._capture(upcomingMovies),
          HomePrefetchService._capture(nowPlayingMovies),
          HomePrefetchService._capture(animationMovies),
          HomePrefetchService._capture(classicMovies),
          HomePrefetchService._capture(koreanActors),
          HomePrefetchService._capture(foreignActors),
          HomePrefetchService._capture(koreanDirectors),
        ]).then((results) {
          final popular = results[0].data as List<Movie>;
          return HomePrefetchData(
            popularMovies: popular,
            randomMovies: DailyRecommendationService.orderMovies(popular),
            upcomingMovies: results[1].data as List<Movie>,
            nowPlayingMovies: results[2].data as List<Movie>,
            animationMovies: results[3].data as List<Movie>,
            classicMovies: results[4].data as List<Movie>,
            koreanActors: results[5].data as List<Person>,
            foreignActors: results[6].data as List<Person>,
            koreanDirectors: results[7].data as List<Person>,
            isComplete:
                results.every((result) => !result.failed) &&
                !(hasExternalFailure?.call() ?? false),
          );
        });
  }

  factory HomeLoadSession.fromData(HomePrefetchData data) {
    return HomeLoadSession(
      popularMovies: Future.value(data.popularMovies),
      randomMovies: Future.value(data.randomMovies),
      upcomingMovies: Future.value(data.upcomingMovies),
      nowPlayingMovies: Future.value(data.nowPlayingMovies),
      animationMovies: Future.value(data.animationMovies),
      classicMovies: Future.value(data.classicMovies),
      koreanActors: Future.value(data.koreanActors),
      foreignActors: Future.value(data.foreignActors),
      koreanDirectors: Future.value(data.koreanDirectors),
    );
  }
}

class HomePrefetchService {
  static const Duration _cacheTtl = Duration(minutes: 30);
  static HomePrefetchData? _cachedData;
  static HomePrefetchData? _offlineData;
  static DateTime? _cachedAt;
  static HomeLoadSession? _activeSession;
  static int _generation = 0;

  static Future<void> restore({SharedPreferences? preferences}) async {
    _offlineData = await HomeCacheStorage.load(preferences: preferences);
    final data = _offlineData;
    if (data != null) {
      SearchCache.addMovies([
        ...data.popularMovies,
        ...data.upcomingMovies,
        ...data.nowPlayingMovies,
        ...data.animationMovies,
        ...data.classicMovies,
      ]);
    }
  }

  static HomePrefetchData? get cachedData {
    final data = _cachedData;
    final cachedAt = _cachedAt;
    if (data == null || cachedAt == null) return null;
    if (DateTime.now().difference(cachedAt) >= _cacheTtl) {
      _cachedData = null;
      _cachedAt = null;
      _activeSession = null;
      return null;
    }
    return data;
  }

  static HomeLoadSession start({bool forceRefresh = false}) {
    if (forceRefresh) {
      _generation++;
      _cachedData = null;
      _cachedAt = null;
      _activeSession = null;
      SearchCache.clear();
    }

    final cached = cachedData;
    if (cached != null) return HomeLoadSession.fromData(cached);
    if (_activeSession != null) return _activeSession!;

    final fallback = _offlineData;
    final fallbackTracker = _FallbackTracker();
    final popular = _withFallback(
      fetchPopularMovies(),
      fallback?.popularMovies,
      fallbackTracker,
    );
    final koreanPeople = _defer(ApiService.getPopularPeopleFromKofic);
    final session = HomeLoadSession(
      popularMovies: popular,
      randomMovies: popular.then(
        (movies) => DailyRecommendationService.orderMovies(movies),
      ),
      upcomingMovies: _withFallback(
        _defer(fetchUpcomingMovies),
        fallback?.upcomingMovies,
        fallbackTracker,
      ),
      nowPlayingMovies: _withFallback(
        _defer(fetchNowPlayingMovies),
        fallback?.nowPlayingMovies,
        fallbackTracker,
      ),
      animationMovies: _withFallback(
        _defer(fetchAnimationMovies),
        fallback?.animationMovies,
        fallbackTracker,
      ),
      classicMovies: _withFallback(
        _defer(fetchClassicMovies),
        fallback?.classicMovies,
        fallbackTracker,
      ),
      koreanActors: _withFallback(
        koreanPeople.then((people) => people['actors'] ?? const <Person>[]),
        fallback?.koreanActors,
        fallbackTracker,
      ),
      foreignActors: _withFallback(
        _defer(fetchForeignActors),
        fallback?.foreignActors,
        fallbackTracker,
      ),
      koreanDirectors: _withFallback(
        koreanPeople.then((people) => people['directors'] ?? const <Person>[]),
        fallback?.koreanDirectors,
        fallbackTracker,
      ),
      hasExternalFailure: () => fallbackTracker.used,
    );
    _activeSession = session;
    final sessionGeneration = _generation;
    session.completed.then<void>((data) {
      if (sessionGeneration != _generation) return;
      if (data.isComplete) {
        _cachedData = data;
        _offlineData = data;
        _cachedAt = DateTime.now();
        unawaited(_saveOffline(data));
      } else {
        _activeSession = null;
      }
    });
    return session;
  }

  static Future<HomePrefetchData> load() => start().completed;

  static Future<HomePrefetchData> refresh() {
    return start(forceRefresh: true).completed;
  }

  static Future<void> _saveOffline(HomePrefetchData data) async {
    try {
      await HomeCacheStorage.save(data);
    } catch (_) {
      // 메모리 캐시는 유지하고 다음 정상 갱신 때 저장을 다시 시도한다.
    }
  }

  static Future<T> _defer<T>(Future<T> Function() request) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return request();
  }

  static Future<T> _withFallback<T>(
    Future<T> request,
    T? fallback,
    _FallbackTracker tracker,
  ) async {
    try {
      final data = await request;
      if (data is Iterable && data.isEmpty && _hasUsableFallback(fallback)) {
        tracker.used = true;
        return fallback as T;
      }
      return data;
    } catch (_) {
      if (!_hasUsableFallback(fallback)) rethrow;
      tracker.used = true;
      return fallback as T;
    }
  }

  static bool _hasUsableFallback(Object? fallback) {
    return fallback != null && (fallback is! Iterable || fallback.isNotEmpty);
  }

  static Future<List<Movie>> fetchPopularMovies() {
    return _rememberMovies(ApiService.getPopularMovies);
  }

  static Future<List<Movie>> fetchUpcomingMovies() {
    return _rememberMovies(ApiService.getUpcomingMovies);
  }

  static Future<List<Movie>> fetchNowPlayingMovies() {
    return _rememberMovies(ApiService.getNowPlayingMovies);
  }

  static Future<List<Movie>> fetchAnimationMovies() {
    return _rememberMovies(() => ApiService.getMoviesByGenre(16));
  }

  static Future<List<Movie>> fetchClassicMovies() {
    return _rememberMovies(ApiService.getClassicMovies);
  }

  static Future<List<Person>> fetchKoreanActors() async {
    final people = await ApiService.getPopularPeopleFromKofic();
    return people['actors'] ?? const <Person>[];
  }

  static Future<List<Person>> fetchForeignActors() {
    return ApiService.getPopularPeople();
  }

  static Future<List<Person>> fetchKoreanDirectors() async {
    final people = await ApiService.getPopularPeopleFromKofic();
    return people['directors'] ?? const <Person>[];
  }

  static Future<List<Movie>> _rememberMovies(
    Future<List<Movie>> Function() request,
  ) async {
    final movies = await request();
    if (movies.isNotEmpty) SearchCache.addMovies(movies);
    return movies;
  }

  static Future<_HomeSectionResult<T>> _capture<T>(Future<T> request) async {
    try {
      final data = await request;
      final isEmpty =
          data is Iterable && data.isEmpty || data is Map && data.isEmpty;
      return _HomeSectionResult(data, failed: isEmpty);
    } catch (_) {
      if (T == List<Movie>) {
        return _HomeSectionResult(<Movie>[] as T, failed: true);
      }
      if (T == List<Person>) {
        return _HomeSectionResult(<Person>[] as T, failed: true);
      }
      rethrow;
    }
  }
}

class _HomeSectionResult<T> {
  const _HomeSectionResult(this.data, {required this.failed});

  final T data;
  final bool failed;
}

class _FallbackTracker {
  bool used = false;
}
