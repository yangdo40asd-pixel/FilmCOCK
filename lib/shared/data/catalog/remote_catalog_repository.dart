import 'package:filmcock_app/shared/domain/repositories/catalog_repository.dart';
import 'package:filmcock_app/shared/domain/models/catalog_models.dart';
import 'package:filmcock_app/shared/domain/models/search_suggestion.dart';
import 'package:filmcock_app/shared/data/kofic/kofic_service.dart';
import 'package:filmcock_app/shared/data/search/search_service.dart';
import 'package:filmcock_app/shared/data/tmdb/tmdb_movie_service.dart';
import 'package:filmcock_app/shared/data/tmdb/tmdb_person_service.dart';

/// TMDB·KOFIC 전용 구현을 공용 조회 계약에 연결한다.
class RemoteCatalogRepository implements CatalogRepository {
  const RemoteCatalogRepository();

  @override
  Future<List<Person>> getMovieCredits(int movieId) =>
      TmdbMovieService.getMovieCredits(movieId);

  @override
  Future<Movie> getMovieDetail(int movieId) =>
      TmdbMovieService.getMovieDetail(movieId);

  @override
  Future<List<Movie>> getUpcomingMovies() =>
      TmdbMovieService.getUpcomingMovies();

  @override
  Future<List<Movie>> getTopRatedMovies() =>
      TmdbMovieService.getTopRatedMovies();

  @override
  Future<List<Movie>> getNowPlayingMovies() =>
      KoficService.getNowPlayingMovies();

  @override
  Future<List<Movie>> getPopularMovies() => KoficService.getPopularMovies();

  @override
  Future<List<Movie>> getRecommendedMovies(int movieId) =>
      TmdbMovieService.getRecommendedMovies(movieId);

  @override
  Future<List<Video>> getMovieVideos(int movieId) =>
      TmdbMovieService.getMovieVideos(movieId);

  @override
  Future<List<WatchProvider>> getMovieWatchProviders(int movieId) =>
      TmdbMovieService.getMovieWatchProviders(movieId);

  @override
  Future<List<Movie>> getMoviesByGenre(int genreId, {int page = 1}) =>
      TmdbMovieService.getMoviesByGenre(genreId, page: page);

  @override
  Future<List<Movie>> getClassicMovies() => TmdbMovieService.getClassicMovies();

  @override
  Future<List<Person>> getPopularPeople() =>
      TmdbPersonService.getPopularPeople();

  @override
  Future<List<Person>> searchPeople(String query) =>
      TmdbPersonService.searchPeople(query);

  @override
  Future<List<Movie>> getPersonFilmography(
    int personId, {
    bool directing = false,
  }) => TmdbPersonService.getPersonFilmography(personId, directing: directing);

  @override
  Future<List<Movie>> searchMoviesByPersonName(String personName) =>
      SearchService.searchMoviesByPersonName(personName);

  @override
  Future<List<Movie>> searchMovies(String query) =>
      SearchService.searchMovies(query);

  @override
  Future<SearchResultPage> searchMultiPage(String query, {int page = 1}) =>
      SearchService.searchMultiPage(query, page: page);

  @override
  Future<Map<String, List<Person>>> getPopularPeopleFromKofic() =>
      KoficService.getPopularPeople();

  @override
  Future<List<SearchSuggestion>> getSearchSuggestions(String query) =>
      SearchService.getSearchSuggestions(query);
}
