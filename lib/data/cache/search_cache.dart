import 'package:filmcock_app/data/models/movie_model.dart';

class SearchCache {
  const SearchCache._();

  static List<Movie> _movies = const [];

  static List<Movie> get movies => _movies;

  static void replaceMovies(Iterable<Movie> movies) {
    final unique = <int, Movie>{};
    for (final movie in movies) {
      unique[movie.id] = movie;
    }
    _movies = List.unmodifiable(unique.values);
  }

  static void addMovies(Iterable<Movie> movies) {
    replaceMovies([..._movies, ...movies]);
  }

  static void clear() {
    _movies = const [];
  }
}
