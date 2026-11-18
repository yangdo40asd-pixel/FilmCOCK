import 'package:filmcock_app/shared/domain/models/movie.dart';
import 'package:filmcock_app/shared/domain/models/person.dart';
import 'package:filmcock_app/shared/domain/models/video.dart';
import 'package:filmcock_app/shared/domain/models/watch_provider.dart';
import 'package:filmcock_app/shared/domain/models/search_suggestion.dart';

/// 화면과 추천 정책이 사용하는 영화·인물 조회 계약.
abstract interface class CatalogRepository {
  Future<List<Person>> getMovieCredits(int movieId);
  Future<Movie> getMovieDetail(int movieId);
  Future<List<Movie>> getUpcomingMovies();
  Future<List<Movie>> getTopRatedMovies();
  Future<List<Movie>> getNowPlayingMovies();
  Future<List<Movie>> getPopularMovies();
  Future<List<Movie>> getRecommendedMovies(int movieId);
  Future<List<Video>> getMovieVideos(int movieId);
  Future<List<WatchProvider>> getMovieWatchProviders(int movieId);
  Future<List<Movie>> getMoviesByGenre(int genreId, {int page = 1});
  Future<List<Movie>> getClassicMovies();
  Future<List<Person>> getPopularPeople();
  Future<List<Person>> searchPeople(String query);
  Future<List<Movie>> getPersonFilmography(
    int personId, {
    bool directing = false,
  });
  Future<List<Movie>> searchMoviesByPersonName(String personName);
  Future<List<Movie>> searchMovies(String query);
  Future<SearchResultPage> searchMultiPage(String query, {int page = 1});
  Future<Map<String, List<Person>>> getPopularPeopleFromKofic();
  Future<List<SearchSuggestion>> getSearchSuggestions(String query);
}
