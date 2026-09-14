import 'dart:convert';

import 'package:filmcock_app/core/config/secrets.dart';
import 'package:filmcock_app/core/errors/app_exception.dart';
import 'package:filmcock_app/core/utils/hangul_utils.dart';
import 'package:filmcock_app/core/utils/language_filter.dart';
import 'package:filmcock_app/data/cache/search_cache.dart';
import 'package:filmcock_app/data/dummy/korean_people_data.dart';
import 'package:filmcock_app/data/models/movie_model.dart';
import 'package:filmcock_app/data/models/search_suggestion.dart';
import 'package:filmcock_app/data/services/api_client.dart';
import 'package:filmcock_app/data/services/tmdb_person_service.dart';

class SearchService {
  const SearchService._();

  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static String get _apiKey => ApiSecrets.tmdbApiKey;

  static Future<List<Movie>> searchMovies(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const <Movie>[];
    final url = Uri.parse(
      '$_baseUrl/search/movie?api_key=$_apiKey&language=ko-KR&query=${Uri.encodeComponent(trimmed)}&page=1',
    );
    final response = await ApiClient.get(url);
    if (response.statusCode != 200) {
      throw ApiResponseException(
        statusCode: response.statusCode,
        operation: 'Search movies',
      );
    }
    final data = jsonDecode(utf8.decode(response.bodyBytes));
    final results = data['results'] as List<dynamic>? ?? [];
    final movies = results
        .whereType<Map<String, dynamic>>()
        .map(Movie.fromJson)
        .toList();
    return LanguageFilter.filterMovies(movies, isUpcoming: false);
  }

  static Future<List<Movie>> searchMoviesByPersonName(String personName) async {
    final people = await TmdbPersonService.searchPeople(personName);
    if (people.isEmpty) return const <Movie>[];
    return TmdbPersonService.getMovieCreditsForPerson(people.first.id);
  }

  static Future<SearchResultPage> searchMultiPage(
    String query, {
    int page = 1,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const SearchResultPage(items: [], page: 1, totalPages: 1);
    }
    final url = Uri.parse(
      '$_baseUrl/search/multi?api_key=$_apiKey&language=ko-KR&query=${Uri.encodeComponent(trimmed)}&page=$page',
    );
    final response = await ApiClient.get(url);
    if (response.statusCode != 200) {
      throw ApiResponseException(
        statusCode: response.statusCode,
        operation: 'Search movies and people',
      );
    }

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    final rawResults = data['results'] as List<dynamic>? ?? const [];
    final items = <SearchSuggestion>[];
    for (final raw in rawResults.whereType<Map<String, dynamic>>()) {
      final id = raw['id'] as int? ?? 0;
      if (id <= 0) continue;
      if (raw['media_type'] == 'movie') {
        final movie = Movie.fromJson(raw);
        if (movie.title.isNotEmpty) {
          items.add(
            SearchSuggestion(
              id: id,
              title: movie.title,
              type: SuggestionType.movie,
              imageUrl: movie.fullPosterUrl.isEmpty
                  ? null
                  : movie.fullPosterUrl,
              movie: movie,
            ),
          );
        }
      } else if (raw['media_type'] == 'person') {
        final person = Person.fromJson(raw);
        if (person.displayName.isNotEmpty) {
          items.add(
            SearchSuggestion(
              id: id,
              title: person.displayName,
              type: SuggestionType.person,
              imageUrl: person.fullProfileUrl.isEmpty
                  ? null
                  : person.fullProfileUrl,
              person: person,
            ),
          );
        }
      }
    }

    final normalized = trimmed.toLowerCase();
    int relevance(SearchSuggestion item) {
      final title = item.title.toLowerCase();
      if (title == normalized) return 0;
      if (title.startsWith(normalized)) return 1;
      return 2;
    }

    items.sort((a, b) {
      final order = relevance(a).compareTo(relevance(b));
      return order != 0 ? order : a.title.compareTo(b.title);
    });
    return SearchResultPage(
      items: items,
      page: data['page'] as int? ?? page,
      totalPages: (data['total_pages'] as int? ?? page).clamp(1, 500),
    );
  }

  static Future<List<SearchSuggestion>> getSearchSuggestions(
    String query,
  ) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const <SearchSuggestion>[];
    final suggestions = <SearchSuggestion>[];
    final seenKeys = <String>{};

    void addMovie(Movie movie) {
      if (seenKeys.add('m_${movie.id}')) {
        suggestions.add(
          SearchSuggestion(
            id: movie.id,
            title: movie.title,
            type: SuggestionType.movie,
            imageUrl: movie.fullPosterUrl.isEmpty ? null : movie.fullPosterUrl,
            movie: movie,
          ),
        );
      }
    }

    void addPerson(Person person) {
      if (seenKeys.add('p_${person.id}')) {
        suggestions.add(
          SearchSuggestion(
            id: person.id,
            title: person.displayName,
            type: SuggestionType.person,
            imageUrl: person.fullProfileUrl.isEmpty
                ? null
                : person.fullProfileUrl,
            person: person,
          ),
        );
      }
    }

    for (final movie in SearchCache.movies) {
      if (HangulUtils.matches(movie.title, trimmed)) addMovie(movie);
      if (suggestions.length >= 8) break;
    }
    for (final person in <Person>[
      ...KoreanPeopleData.masterActors,
      ...KoreanPeopleData.masterDirectors,
    ]) {
      if (HangulUtils.matches(person.name, trimmed)) addPerson(person);
      if (suggestions.length >= 20) break;
    }

    if (!HangulUtils.isChosungOnly(trimmed)) {
      try {
        final page = await searchMultiPage(trimmed);
        for (final item in page.items) {
          final key =
              '${item.type == SuggestionType.movie ? 'm' : 'p'}_${item.id}';
          if (seenKeys.add(key)) suggestions.add(item);
          if (suggestions.length >= 20) break;
        }
      } catch (_) {
        if (suggestions.isEmpty) rethrow;
      }
    }
    return suggestions.take(15).toList();
  }
}
