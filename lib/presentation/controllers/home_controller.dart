import 'package:filmcock_app/data/models/movie_model.dart';
import 'package:filmcock_app/data/services/home_prefetch_service.dart';

class HomeController {
  late Future<List<Movie>> popularMovies;
  late Future<List<Movie>> randomMovies;
  late Future<List<Movie>> upcomingMovies;
  late Future<List<Movie>> nowPlayingMovies;
  late Future<List<Movie>> animationMovies;
  late Future<List<Movie>> topRatedMovies;
  late Future<List<Person>> popularForeignActors;
  Future<List<Person>>? popularKoreanActors;
  Future<List<Person>>? popularKoreanDirectors;

  String userMbti = '추천영화';
  String _activeDateKey = _dateKey(DateTime.now());
  int loadId = 0;

  HomeController() {
    bind(HomePrefetchService.start());
  }

  void bind(HomeLoadSession session) {
    loadId++;
    popularMovies = session.popularMovies;
    randomMovies = session.randomMovies;
    upcomingMovies = session.upcomingMovies;
    nowPlayingMovies = session.nowPlayingMovies;
    animationMovies = session.animationMovies;
    topRatedMovies = session.classicMovies;
    popularForeignActors = session.foreignActors;
    popularKoreanActors = session.koreanActors;
    popularKoreanDirectors = session.koreanDirectors;
  }

  HomeLoadSession refresh() {
    final session = HomePrefetchService.start(forceRefresh: true);
    bind(session);
    return session;
  }

  int nextLoad() => ++loadId;

  bool moveToTodayIfNeeded() {
    final today = _dateKey(DateTime.now());
    if (today == _activeDateKey) return false;
    _activeDateKey = today;
    return true;
  }

  static String _dateKey(DateTime date) {
    return date.toIso8601String().substring(0, 10);
  }
}
