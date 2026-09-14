import 'dart:convert';

import 'package:filmcock_app/core/config/secrets.dart';
import 'package:filmcock_app/core/errors/app_exception.dart';
import 'package:filmcock_app/core/utils/language_filter.dart';
import 'package:filmcock_app/data/models/movie_model.dart';
import 'package:filmcock_app/data/services/api_client.dart';

class TmdbMovieService {
  const TmdbMovieService._();

  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static String get _apiKey => ApiSecrets.tmdbApiKey;

  static Future<List<Movie>> getMovies(
    String endpoint, {
    bool isUpcoming = false,
  }) async {
    final data = await _getJson(
      Uri.parse(
        '$_baseUrl/movie/$endpoint?api_key=$_apiKey&language=ko-KR&page=1',
      ),
      'Load movies from $endpoint',
    );
    final movies = _movieList(data['results']);
    return LanguageFilter.filterMovies(movies, isUpcoming: isUpcoming);
  }

  static Future<List<Person>> getMovieCredits(int movieId) async {
    final data = await _getJson(
      Uri.parse(
        '$_baseUrl/movie/$movieId/credits?api_key=$_apiKey&language=ko-KR',
      ),
      'Load movie credits for $movieId',
    );
    return (data['cast'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(Person.fromJson)
        .toList();
  }

  static Future<Movie> getMovieDetail(int movieId) async {
    final data = await _getJson(
      Uri.parse('$_baseUrl/movie/$movieId?api_key=$_apiKey&language=ko-KR'),
      'Load movie detail for $movieId',
    );
    return Movie.fromJson(data);
  }

  static Future<List<Movie>> getUpcomingMovies() async {
    final data = await _getJson(
      Uri.parse(
        '$_baseUrl/movie/upcoming?api_key=$_apiKey&language=ko-KR&page=1&region=KR',
      ),
      'Load upcoming movies',
    );
    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final movies =
        _movieList(data['results'])
            .where(
              (movie) =>
                  movie.releaseDate.isNotEmpty &&
                  movie.releaseDate.compareTo(today) > 0,
            )
            .toList()
          ..sort((a, b) => a.releaseDate.compareTo(b.releaseDate));
    return LanguageFilter.filterMovies(movies, isUpcoming: true);
  }

  static Future<List<Movie>> getTopRatedMovies() => getMovies('top_rated');

  static Future<List<Movie>> getRecommendedMovies(int movieId) {
    return getMovies('$movieId/recommendations');
  }

  static Future<List<Video>> getMovieVideos(int movieId) async {
    final response = await ApiClient.get(
      Uri.parse(
        '$_baseUrl/movie/$movieId/videos?api_key=$_apiKey&language=ko-KR',
      ),
    );
    if (response.statusCode != 200) return const <Video>[];
    final data = _decode(response.bodyBytes);
    return (data['results'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(Video.fromJson)
        .where(
          (video) =>
              video.site == 'YouTube' &&
              (video.type == 'Trailer' || video.type == 'Teaser'),
        )
        .toList();
  }

  static Future<List<WatchProvider>> getMovieWatchProviders(int movieId) async {
    final data = await _getJson(
      Uri.parse('$_baseUrl/movie/$movieId/watch/providers?api_key=$_apiKey'),
      'Load watch providers for $movieId',
    );
    final results = data['results'] as Map<String, dynamic>?;
    final korea = results?['KR'] as Map<String, dynamic>?;
    if (korea == null) return const <WatchProvider>[];

    final providers = <WatchProvider>[];
    const offerTypes = <String, String>{
      'flatrate': '구독',
      'free': '무료',
      'ads': '광고 포함',
      'rent': '대여',
      'buy': '구매',
    };
    for (final offer in offerTypes.entries) {
      final values = korea[offer.key] as List<dynamic>? ?? const [];
      providers.addAll(
        values.whereType<Map<String, dynamic>>().map(
          (value) => WatchProvider.fromJson(
            value,
            offerType: offer.value,
            link: korea['link'] as String? ?? '',
          ),
        ),
      );
    }
    return providers;
  }

  static Future<List<Movie>> getMoviesByGenre(
    int genreId, {
    int page = 1,
  }) async {
    final data = await _getJson(
      Uri.parse(
        '$_baseUrl/discover/movie?api_key=$_apiKey&language=ko-KR&with_genres=$genreId&page=$page&sort_by=popularity.desc',
      ),
      'Load movies for genre $genreId',
    );
    return LanguageFilter.filterMovies(_movieList(data['results']));
  }

  static Future<List<Movie>> getClassicMovies() async {
    final data = await _getJson(
      Uri.parse(
        '$_baseUrl/discover/movie?api_key=$_apiKey&language=ko-KR&primary_release_date.gte=2000-01-01&primary_release_date.lte=2010-12-31&sort_by=vote_average.desc&vote_count.gte=500&page=1',
      ),
      'Load classic movies',
    );
    return LanguageFilter.filterMovies(_movieList(data['results']));
  }

  static List<Movie> _movieList(dynamic raw) {
    return (raw as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(Movie.fromJson)
        .toList();
  }

  static Future<Map<String, dynamic>> _getJson(
    Uri url,
    String operation,
  ) async {
    final response = await ApiClient.get(url);
    if (response.statusCode != 200) {
      throw ApiResponseException(
        statusCode: response.statusCode,
        operation: operation,
      );
    }
    return _decode(response.bodyBytes);
  }

  static Map<String, dynamic> _decode(List<int> bytes) {
    return jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
  }
}
