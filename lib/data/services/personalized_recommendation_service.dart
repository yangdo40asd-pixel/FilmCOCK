import 'package:filmcock_app/data/models/genre_catalog.dart';
import 'package:filmcock_app/data/models/mbti_info.dart';
import 'package:filmcock_app/data/models/movie_model.dart';
import 'package:filmcock_app/data/services/api_service.dart';
import 'package:filmcock_app/data/services/movie_history_service.dart';

class PersonalizedRecommendation {
  final List<Movie> movies;
  final String? mbti;
  final String? genreName;

  const PersonalizedRecommendation({
    required this.movies,
    this.mbti,
    this.genreName,
  });

  bool get isPersonalized => genreName != null && genreName!.isNotEmpty;
}

class PersonalizedRecommendationService {
  PersonalizedRecommendationService._();

  static List<String> genreKeysFor({
    required String? mbti,
    required List<String> genres,
  }) {
    final info = mbti == null ? null : getMbtiInfoById(mbti);
    return <String>{
      ...genres.where((key) => GenreCatalog.tmdbIdFor(key) != null),
      ...?info?.genreIds.where((key) => GenreCatalog.tmdbIdFor(key) != null),
    }.take(3).toList();
  }

  static String? genreNameFor({
    required String? mbti,
    required List<String> genres,
  }) {
    final names = genreKeysFor(
      mbti: mbti,
      genres: genres,
    ).map(GenreCatalog.labelFor).whereType<String>().join('/');
    return names.isEmpty ? null : names;
  }

  static Future<PersonalizedRecommendation> load({
    required String? mbti,
    required List<String> genres,
    required List<Movie> fallback,
  }) async {
    final genreKeys = genreKeysFor(mbti: mbti, genres: genres);
    final genreIds = genreKeys.map(GenreCatalog.tmdbIdFor).whereType<int>();
    final genreName = genreNameFor(mbti: mbti, genres: genres);

    if (genreKeys.isEmpty) {
      return PersonalizedRecommendation(
        movies: await MovieHistoryService.excludeSavedMovies(fallback),
      );
    }

    try {
      final fetchedByGenre = await Future.wait(
        genreIds.map((genreId) async {
          try {
            return await ApiService.getMoviesByGenre(genreId);
          } catch (_) {
            return const <Movie>[];
          }
        }),
      );
      final seenIds = <int>{};
      final fetched = <Movie>[];
      for (final movies in fetchedByGenre) {
        for (final movie in movies) {
          if (seenIds.add(movie.id)) fetched.add(movie);
        }
      }
      final candidates = fetched.isEmpty ? fallback : fetched;
      return PersonalizedRecommendation(
        movies: await MovieHistoryService.excludeSavedMovies(candidates),
        mbti: mbti,
        genreName: genreName,
      );
    } catch (_) {
      return PersonalizedRecommendation(
        movies: await MovieHistoryService.excludeSavedMovies(fallback),
        mbti: mbti,
        genreName: genreName,
      );
    }
  }
}
