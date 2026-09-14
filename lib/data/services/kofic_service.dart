import 'dart:convert';

import 'package:filmcock_app/core/config/secrets.dart';
import 'package:filmcock_app/core/errors/app_exception.dart';
import 'package:filmcock_app/core/utils/language_filter.dart';
import 'package:filmcock_app/data/dummy/korean_people_data.dart';
import 'package:filmcock_app/data/models/movie_model.dart';
import 'package:filmcock_app/data/services/api_client.dart';
import 'package:http/http.dart' as http;

class KoficService {
  const KoficService._();

  static const String _koficBaseUrl =
      'https://www.kobis.or.kr/kobisopenapi/webservice/rest';
  static const String _tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static String get _koficApiKey => ApiSecrets.koficApiKey;
  static String get _tmdbApiKey => ApiSecrets.tmdbApiKey;

  static Future<List<Movie>> getNowPlayingMovies() => _getBoxOffice(false);

  static Future<List<Movie>> getPopularMovies() => _getBoxOffice(true);

  static Future<List<KoficPerson>> getPeopleInfo(List<String> names) async {
    final people = <KoficPerson>[];
    for (final name in names) {
      final response = await _getKofic(
        Uri.parse(
          '$_koficBaseUrl/people/searchPeopleList.json?key=$_koficApiKey&peopleNm=${Uri.encodeComponent(name)}',
        ),
      );
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final values =
          data['peopleListResult']?['peopleList'] as List<dynamic>? ?? const [];
      final first = values.whereType<Map<String, dynamic>>().firstOrNull;
      if (first != null) people.add(KoficPerson.fromJson(first));
    }
    return people;
  }

  static Future<Map<String, List<Person>>> getPopularPeople() async {
    final actors = List<Person>.from(KoreanPeopleData.masterActors);
    final directors = List<Person>.from(KoreanPeopleData.masterDirectors);
    try {
      final boxOffice = await _getDailyBoxOffice().timeout(
        const Duration(seconds: 3),
      );
      final peopleByMovie = await Future.wait(
        boxOffice
            .take(5)
            .map(
              (movie) =>
                  _getMoviePeople(movie['movieCd']?.toString() ?? '').timeout(
                    const Duration(seconds: 5),
                    onTimeout: () => const {'actors': [], 'directors': []},
                  ),
            ),
      );
      final currentActorNames = <String>[];
      for (final people in peopleByMovie) {
        for (final actor
            in (people['actors'] ?? const [])
                .whereType<Map<String, dynamic>>()
                .take(3)) {
          final name = actor['peopleNm']?.toString() ?? '';
          if (name.isNotEmpty) currentActorNames.add(name);
        }
      }
      for (final name in currentActorNames.reversed) {
        final index = actors.indexWhere((person) => person.name == name);
        if (index > 0) actors.insert(0, actors.removeAt(index));
      }
    } catch (_) {
      // 정적 인물 데이터는 KOFIC가 일시적으로 실패해도 계속 제공한다.
    }
    return {'actors': actors, 'directors': directors};
  }

  static Future<List<Movie>> _getBoxOffice(bool weekly) async {
    final boxOffice = weekly
        ? await _getWeeklyBoxOffice()
        : await _getDailyBoxOffice();
    final movies = await Future.wait<Movie?>(
      boxOffice.map((item) async {
        final koreanTitle = item['movieNm']?.toString().trim() ?? '';
        if (koreanTitle.isEmpty) return null;
        final englishTitle = item['movieNmEn']?.toString().trim() ?? '';
        final openDate = item['openDt']?.toString() ?? '';
        final releaseYear = openDate.length >= 4
            ? openDate.substring(0, 4)
            : '';
        try {
          final response = await ApiClient.get(
            Uri.parse(
              '$_tmdbBaseUrl/search/movie?api_key=$_tmdbApiKey&query=${Uri.encodeComponent(koreanTitle)}&language=ko-KR&page=1',
            ),
          );
          if (response.statusCode != 200) return null;
          final data = jsonDecode(utf8.decode(response.bodyBytes));
          final results = (data['results'] as List<dynamic>? ?? const [])
              .whereType<Map<String, dynamic>>()
              .toList();
          final selected = _selectSafeTmdbMatch(
            results,
            koreanTitle: koreanTitle,
            englishTitle: englishTitle,
            releaseYear: releaseYear,
          );
          return selected == null ? null : Movie.fromJson(selected);
        } catch (_) {
          return null;
        }
      }),
    );
    return LanguageFilter.filterMovies(movies.whereType<Movie>().toList());
  }

