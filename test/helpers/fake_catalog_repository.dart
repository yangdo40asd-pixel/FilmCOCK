import 'package:filmcock_app/shared/domain/models/movie.dart';
import 'package:filmcock_app/shared/domain/models/person.dart';
import 'package:filmcock_app/shared/domain/models/search_suggestion.dart';
import 'package:filmcock_app/shared/domain/repositories/catalog_repository.dart';

/// 테스트가 외부 API로 빠지지 않게 하는 로컬 조회 구현.
class FakeCatalogRepository implements CatalogRepository {
  final List<Movie> movies;
  final List<Person> people;
  final List<String> movieQueries = [];
  final List<int> genreQueries = [];

  FakeCatalogRepository({List<Movie>? movies, this.people = const []})
    : movies =
          movies ??
          [
            Movie(
              id: 900001,
              title: '검증용 영화',
              overview: '',
              voteAverage: 8.8,
              releaseDate: '2020-01-01',
            ),
          ];

  @override
  Future<List<Movie>> getPopularMovies() async => List.of(movies);

  @override
  Future<List<Movie>> getMoviesByGenre(int genreId, {int page = 1}) async {
    genreQueries.add(genreId);
    return List.of(movies);
  }

  @override
  Future<List<Movie>> searchMovies(String query) async {
    movieQueries.add(query);
    return List.of(movies);
  }

  @override
  Future<List<Person>> searchPeople(String query) async => List.of(people);

  @override
  Future<List<Movie>> getPersonFilmography(
    int personId, {
    bool directing = false,
  }) async => List.of(movies);

  @override
  Future<List<SearchSuggestion>> getSearchSuggestions(String query) async => [
    for (final movie in movies)
      SearchSuggestion(
        id: movie.id,
        title: movie.title,
        type: SuggestionType.movie,
        movie: movie,
      ),
  ];

  @override
  Future<SearchResultPage> searchMultiPage(
    String query, {
    int page = 1,
  }) async => SearchResultPage(
    items: await getSearchSuggestions(query),
    page: page,
    totalPages: page,
  );

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('가짜 조회에서 지원하지 않는 요청: ${invocation.memberName}');
}
