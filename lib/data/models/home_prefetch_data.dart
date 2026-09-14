import 'package:filmcock_app/data/models/movie_model.dart';

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
  final bool isComplete;

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
    this.isComplete = true,
  });
}
