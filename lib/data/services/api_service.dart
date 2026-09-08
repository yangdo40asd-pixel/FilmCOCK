import 'dart:convert';
import 'package:filmcock_app/data/models/movie_model.dart';
import 'package:filmcock_app/data/dummy/korean_people_data.dart';
import 'package:filmcock_app/core/config/secrets.dart';
import 'package:filmcock_app/core/utils/language_filter.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _apiKey = ApiSecrets.apiKey;
  static Future<List<Person>>? _popularPeoplePagesCache;

  // 여러 종류의 영화 목록을 가져오는 범용 함수
  static Future<List<Movie>> getMovies(
    String endpoint, {
    bool isUpcoming = false,
  }) async {
    final url = Uri.parse(
      '$_baseUrl/movie/$endpoint?api_key=$_apiKey&language=ko-KR&page=1',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // UTF-8로 디코딩하여 한글 깨짐 방지
      final utf8DecodedBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> data = jsonDecode(utf8DecodedBody);
      final List<dynamic> results = data['results'];

      // JSON 맵 리스트를 Movie 객체 리스트로 변환
      final movies = results.map((json) => Movie.fromJson(json)).toList();
      return LanguageFilter.filterMovies(movies, isUpcoming: false);
    } else {
      // 에러 발생 시 예외 처리
      throw Exception('Failed to load movies from $endpoint');
    }
  }

  // 특정 영화의 출연진(크레딧) 정보를 가져오는 함수
  static Future<List<Person>> getMovieCredits(int movieId) async {
    final url = Uri.parse(
      '$_baseUrl/movie/$movieId/credits?api_key=$_apiKey&language=ko-KR',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final utf8DecodedBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> data = jsonDecode(utf8DecodedBody);
      final List<dynamic> cast = data['cast'];
      // Person.fromJson을 사용하여 Person 객체 리스트로 변환
      return cast.map((json) => Person.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load movie credits for id $movieId');
    }
  }

  // 특정 영화 ID로 상세 정보를 가져오는 함수
  static Future<Movie> getMovieDetail(int movieId) async {
    final url = Uri.parse(
      '$_baseUrl/movie/$movieId?api_key=$_apiKey&language=ko-KR',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final utf8DecodedBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> data = jsonDecode(utf8DecodedBody);
      return Movie.fromJson(data);
    } else {
      throw Exception('Failed to load movie detail for id $movieId');
    }
  }

  // '방영 예정일 영화' 목록을 가져오는 함수
  static Future<List<Movie>> getUpcomingMovies() async {
    final url = Uri.parse(
      '$_baseUrl/movie/upcoming?api_key=$_apiKey&language=ko-KR&page=1&region=KR',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final utf8DecodedBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> data = jsonDecode(utf8DecodedBody);
      final List<dynamic> results = data['results'];

      final now = DateTime.now();
      final todayStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final movies = results
          .map((json) => Movie.fromJson(json))
          .where(
            (m) =>
                m.releaseDate.isNotEmpty &&
                m.releaseDate.compareTo(todayStr) > 0,
          )
          .toList();

      movies.sort((a, b) => a.releaseDate.compareTo(b.releaseDate));

      return LanguageFilter.filterMovies(movies, isUpcoming: true);
    } else {
      throw Exception('Failed to load upcoming movies');
    }
  }

  // '고전 명작' 목록을 가져오는 함수
  static Future<List<Movie>> getTopRatedMovies() async {
    final url = Uri.parse(
      '$_baseUrl/movie/top_rated?api_key=$_apiKey&language=ko-KR&page=1',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final utf8DecodedBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> data = jsonDecode(utf8DecodedBody);
      final List<dynamic> results = data['results'];
      final movies = results.map((json) => Movie.fromJson(json)).toList();
      return LanguageFilter.filterMovies(movies, isUpcoming: false);
    } else {
      throw Exception('Failed to load top rated movies');
    }
  }

  // '최신 상영 영화' 목록을 가져오는 함수
  static Future<List<Movie>> getNowPlayingMovies() async {
    // KOFIC 일간 박스오피스 기반 TMDB 브릿지 검색 반환
    return _getMoviesFromKofic(false);
  }

  // '인기 영화' 목록을 가져오는 함수
  static Future<List<Movie>> getPopularMovies() async {
    // KOFIC 주간 박스오피스 기반 TMDB 브릿지 검색 반환
    return _getMoviesFromKofic(true);
  }

  // '추천 영화' 목록을 가져오는 함수
  static Future<List<Movie>> getRecommendedMovies(int movieId) async {
    return getMovies('$movieId/recommendations');
  }

  // 영화 예고편(비디오) 정보를 가져오는 함수
  static Future<List<Video>> getMovieVideos(int movieId) async {
    final url = Uri.parse(
      '$_baseUrl/movie/$movieId/videos?api_key=$_apiKey&language=ko-KR',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final utf8DecodedBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> data = jsonDecode(utf8DecodedBody);
      final List<dynamic> results = data['results'];

      // YouTube 예고편만 필터링
      final videos = results
          .map((json) => Video.fromJson(json))
          .where(
            (video) =>
                video.site == 'YouTube' &&
                (video.type == 'Trailer' || video.type == 'Teaser'),
          )
          .toList();

      return videos;
    } else {
      // 비디오 정보가 없는 경우 빈 리스트를 반환하도록 예외 처리를 수정
      return [];
    }
  }

  // 국내(KR) 영화 시청 가능 서비스 정보를 가져오는 함수
  static Future<List<WatchProvider>> getMovieWatchProviders(int movieId) async {
    final url = Uri.parse(
      '$_baseUrl/movie/$movieId/watch/providers?api_key=$_apiKey',
    );
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load watch providers for movie $movieId');
    }

    final data =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final korea = data['results']?['KR'] as Map<String, dynamic>?;
    if (korea == null) return [];

    final link = korea['link'] as String? ?? '';
    const offerTypes = <String, String>{
      'flatrate': '구독',
      'free': '무료',
      'ads': '광고 포함',
      'rent': '대여',
      'buy': '구매',
    };
    final providers = <WatchProvider>[];

    for (final entry in offerTypes.entries) {
      final rawProviders = korea[entry.key] as List<dynamic>? ?? [];
      providers.addAll(
        rawProviders.whereType<Map<String, dynamic>>().map(
          (provider) => WatchProvider.fromJson(
            provider,
            offerType: entry.value,
            link: link,
          ),
        ),
      );
    }

    return providers;
  }

  // 특정 장르의 영화 목록을 가져오는 함수
  static Future<List<Movie>> getMoviesByGenre(int genreId) async {
    final url = Uri.parse(
      '$_baseUrl/discover/movie?api_key=$_apiKey&language=ko-KR&with_genres=$genreId',
    );
    // getMovies 함수를 재사용하기보다는 discover 엔드포인트에 맞게 새로 구현
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final utf8DecodedBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> data = jsonDecode(utf8DecodedBody);
      final List<dynamic> results = data['results'];
      final movies = results.map((json) => Movie.fromJson(json)).toList();
      return LanguageFilter.filterMovies(movies, isUpcoming: false);
    } else {
      throw Exception('Failed to load movies for genre $genreId');
    }
  }

  // 인기 인물(배우, 감독) 목록을 가져오는 메서드

  // 고전명작 (2000~2010년) 가져오기
  static Future<List<Movie>> getClassicMovies() async {
    final url = Uri.parse(
      '$_baseUrl/discover/movie?api_key=$_apiKey&language=ko-KR&primary_release_date.gte=2000-01-01&primary_release_date.lte=2010-12-31&sort_by=vote_average.desc&vote_count.gte=500&page=1',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final utf8DecodedBody = utf8.decode(response.bodyBytes);
      final List<dynamic> results = jsonDecode(utf8DecodedBody)['results'];
      final movies = results.map((movie) => Movie.fromJson(movie)).toList();
      return LanguageFilter.filterMovies(movies);
    } else {
      throw Exception('Failed to load classic movies');
    }
  }

  static Future<List<Person>> getPopularPeople() async {
    final koreanPattern = RegExp(r'[가-힣]');
    final people = await _getPopularPeoplePages();
    final allForeignActors = people.where((p) {
      return p.knownForDepartment == 'Acting' &&
          !koreanPattern.hasMatch(p.originalName) &&
          p.hasKoreanDisplayName;
    }).toList();

    if (allForeignActors.isEmpty) {
      throw Exception('Failed to load popular people');
    }

    final uniqueActors = <int, Person>{
      for (final person in allForeignActors) person.id: person,
    }.values.toList();
    return uniqueActors;
  }

  // 특정 인물의 출연 영화 목록(필모그래피)을 가져오는 메서드
  static Future<List<Movie>> getMovieCreditsForPerson(int personId) async {
    final url = Uri.parse(
      '$_baseUrl/person/$personId/movie_credits?api_key=$_apiKey&language=ko-KR',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final utf8DecodedBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> data = jsonDecode(utf8DecodedBody);
      // 'cast' 목록 (배우로서 출연한 작품)과 'crew' 목록 (감독/스태프로 참여한 작품)을 합칠 수 있습니다.
      // 여기서는 'cast' 목록만 가져오겠습니다.
      final List<dynamic> credits = data['cast'];
      final movies = credits
          .map((movieJson) => Movie.fromJson(movieJson))
          .toList();
      return LanguageFilter.filterMovies(movies, isUpcoming: false);
    } else {
      throw Exception('Failed to load movie credits for person $personId');
    }
  }

  static Future<List<Movie>> getPersonFilmography(
    int personId, {
    bool directing = false,
  }) async {
    final url = Uri.parse(
      '$_baseUrl/person/$personId/movie_credits?api_key=$_apiKey&language=ko-KR',
    );
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load filmography for person $personId');
    }

    final data =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final key = directing ? 'crew' : 'cast';
    final credits = data[key] as List<dynamic>? ?? [];
    final selected = directing
        ? credits.where((item) {
            final department = item['department'] as String? ?? '';
            final job = item['job'] as String? ?? '';
            return department == 'Directing' || job == 'Director';
          })
        : credits;

    final seenIds = <int>{};
    final movies = <Movie>[];
    for (final credit in selected) {
      final movie = Movie.fromJson(credit as Map<String, dynamic>);
      if (seenIds.add(movie.id)) movies.add(movie);
    }

    movies.sort((a, b) => b.releaseDate.compareTo(a.releaseDate));
    return LanguageFilter.filterMovies(movies, isUpcoming: false);
  }

  // --- 영화진흥위원회(KOFIC) API 관련 ---
  static const String _koficApiKey = '3dfc7b6fd0866165a54b374be9c4397c';
  static const String _koficBaseUrl =
      'http://www.kobis.or.kr/kobisopenapi/webservice/rest';

  static Future<http.Response> _getKofic(Uri url) async {
    Object? lastError;
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        final response = await http.get(url).timeout(const Duration(seconds: 15));
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
    throw Exception('KOBIS request failed: $lastError');
  }

  // KOFIC API로 주간 박스오피스 순위 가져오기 (지난주 기준)

  // KOFIC API를 통해 일간 박스오피스 목록 조회 (어제 기준)
  static Future<List<dynamic>> _getKoficDailyBoxOffice() async {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final targetDt =
        '${yesterday.year}${yesterday.month.toString().padLeft(2, '0')}${yesterday.day.toString().padLeft(2, '0')}';

    final url = Uri.parse(
      '$_koficBaseUrl/boxoffice/searchDailyBoxOfficeList.json?key=$_koficApiKey&targetDt=$targetDt',
    );
    final response = await _getKofic(url);

    if (response.statusCode == 200) {
      final utf8DecodedBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> data = jsonDecode(utf8DecodedBody);
      return data['boxOfficeResult']['dailyBoxOfficeList'] ?? [];
    } else {
      throw Exception('Failed to load KOFIC daily box office');
    }
  }

  // KOFIC 박스오피스 제목 기반으로 TMDB 영화 정보 검색 및 브릿지
  static Future<List<Movie>> _getMoviesFromKofic(bool isWeekly) async {
    final boxOfficeList = isWeekly
        ? await _getKoficWeeklyBoxOffice()
        : await _getKoficDailyBoxOffice();

    List<Movie> bridgeMovies = [];

    for (var koficMovie in boxOfficeList) {
      final movieNm = koficMovie['movieNm'];
      final url = Uri.parse(
        '$_baseUrl/search/movie?api_key=$_apiKey&query=${Uri.encodeComponent(movieNm)}&language=ko-KR&page=1',
      );

      try {
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final utf8DecodedBody = utf8.decode(response.bodyBytes);
          final Map<String, dynamic> data = jsonDecode(utf8DecodedBody);
          final List<dynamic> results = data['results'];

          if (results.isNotEmpty) {
            // 가장 연관도 높은 첫 번째 결과만 사용
            bridgeMovies.add(Movie.fromJson(results.first));
          }
        }
      } catch (e) {
        print('TMDB search error for $movieNm: $e');
      }
    }

    // 최종 언어 필터 거쳐서 반환
    return LanguageFilter.filterMovies(bridgeMovies);
  }

  static Future<List<dynamic>> _getKoficWeeklyBoxOffice() async {
    // 지난주 날짜 계산 (일요일 기준)
    final now = DateTime.now();
    final lastSunday = now.subtract(Duration(days: now.weekday));
    final targetDt =
        '${lastSunday.year}${lastSunday.month.toString().padLeft(2, '0')}${lastSunday.day.toString().padLeft(2, '0')}';

    final url = Uri.parse(
      '$_koficBaseUrl/boxoffice/searchWeeklyBoxOfficeList.json?key=$_koficApiKey&targetDt=$targetDt&weekGb=0', // 0: 주간
    );
    final response = await _getKofic(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['boxOfficeResult']['weeklyBoxOfficeList'];
    } else {
      throw Exception('Failed to load KOFIC weekly box office');
    }
  }

  // KOFIC 영화 코드로 영화 상세 정보(배우, 감독 포함) 가져오기
  static Future<Map<String, List<dynamic>>> _getKoficMoviePeople(
    String movieCd,
  ) async {
    final url = Uri.parse(
      '$_koficBaseUrl/movie/searchMovieInfo.json?key=$_koficApiKey&movieCd=$movieCd',
    );
    final response = await _getKofic(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // API 응답 구조에 따라 배우 목록 반환
      if (data['movieInfoResult']?['movieInfo'] != null) {
        final movieInfo = data['movieInfoResult']['movieInfo'];
        return {
          'actors': movieInfo['actors'] as List<dynamic>? ?? [],
          'directors': movieInfo['directors'] as List<dynamic>? ?? [],
        };
      }
    }
    return {'actors': [], 'directors': []}; // 정보가 없으면 빈 맵 반환
  }

  // KOFIC API로 여러 한국 영화인 정보 가져오기
  static Future<List<KoficPerson>> getKoficPeopleInfo(
    List<String> names,
  ) async {
    List<KoficPerson> results = [];
    for (String name in names) {
      final url = Uri.parse(
        '$_koficBaseUrl/people/searchPeopleList.json?key=$_koficApiKey&peopleNm=${Uri.encodeComponent(name)}',
      );
      final response = await _getKofic(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> peopleList = data['peopleListResult']['peopleList'];
        if (peopleList.isNotEmpty) {
          // 가장 첫 번째 검색 결과만 사용
          results.add(KoficPerson.fromJson(peopleList.first));
        }
      }
    }
    return results;
  }

  // 이름으로 인물을 검색하고, 해당 인물의 영화 목록을 가져오는 메서드
  static Future<List<Movie>> searchMoviesByPersonName(String personName) async {
    // 1. 이름으로 인물 검색하여 ID 얻기
    final searchUrl = Uri.parse(
      '$_baseUrl/search/person?api_key=$_apiKey&language=ko-KR&query=${Uri.encodeComponent(personName)}',
    );
    final searchResponse = await http.get(searchUrl);

    if (searchResponse.statusCode == 200) {
      final searchData = jsonDecode(utf8.decode(searchResponse.bodyBytes));
      final List<dynamic> results = searchData['results'];

      if (results.isNotEmpty) {
        // 2. 가장 정확도가 높은 첫 번째 인물의 ID로 영화 목록 조회
        final int personId = results.first['id'];
        return getMovieCreditsForPerson(personId);
      } else {
        // 검색 결과가 없으면 빈 리스트 반환
        return [];
      }
    } else {
      throw Exception('Failed to search for person: $personName');
    }
  }

  // 영화 검색
  static Future<List<Movie>> searchMovies(String query) async {
    final url = Uri.parse(
      '$_baseUrl/search/movie?api_key=$_apiKey&language=ko-KR&query=${Uri.encodeComponent(query)}&page=1',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final utf8DecodedBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> data = jsonDecode(utf8DecodedBody);
      final List<dynamic> results = data['results'];
      final movies = results.map((json) => Movie.fromJson(json)).toList();
      return LanguageFilter.filterMovies(movies, isUpcoming: false);
    } else {
      throw Exception('Failed to search movies for query: $query');
    }
  }

  // 대한민국 대표/인기 한국 배우 및 감독 목록을 가져오는 통합 함수
  static Future<Map<String, List<Person>>> getPopularPeopleFromKofic() async {
    final actors = List<Person>.from(KoreanPeopleData.masterActors);
    final directors = List<Person>.from(KoreanPeopleData.masterDirectors);

    // KOFIC 일간 박스오피스 상위작에서 현재 활약 중인 주연 배우들을 선두에 배치 (안전 타임아웃 3초)
    try {
      final boxOfficeList = await _getKoficDailyBoxOffice().timeout(
        const Duration(seconds: 3),
      );
      final topMovies = boxOfficeList.take(5);
      final currentActorNames = <String>[];
      for (var movie in topMovies) {
        final people = await _getKoficMoviePeople(movie['movieCd'] as String);
        final movieActors = people['actors'] ?? [];
        for (var actor in movieActors.take(3)) {
          final name = actor['peopleNm'] as String?;
          if (name != null && name.isNotEmpty) {
            currentActorNames.add(name);
          }
        }
      }

      // 이미 마스터에 있는 배우는 상단으로 재배치
      for (final name in currentActorNames.reversed) {
        final existingIndex = actors.indexWhere((a) => a.name == name);
        if (existingIndex > 0) {
          final matched = actors.removeAt(existingIndex);
          actors.insert(0, matched);
        }
      }
    } catch (_) {
      // 네트워크 예외 발생 시에도 마스터 데이터가 완벽하게 서비스되므로 무시
    }

    return {
      'actors': actors,
      'directors': directors,
    };
  }

  static Future<List<Person>> _getPopularPeoplePages() {
    return _popularPeoplePagesCache ??= _loadPopularPeoplePages();
  }

  static Future<List<Person>> _loadPopularPeoplePages() async {
    const totalPages = 5; // 5페이지(100명)로 최적화하여 429 에러 방지 및 초고속 로딩
    const batchSize = 5;
    final pages = <List<Person>>[];

    for (var start = 1; start <= totalPages; start += batchSize) {
      final end = (start + batchSize - 1).clamp(1, totalPages);
      final batch = await Future.wait(
        List.generate(end - start + 1, (index) async {
          final page = start + index;
          final url = Uri.parse(
            '$_baseUrl/person/popular?api_key=$_apiKey&language=ko-KR&page=$page',
          );
          final response = await http.get(url);
          if (response.statusCode != 200) return <Person>[];
          final data = jsonDecode(utf8.decode(response.bodyBytes));
          final results = data['results'] as List<dynamic>? ?? [];
          return results
              .whereType<Map<String, dynamic>>()
              .map(Person.fromJson)
              .toList();
        }),
      );
      pages.addAll(batch);
    }

    return pages.expand((page) => page).toList();
  }
}
