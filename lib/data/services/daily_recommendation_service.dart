import 'package:filmcock_app/data/models/movie_model.dart';

class DailyRecommendationService {
  static List<Movie> orderMovies(Iterable<Movie> movies, {DateTime? now}) {
    final date = now ?? DateTime.now();
    final dateSeed = date.year * 10000 + date.month * 100 + date.day;
    final ordered = movies.toList();
    ordered.sort((a, b) {
      final aScore = _score(a.id, dateSeed);
      final bScore = _score(b.id, dateSeed);
      return aScore.compareTo(bScore);
    });
    return ordered;
  }

  static int _score(int movieId, int dateSeed) {
    return (movieId * 1103515245 + dateSeed * 12345) & 0x7fffffff;
  }
}
