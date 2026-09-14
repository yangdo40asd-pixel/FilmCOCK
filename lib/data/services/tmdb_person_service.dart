import 'dart:convert';

import 'package:filmcock_app/core/config/secrets.dart';
import 'package:filmcock_app/core/errors/app_exception.dart';
import 'package:filmcock_app/core/utils/language_filter.dart';
import 'package:filmcock_app/data/models/movie_model.dart';
import 'package:filmcock_app/data/services/api_client.dart';

class TmdbPersonService {
  const TmdbPersonService._();

  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static String get _apiKey => ApiSecrets.tmdbApiKey;
  static Future<List<Person>>? _popularPeoplePagesCache;

  static Future<List<Person>> getPopularPeople() async {
    final koreanPattern = RegExp(r'[가-힣]');
    final people = await _getPopularPeoplePages();
    final actors = people.where((person) {
      return person.knownForDepartment == 'Acting' &&
          !koreanPattern.hasMatch(person.originalName) &&
          person.hasKoreanDisplayName;
    }).toList();

    if (actors.isEmpty) {
      throw const AppException(
        userMessage: '표시할 해외 배우 정보를 찾지 못했습니다.',
        technicalMessage: 'Popular people response contained no usable actors',
      );
    }

    return <int, Person>{
      for (final person in actors) person.id: person,
    }.values.toList();
  }

  static Future<List<Person>> searchPeople(String query) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) return const <Person>[];

    final url = Uri.parse(
      '$_baseUrl/search/person?api_key=$_apiKey&query=${Uri.encodeComponent(normalizedQuery)}&language=ko-KR&page=1',
    );
    final response = await ApiClient.get(url);
    if (response.statusCode != 200) {
      throw ApiResponseException(
        statusCode: response.statusCode,
        operation: 'Search people',
      );
    }

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    final results = data['results'] as List<dynamic>? ?? [];
    return results
        .whereType<Map<String, dynamic>>()
        .map(Person.fromJson)
        .where((person) => person.id > 0 && person.displayName.isNotEmpty)
        .toList();
  }

  static Future<List<Movie>> getMovieCreditsForPerson(int personId) async {
    return getPersonFilmography(personId);
  }

  static Future<List<Movie>> getPersonFilmography(
    int personId, {
    bool directing = false,
  }) async {
    final url = Uri.parse(
      '$_baseUrl/person/$personId/movie_credits?api_key=$_apiKey&language=ko-KR',
    );
    final response = await ApiClient.get(url);
    if (response.statusCode != 200) {
      throw ApiResponseException(
        statusCode: response.statusCode,
        operation: 'Load filmography for person $personId',
      );
    }

    final data =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final credits = data[directing ? 'crew' : 'cast'] as List<dynamic>? ?? [];
    final selected = directing
        ? credits.where((item) {
            final department = item['department'] as String? ?? '';
            final job = item['job'] as String? ?? '';
            return department == 'Directing' || job == 'Director';
          })
        : credits;

    final seenIds = <int>{};
    final movies = <Movie>[];
    for (final credit in selected.whereType<Map<String, dynamic>>()) {
      final movie = Movie.fromJson(credit);
      if (seenIds.add(movie.id)) movies.add(movie);
    }
    movies.sort((a, b) => b.releaseDate.compareTo(a.releaseDate));
    return LanguageFilter.filterMovies(movies, isUpcoming: false);
  }

  static Future<List<Person>> _getPopularPeoplePages() {
    return _popularPeoplePagesCache ??= _loadPopularPeoplePages();
  }

  static Future<List<Person>> _loadPopularPeoplePages() async {
    const totalPages = 5;
    final pages = await Future.wait(
      List.generate(totalPages, (index) async {
        final page = index + 1;
        final url = Uri.parse(
          '$_baseUrl/person/popular?api_key=$_apiKey&language=ko-KR&page=$page',
        );
        final response = await ApiClient.get(url);
        if (response.statusCode != 200) {
          throw ApiResponseException(
            statusCode: response.statusCode,
            operation: 'Load popular people page $page',
          );
        }
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final results = data['results'] as List<dynamic>? ?? [];
        return results
            .whereType<Map<String, dynamic>>()
            .map(Person.fromJson)
            .toList();
      }),
    );
    return pages.expand((page) => page).toList();
  }
}
