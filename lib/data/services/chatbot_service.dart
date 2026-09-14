import 'package:filmcock_app/data/models/movie_model.dart';
import 'package:filmcock_app/data/services/api_service.dart';
import 'package:filmcock_app/data/chatbot/chatbot_database.dart';
import 'package:filmcock_app/data/services/movie_history_service.dart';
import 'package:filmcock_app/data/models/chat_intent.dart';
import 'package:filmcock_app/data/services/personalized_recommendation_service.dart';
import 'package:filmcock_app/data/repositories/user_settings_repository.dart';

enum ChatbotDialogueState { initial, awaitingMoodGenre }

class ChatMessage {
  final String text;
  final bool isUser;
  final List<String>? followUpOptions;
  final List<Movie>? recommendedMovies;
  final List<String>? movieReasons;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.followUpOptions,
    this.recommendedMovies,
    this.movieReasons,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ChatbotService {
  final UserSettingsRepository _settingsRepository =
      const UserSettingsRepository();
  ChatbotDialogueState _state = ChatbotDialogueState.initial;
  Set<int> _excludedMovieIds = const <int>{};
  final Set<int> _recentRecommendationIds = <int>{};

  ChatbotDialogueState get state => _state;

  void reset() {
    _state = ChatbotDialogueState.initial;
    _recentRecommendationIds.clear();
  }

  Future<ChatMessage> processInput(String rawInput, {String? promptId}) async {
    await ChatbotDatabase.ensureLoaded();
    final match = ChatIntentResolver.resolve(rawInput, promptId: promptId);
    final input = match.normalizedInput;
    final intent = match.intent;
    _excludedMovieIds = await MovieHistoryService.excludedMovieIds();

    // 1. 대화 상태가 기분 꼬리질문 대기 중인 경우
    if (_state == ChatbotDialogueState.awaitingMoodGenre) {
      _state = ChatbotDialogueState.initial;
      if (promptId == null && ChatIntentResolver.isMoodFollowUp(input)) {
        return _handleMoodGenreFollowUp(input);
      }
    }

    // 2. 초기 상태에서 기분/감정이 별로라는 폭넓은 질의 감지 -> 꼬리질문 트리거
    if (intent == ChatIntent.moodVague) {
      _state = ChatbotDialogueState.awaitingMoodGenre;
      return ChatMessage(
        text:
            '오늘 힘든 일이 있으셨군요. 지친 마음에 작은 위로와 기분 전환을 도와드리겠습니다. 어떤 느낌의 장르로 기분을 환기하고 싶으신가요?',
        isUser: false,
        followUpOptions: const [
          '빵 터지는 코미디',
          '따뜻한 힐링',
          '생각 없이 보는 액션',
          '펑펑 우는 감동 드라마',
        ],
      );
    }

    // 3. 힐링 직접 요청
    if (intent == ChatIntent.healing) {
      final matches = _getCuratedByCategories(['힐링']);
      return ChatMessage(
        text:
            '몸과 마음이 지쳤을 때는 자극 없는 따뜻한 이야기가 최고의 처방입니다. 마음에 잔잔한 여운을 줄 힐링 작품들을 추천합니다.',
        isUser: false,
        recommendedMovies: matches.map((m) => m.toMovie()).toList(),
        movieReasons: matches.map((m) => m.reason).toList(),
      );
    }

    // 4. 스트레스 / 사이다
    if (intent == ChatIntent.stressRelief) {
      final matches = _getCuratedByCategories(['스트레스', '코미디']);
      return ChatMessage(
        text: '답답했던 속을 시원하게 뚫어줄 유쾌하고 통쾌한 사이다 영화들입니다. 복잡한 생각 없이 마음껏 웃어보세요.',
        isUser: false,
        recommendedMovies: matches.map((m) => m.toMovie()).toList(),
        movieReasons: matches.map((m) => m.reason).toList(),
      );
    }

    if (intent == ChatIntent.emotional) {
      final matches = _getCuratedByCategories(['감동', '기분_드라마']);
      return ChatMessage(
        text: '마음껏 감정을 비워내고 깊은 여운을 느낄 수 있는 감동적인 작품들입니다.',
        isUser: false,
        recommendedMovies: matches.map((m) => m.toMovie()).toList(),
        movieReasons: matches.map((m) => m.reason).toList(),
      );
    }

    // 5. 혼맥 / 심야
    if (intent == ChatIntent.beerNight) {
      final matches = _getCuratedByCategories(['혼맥', '액션']);
      return ChatMessage(
        text: '시원한 캔맥주 한 캔과 함께 가볍게 감상하기 좋은 작품들입니다. 편안한 혼자만의 밤을 만끽해보세요.',
        isUser: false,
        recommendedMovies: matches.map((m) => m.toMovie()).toList(),
        movieReasons: matches.map((m) => m.reason).toList(),
      );
    }

    // 6. 주말 몰입작
    if (intent == ChatIntent.weekend) {
      final matches = _getCuratedByCategories(['주말', '스릴러']);
      return ChatMessage(
        text: '주말 동안 시간 가는 줄 모르고 빠져들 수 있는 높은 완성도의 명작들입니다. 빈틈없는 몰입감을 선사합니다.',
        isUser: false,
        recommendedMovies: matches.map((m) => m.toMovie()).toList(),
        movieReasons: matches.map((m) => m.reason).toList(),
      );
    }

    // 7. 반전 / 스릴러
    if (intent == ChatIntent.thriller) {
      final matches = _getCuratedByCategories(['반전', '스릴러']);
      return ChatMessage(
        text:
            '마지막 순간까지 방심할 수 없는 치밀한 두뇌 싸움과 충격적인 결말의 스릴러 명작입니다. 결말의 전율을 직접 느껴보세요.',
        isUser: false,
        recommendedMovies: matches.map((m) => m.toMovie()).toList(),
        movieReasons: matches.map((m) => m.reason).toList(),
      );
    }

    // 8. 데이트 / 설렘 / 로맨스
    if (intent == ChatIntent.romance) {
      final matches = _getCuratedByCategories(['로맨스', '데이트']);
      return ChatMessage(
        text: '보는 내내 마음에 기분 좋은 설렘과 따뜻한 온기를 불어넣어 줄 검증된 로맨스 작품들입니다.',
        isUser: false,
        recommendedMovies: matches.map((m) => m.toMovie()).toList(),
        movieReasons: matches.map((m) => m.reason).toList(),
      );
    }

    // 9. 비 오는 날
    if (intent == ChatIntent.rainyDay) {
      final matches = _getCuratedByCategories(['비오는날', '스릴러']);
      return ChatMessage(
        text: '창밖 빗소리와 함께 방 안에서 불을 끄고 집중하기 좋은 묵직한 분위기의 미스터리 수작입니다.',
        isUser: false,
        recommendedMovies: matches.map((m) => m.toMovie()).toList(),
        movieReasons: matches.map((m) => m.reason).toList(),
      );
    }

    if (intent == ChatIntent.family) {
      return _recommendFromGenre(
        genreId: 10751,
        fallbackCategories: const ['힐링'],
        message: '가족과 함께 편안하게 즐길 수 있는 따뜻한 작품들입니다.',
      );
    }

    if (intent == ChatIntent.midnight) {
      final matches = _getCuratedByCategories(['심야']);
      return ChatMessage(
        text: '조용한 밤의 분위기와 잘 어울리는 몰입도 높은 작품들입니다.',
        isUser: false,
        recommendedMovies: matches.map((m) => m.toMovie()).toList(),
        movieReasons: matches.map((m) => m.reason).toList(),
      );
    }

    if (intent == ChatIntent.art) {
      final matches = _getCuratedByCategories(['예술']);
      return ChatMessage(
        text: '영상과 음악의 조화를 오래 기억할 수 있는 예술적인 작품들입니다.',
        isUser: false,
        recommendedMovies: matches.map((m) => m.toMovie()).toList(),
        movieReasons: matches.map((m) => m.reason).toList(),
      );
    }

    if (intent == ChatIntent.boxOffice) {
      try {
        final movies = _takeFreshMovies(await ApiService.getPopularMovies(), 3);
        if (movies.isNotEmpty) {
          return ChatMessage(
            text: '현재 국내 박스오피스 흐름을 기준으로 주목받는 작품들입니다.',
            isUser: false,
            recommendedMovies: movies,
            movieReasons: movies.map((_) => '현재 박스오피스에서 주목받는 작품입니다.').toList(),
          );
        }
      } catch (_) {}
      final fallback = _getCuratedByCategories(const ['명작', '힐링']);
      return ChatMessage(
        text: '실시간 박스오피스를 불러오지 못해 앱에 준비된 인기 명작을 대신 추천합니다.',
        isUser: false,
        recommendedMovies: fallback.map((movie) => movie.toMovie()).toList(),
        movieReasons: fallback.map((movie) => movie.reason).toList(),
        followUpOptions: const ['박스오피스 다시 보기'],
      );
    }

    // 10. SF / 판타지
    if (intent == ChatIntent.scienceFiction) {
      final matches = _getCuratedByCategories(['SF']);
      return ChatMessage(
        text: '경이로운 우주 영상미와 독창적인 상상력이 돋보이는 SF 대작들입니다. 가슴 벅찬 감동을 경험해보세요.',
        isUser: false,
        recommendedMovies: matches.map((m) => m.toMovie()).toList(),
        movieReasons: matches.map((m) => m.reason).toList(),
      );
    }

    // 11. 한국 코미디
    if (intent == ChatIntent.comedy) {
      final matches = _getCuratedByCategories(['코미디']);
      return ChatMessage(
        text: '쉴 새 없이 터지는 대사와 유쾌한 상황극으로 스트레스를 단숨에 날려버릴 한국 코미디 명작입니다.',
        isUser: false,
        recommendedMovies: matches.map((m) => m.toMovie()).toList(),
        movieReasons: matches.map((m) => m.reason).toList(),
      );
    }

    // 12. MBTI 맞춤
    if (intent == ChatIntent.mbti) {
      final mbti = await _settingsRepository.loadMbti();
      final genres = await _settingsRepository.loadGenres();
      final fallback = ChatbotDatabase.validCuratedMovies
          .where((movie) => !_excludedMovieIds.contains(movie.id))
          .take(3)
          .map((movie) => movie.toMovie())
          .toList();
      final recommendation = await PersonalizedRecommendationService.load(
        mbti: mbti,
        genres: genres,
        fallback: fallback,
      );
      if (!recommendation.isPersonalized) {
        return ChatMessage(
          text: 'MBTI를 먼저 설정하면 성향에 맞는 장르로 추천해드릴 수 있어요.',
          isUser: false,
          followUpOptions: const ['힐링', '코미디', '액션', '감동 드라마'],
        );
      }

      final movies = _takeFreshMovies(recommendation.movies, 3);
      final preferenceLabel = mbti == null ? '선택한 취향' : '$mbti 성향';
      return ChatMessage(
        text:
            '$preferenceLabel 및 ${recommendation.genreName} 장르를 반영한 맞춤 추천입니다.',
        isUser: false,
        recommendedMovies: movies,
        movieReasons: movies
            .map((_) => '$preferenceLabel · ${recommendation.genreName} 장르 추천')
            .toList(),
      );
    }

    // 13. 평점 8.5 이상 명작
    if (intent == ChatIntent.highRated) {
      final candidates = ChatbotDatabase.validCuratedMovies
          .where(
            (movie) =>
                movie.voteAverage >= 8.5 &&
                !_excludedMovieIds.contains(movie.id),
          )
          .toList();
      final fresh = candidates
          .where((movie) => !_recentRecommendationIds.contains(movie.id))
          .take(3)
          .toList();
      final matches = fresh.isNotEmpty ? fresh : candidates.take(3).toList();
      _rememberMovieIds(matches.map((movie) => movie.id));
      return ChatMessage(
        text: '평단과 대중 모두에게 만점에 가까운 평가를 받은 실패 없는 인생 명작들입니다. 믿고 감상해보세요.',
        isUser: false,
        recommendedMovies: matches.map((m) => m.toMovie()).toList(),
        movieReasons: matches.map((m) => m.reason).toList(),
      );
    }

    if (intent == ChatIntent.personFilmography) {
      return _searchPersonFilmography(
        match.searchTerm ?? '',
        directing: input.contains('감독'),
      );
    }

    if (intent == ChatIntent.movieTitle) {
      return _searchMovieTitle(match.searchTerm ?? '');
    }

    return ChatMessage(
      text:
          '영화 추천과 영화 제목 검색, 배우·감독의 출연작 안내를 도와드릴 수 있어요. 예: “힐링 영화 추천”, “영화 기생충 찾아줘”, “봉준호 감독 작품”.',
      isUser: false,
      followUpOptions: const ['힐링 영화', '박스오피스', 'MBTI 맞춤', '평점 높은 명작'],
    );
  }

  Future<ChatMessage> _searchMovieTitle(String title) async {
    try {
      final movies = _takeFreshMovies(await ApiService.searchMovies(title), 3);
      if (movies.isEmpty) {
        return ChatMessage(
          text: '“$title” 제목으로 찾은 영화가 없습니다. 제목을 확인해 다시 입력해주세요.',
          isUser: false,
        );
      }
      return ChatMessage(
        text: '“$title” 제목과 관련된 영화를 찾았습니다.',
        isUser: false,
        recommendedMovies: movies,
        movieReasons: movies
            .map(
              (movie) =>
                  '제목 검색 결과 · 평점 ${movie.voteAverage.toStringAsFixed(1)}',
            )
            .toList(),
      );
    } catch (_) {
      return _localFallbackWithRetry('영화 검색 서버에 연결하지 못했습니다.', '영화 $title 찾아줘');
    }
  }

  Future<ChatMessage> _searchPersonFilmography(
    String name, {
    required bool directing,
  }) async {
    try {
      final people = await ApiService.searchPeople(name);
      if (people.isEmpty) {
        return ChatMessage(
          text: '“$name” 이름으로 찾은 영화인이 없습니다. 이름을 확인해 다시 입력해주세요.',
          isUser: false,
        );
      }

      final person = people.first;
      final movies = _takeFreshMovies(
        await ApiService.getPersonFilmography(person.id, directing: directing),
        3,
      );
      if (movies.isEmpty) {
        return ChatMessage(
          text:
              '${person.displayName}님의 ${directing ? '연출작' : '출연작'} 정보를 찾지 못했습니다.',
          isUser: false,
        );
      }
      return ChatMessage(
        text: '${person.displayName}님의 대표 ${directing ? '연출작' : '출연작'}입니다.',
        isUser: false,
        recommendedMovies: movies,
        movieReasons: movies
            .map((_) => '${person.displayName} ${directing ? '감독' : '출연'} 작품')
            .toList(),
      );
    } catch (_) {
      return _localFallbackWithRetry(
        '인물 정보를 불러오지 못했습니다.',
        '$name ${directing ? '감독 작품' : '배우 출연작'}',
      );
    }
  }

  ChatMessage _localFallbackWithRetry(String message, String retryText) {
    final fallback = _getCuratedByCategories(const ['명작', '힐링']);
    return ChatMessage(
      text: '$message 앱에 준비된 추천작을 대신 보여드릴게요.',
      isUser: false,
      recommendedMovies: fallback.map((movie) => movie.toMovie()).toList(),
      movieReasons: fallback.map((movie) => movie.reason).toList(),
      followUpOptions: [retryText],
    );
  }

  Future<ChatMessage> _recommendFromGenre({
    required int genreId,
    required List<String> fallbackCategories,
    required String message,
  }) async {
    try {
      final movies = _takeFreshMovies(
        await ApiService.getMoviesByGenre(genreId),
        3,
      );
      if (movies.isNotEmpty) {
        return ChatMessage(
          text: message,
          isUser: false,
          recommendedMovies: movies,
          movieReasons: movies.map((_) => '선호 장르와 현재 인기도를 반영했습니다.').toList(),
        );
      }
    } catch (_) {}
    final fallback = _getCuratedByCategories(fallbackCategories);
    return ChatMessage(
      text: message,
      isUser: false,
      recommendedMovies: fallback.map((movie) => movie.toMovie()).toList(),
      movieReasons: fallback.map((movie) => movie.reason).toList(),
    );
  }

  static bool isRainyDayQuery(String input) {
    return input.contains('비 오는') ||
        input.contains('비오는') ||
        input.contains('빗소리') ||
        input.contains('장마');
  }

  ChatMessage _handleMoodGenreFollowUp(String input) {
    if (input.contains('코미디') || input.contains('웃') || input.contains('빵')) {
      final matches = _getCuratedByCategories(['코미디', '기분_코미디']);
      return ChatMessage(
        text: '지친 마음에 활력을 불어넣어 줄 유쾌한 코미디 작품들을 선정했습니다. 가볍게 웃으며 기분을 전환해보세요.',
        isUser: false,
        recommendedMovies: matches.map((m) => m.toMovie()).toList(),
        movieReasons: matches.map((m) => m.reason).toList(),
      );
    }

    if (input.contains('힐링') || input.contains('따뜻') || input.contains('몽글')) {
      final matches = _getCuratedByCategories(['힐링', '기분_힐링']);
      return ChatMessage(
        text: '마음을 편안하게 다독여 줄 온화하고 감동적인 힐링 명작입니다. 따뜻한 위안의 시간을 가져보세요.',
        isUser: false,
        recommendedMovies: matches.map((m) => m.toMovie()).toList(),
        movieReasons: matches.map((m) => m.reason).toList(),
      );
    }

    if (input.contains('액션') || input.contains('생각 없이')) {
      final matches = _getCuratedByCategories(['액션', '기분_액션']);
      return ChatMessage(
        text: '복잡한 생각 없이 스트레스를 한 번에 날려버릴 화끈한 액션 영화들입니다. 시원한 속도감을 즐겨보세요.',
        isUser: false,
        recommendedMovies: matches.map((m) => m.toMovie()).toList(),
        movieReasons: matches.map((m) => m.reason).toList(),
      );
    }

    // 드라마 / 눈물
    final matches = _getCuratedByCategories(['감동', '기분_드라마']);
    return ChatMessage(
      text: '답답했던 마음을 시원하게 씻어내 줄 깊은 울림의 드라마 작품입니다. 마음껏 감정을 비워내 보세요.',
      isUser: false,
      recommendedMovies: matches.map((m) => m.toMovie()).toList(),
      movieReasons: matches.map((m) => m.reason).toList(),
    );
  }

  List<ChatbotMovieData> _getCuratedByCategories(List<String> categories) {
    final results = <ChatbotMovieData>[];
    for (final movie in ChatbotDatabase.validCuratedMovies) {
      if (_excludedMovieIds.contains(movie.id) ||
          _recentRecommendationIds.contains(movie.id)) {
        continue;
      }
      for (final cat in categories) {
        if (movie.categories.contains(cat)) {
          if (!results.contains(movie)) {
            results.add(movie);
          }
          break;
        }
      }
      if (results.length >= 2) break;
    }
    final selected = results.isEmpty
        ? ChatbotDatabase.validCuratedMovies
              .where((movie) => !_excludedMovieIds.contains(movie.id))
              .take(2)
              .toList()
        : results;
    _rememberMovieIds(selected.map((movie) => movie.id));
    return selected;
  }

  List<Movie> _filterMovies(Iterable<Movie> movies) {
    return movies
        .where((movie) => !_excludedMovieIds.contains(movie.id))
        .toList();
  }

  List<Movie> _takeFreshMovies(Iterable<Movie> movies, int count) {
    final available = _filterMovies(movies);
    final fresh = available
        .where((movie) => !_recentRecommendationIds.contains(movie.id))
        .take(count)
        .toList();
    final selected = fresh.isNotEmpty ? fresh : available.take(count).toList();
    _rememberMovieIds(selected.map((movie) => movie.id));
    return selected;
  }

  void _rememberMovieIds(Iterable<int> ids) {
    _recentRecommendationIds.addAll(ids);
    if (_recentRecommendationIds.length <= 30) return;
    final oldest = _recentRecommendationIds
        .take(_recentRecommendationIds.length - 30)
        .toList();
    _recentRecommendationIds.removeAll(oldest);
  }
}
