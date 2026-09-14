import 'package:filmcock_app/data/models/movie_model.dart';
import 'package:filmcock_app/data/models/search_suggestion.dart';
import 'package:filmcock_app/data/services/kofic_service.dart';
import 'package:filmcock_app/data/services/search_service.dart';
import 'package:filmcock_app/data/services/tmdb_movie_service.dart';
import 'package:filmcock_app/data/services/tmdb_person_service.dart';

/// 기존 화면의 호출 방식을 유지하는 호환 계층입니다.
/// 실제 통신과 응답 해석은 API별 전용 서비스가 담당합니다.
class ApiService {
  const ApiService._();

  static Future<List<Movie>> getMovies(
    String endpoint, {
    bool isUpcoming = false,
  }) => TmdbMovieService.getMovies(endpoint, isUpcoming: isUpcoming);

  static Future<List<Person>> getMovieCredits(int movieId) =>
      TmdbMovieService.getMovieCredits(movieId);

  static Future<Movie> getMovieDetail(int movieId) =>
      TmdbMovieService.getMovieDetail(movieId);

  static Future<List<Movie>> getUpcomingMovies() =>
      TmdbMovieService.getUpcomingMovies();

  static Future<List<Movie>> getTopRatedMovies() =>
      TmdbMovieService.getTopRatedMovies();

  static Future<List<Movie>> getNowPlayingMovies() =>
      KoficService.getNowPlayingMovies();

  static Future<List<Movie>> getPopularMovies() =>
      KoficService.getPopularMovies();

  static Future<List<Movie>> getRecommendedMovies(int movieId) =>
      TmdbMovieService.getRecommendedMovies(movieId);

  static Future<List<Video>> getMovieVideos(int movieId) =>
      TmdbMovieService.getMovieVideos(movieId);

  static Future<List<WatchProvider>> getMovieWatchProviders(int movieId) =>
      TmdbMovieService.getMovieWatchProviders(movieId);

  static Future<List<Movie>> getMoviesByGenre(int genreId, {int page = 1}) =>
      TmdbMovieService.getMoviesByGenre(genreId, page: page);

  static Future<List<Movie>> getClassicMovies() =>
      TmdbMovieService.getClassicMovies();

  static Future<List<Person>> getPopularPeople() =>
      TmdbPersonService.getPopularPeople();

  static Future<List<Person>> searchPeople(String query) =>
      TmdbPersonService.searchPeople(query);

  static Future<List<Movie>> getMovieCreditsForPerson(int personId) =>
      TmdbPersonService.getMovieCreditsForPerson(personId);

  static Future<List<Movie>> getPersonFilmography(
    int personId, {
    bool directing = false,
  }) => TmdbPersonService.getPersonFilmography(personId, directing: directing);

  static Future<List<KoficPerson>> getKoficPeopleInfo(List<String> names) =>
      KoficService.getPeopleInfo(names);

  static Future<List<Movie>> searchMoviesByPersonName(String personName) =>
      SearchService.searchMoviesByPersonName(personName);

  static Future<List<Movie>> searchMovies(String query) =>
      SearchService.searchMovies(query);

  static Future<SearchResultPage> searchMultiPage(
    String query, {
    int page = 1,
  }) => SearchService.searchMultiPage(query, page: page);

  static Future<Map<String, List<Person>>> getPopularPeopleFromKofic() =>
      KoficService.getPopularPeople();

  static Future<List<SearchSuggestion>> getSearchSuggestions(String query) =>
      SearchService.getSearchSuggestions(query);
}
