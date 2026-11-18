import 'package:filmcock_app/shared/domain/models/catalog_models.dart';
import 'package:filmcock_app/core/time/app_clock.dart';
import 'package:filmcock_app/features/home/data/home_prefetch_service.dart';

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

  final AppClock clock;
  String userMbti = '추천영화';
  late String _activeDateKey;
  int loadId = 0;

  HomeController({this.clock = const SystemClock()}) {
    _activeDateKey = _dateKey(clock.now());
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
    final today = _dateKey(clock.now());
    if (today == _activeDateKey) return false;
    _activeDateKey = today;
    return true;
  }

  static String _dateKey(DateTime date) {
    return date.toIso8601String().substring(0, 10);
  }
}