  static Future<List<dynamic>> _getDailyBoxOffice() async {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final date = _compactDate(yesterday);
    final response = await _getKofic(
      Uri.parse(
        '$_koficBaseUrl/boxoffice/searchDailyBoxOfficeList.json?key=$_koficApiKey&targetDt=$date',
      ),
    );
    final data = jsonDecode(utf8.decode(response.bodyBytes));
    return data['boxOfficeResult']?['dailyBoxOfficeList'] as List<dynamic>? ??
        const [];
  }

  static Future<List<dynamic>> _getWeeklyBoxOffice() async {
    final now = DateTime.now();
    final date = _compactDate(now.subtract(Duration(days: now.weekday)));
    final response = await _getKofic(
      Uri.parse(
        '$_koficBaseUrl/boxoffice/searchWeeklyBoxOfficeList.json?key=$_koficApiKey&targetDt=$date&weekGb=0',
      ),
    );
    final data = jsonDecode(utf8.decode(response.bodyBytes));
    return data['boxOfficeResult']?['weeklyBoxOfficeList'] as List<dynamic>? ??
        const [];
  }

  static Future<Map<String, List<dynamic>>> _getMoviePeople(
    String movieCode,
  ) async {
    if (movieCode.isEmpty) return const {'actors': [], 'directors': []};
    final response = await _getKofic(
      Uri.parse(
        '$_koficBaseUrl/movie/searchMovieInfo.json?key=$_koficApiKey&movieCd=$movieCode',
      ),
    );
    final data = jsonDecode(utf8.decode(response.bodyBytes));
    final movieInfo = data['movieInfoResult']?['movieInfo'];
    return {
      'actors': movieInfo?['actors'] as List<dynamic>? ?? const [],
      'directors': movieInfo?['directors'] as List<dynamic>? ?? const [],
    };
  }

  static Future<http.Response> _getKofic(Uri url) async {
    Object? lastError;
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        final response = await ApiClient.get(url);
        if (response.statusCode == 200) return response;
        lastError = 'HTTP ${response.statusCode}';
        if (response.statusCode < 500 && response.statusCode != 429) break;
      } catch (error) {
        lastError = error;
      }
      if (attempt < 2) {
        await Future<void>.delayed(Duration(milliseconds: 500 * (attempt + 1)));
      }
    }
    if (lastError is AppException) throw lastError;
    throw AppException(
      userMessage: '박스오피스 정보를 불러오지 못했습니다. 잠시 후 다시 시도해주세요.',
      technicalMessage: 'KOBIS request failed: $lastError',
    );
  }

  static Map<String, dynamic>? _selectSafeTmdbMatch(
    List<Map<String, dynamic>> results, {
    required String koreanTitle,
    required String englishTitle,
    required String releaseYear,
  }) {
    final expected = <String>{
      _normalizeTitle(koreanTitle),
      if (englishTitle.isNotEmpty) _normalizeTitle(englishTitle),
    }..remove('');
    final titleMatches = results.where((item) {
      final titles = <String>{
        _normalizeTitle(item['title']?.toString() ?? ''),
        _normalizeTitle(item['original_title']?.toString() ?? ''),
      }..remove('');
      return titles.any(expected.contains);
    }).toList();
    if (releaseYear.isEmpty) {
      return titleMatches.length == 1 ? titleMatches.single : null;
    }
    final yearMatches =
        titleMatches.where((item) {
          final date = item['release_date']?.toString() ?? '';
          return date.length >= 4 && date.substring(0, 4) == releaseYear;
        }).toList()..sort((a, b) {
          final votes = _number(
            b['vote_count'],
          ).compareTo(_number(a['vote_count']));
          return votes != 0
              ? votes
              : _number(b['popularity']).compareTo(_number(a['popularity']));
        });
    return yearMatches.firstOrNull;
  }

  static String _compactDate(DateTime date) {
    return '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
  }

  static String _normalizeTitle(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'''[\s\u00a0·:：\-_,.!?'"“”‘’()\[\]{}<>/\\]'''), '')
        .trim();
  }

  static double _number(dynamic value) {
    return value is num
        ? value.toDouble()
        : double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
