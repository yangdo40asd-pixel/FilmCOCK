import 'package:filmcock_app/features/preferences/domain/preference_repository.dart';
import 'package:filmcock_app/features/chat/application/llm_plan_interpreter.dart';
import 'package:filmcock_app/features/chat/application/movie_candidate_verifier.dart';
import 'package:filmcock_app/features/chat/domain/chat_message.dart';
export 'package:filmcock_app/features/chat/domain/chat_message.dart';
import 'package:filmcock_app/features/chat/domain/curated_rule.dart';
import 'dart:convert';

import 'package:filmcock_app/features/chat/domain/chat_plan.dart';
import 'package:filmcock_app/features/chat/domain/llm_client.dart';
import 'package:filmcock_app/shared/domain/models/catalog_models.dart';
import 'package:filmcock_app/shared/domain/repositories/catalog_repository.dart';
import 'package:filmcock_app/features/chat/data/curated_movie_catalog.dart';
import 'package:filmcock_app/features/activity/data/movie_history_service.dart';
import 'package:filmcock_app/features/chat/domain/chat_intent.dart';
import 'package:filmcock_app/features/preferences/domain/genre_catalog.dart';
import 'package:filmcock_app/features/recommendations/application/personalized_recommendation_service.dart';
import 'package:filmcock_app/features/preferences/data/user_settings_repository.dart';

enum ChatbotDialogueState { initial, awaitingMoodGenre }

class ChatbotService {
  final PreferenceRepository _settingsRepository;
  ChatbotDialogueState _state = ChatbotDialogueState.initial;
  Set<int> _excludedMovieIds = const <int>{};
  final Set<int> _recentRecommendationIds = <int>{};
  final LlmPlanInterpreter _planner;
  int _generation = 0;
  final CatalogRepository catalog;
  final MovieCandidateVerifier _candidateVerifier;
  final List<LlmTurn> _history = <LlmTurn>[];

  ChatbotService({
    required this.catalog,
    PreferenceRepository settings = const UserSettingsRepository(),
    LlmClient? llmClient,
    Future<List<Movie>> Function(String query)? movieSearch,
  }) : _settingsRepository = settings,
       _planner = LlmPlanInterpreter(llmClient ?? const DisabledLlmClient()),
       _candidateVerifier = MovieCandidateVerifier(
         search: movieSearch ?? catalog.searchMovies,
       );

  ChatbotDialogueState get state => _state;

  void reset() {
    _generation++;
    _state = ChatbotDialogueState.initial;
    _recentRecommendationIds.clear();
    _history.clear();
  }

  Future<ChatMessage> processInput(String rawInput, {String? promptId}) async {
    final generation = _generation;
    final response = await _processInternal(rawInput, promptId: promptId);
    if (generation == _generation) _recordTurn(rawInput, response);
    return response;
  }

  Future<ChatMessage> _processInternal(
    String rawInput, {
    String? promptId,
  }) async {
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

    // 자유 입력은 LLM 도슨트가 먼저 해석하고, 실패하면 아래 규칙 기반으로 대체한다.
    // 프롬프트 칩(promptId)은 항상 규칙 기반으로 처리한다.
    if (promptId == null && _planner.isAvailable) {
      final llmResponse = await _tryLlm(rawInput.trim());
      if (llmResponse != null) return llmResponse;
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

    final curatedRule = CuratedRule.forIntent(intent);
    if (curatedRule != null) {
      final matches = _getCuratedByCategories(curatedRule.categories);
      return ChatMessage(
        text: curatedRule.message,
        isUser: false,
        recommendedMovies: matches.map((movie) => movie.toMovie()).toList(),
        movieReasons: matches.map((movie) => movie.reason).toList(),
      );
    }

    if (intent == ChatIntent.family) {
      return _recommendFromGenre(
        genreId: 10751,
        fallbackCategories: const ['힐링'],
        message: '가족과 함께 편안하게 즐길 수 있는 따뜻한 작품들입니다.',
      );
    }

    if (intent == ChatIntent.boxOffice) {
      try {
        final movies = _takeFreshMovies(await catalog.getPopularMovies(), 3);
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

    // 12. MBTI 맞춤
    if (intent == ChatIntent.mbti) {
      final preferences = await _settingsRepository.loadPreferences();
      final mbti = preferences.mbti;
      final genres = preferences.genres;
      final fallback = ChatbotDatabase.validCuratedMovies
          .where((movie) => !_excludedMovieIds.contains(movie.id))
          .take(3)
          .map((movie) => movie.toMovie())
          .toList();
      final recommendation = await PersonalizedRecommendationService.load(
        mbti: mbti,
        genres: genres,
        fallback: fallback,
        catalog: catalog,
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

    if (intent == ChatIntent.genre && match.genreKey != null) {
      return recommendGenre(match.genreKey!);
    }

    return ChatMessage(
      text:
          '영화 추천과 영화 제목 검색, 배우·감독의 출연작 안내를 도와드릴 수 있어요. 예: “힐링 영화 추천”, “영화 기생충 찾아줘”, “봉준호 감독 작품”.',
      isUser: false,
      followUpOptions: const ['힐링 영화', '박스오피스', 'MBTI 맞춤', '평점 높은 명작'],
    );
  }

  Set<String> get _curatedCategories => ChatbotDatabase.validCuratedMovies
      .expand((movie) => movie.categories)
      .toSet();

  Future<ChatMessage?> _tryLlm(String input) async {
    try {
      final plan = await _planner.interpret(
        input,
        categories: _curatedCategories,
        history: _history,
        mbti: await _settingsRepository.loadMbti(),
      );
      return plan == null ? null : await _groundPlan(plan);
    } catch (_) {
      return null;
    }
  }

  /// LLM 계획을 실제 데이터(TMDB 검색·큐레이션)로 확인해 카드 응답을 만든다.
  /// 확인되지 않은 영화는 보여주지 않는다.
  Future<ChatMessage?> _groundPlan(ChatPlan plan) async {
    switch (plan.intent) {
      case ChatPlanIntent.outOfScope:
        return ChatMessage(
          text: plan.reply,
          isUser: false,
          followUpOptions: plan.followUps.isNotEmpty
              ? plan.followUps
              : const ['힐링 영화', '박스오피스', 'MBTI 맞춤', '평점 높은 명작'],
        );
      case ChatPlanIntent.searchTitle:
        return _searchMovieTitle(plan.searchTerm!);
      case ChatPlanIntent.person:
        return _searchPersonFilmography(
          plan.searchTerm!,
          directing: plan.directing,
        );
      case ChatPlanIntent.recommend:
        break;
    }

    final verified = await _candidateVerifier.verify(
      plan,
      excluded: _excludedMovieIds,
      recent: _recentRecommendationIds,
    );
    final movies = verified.movies;
    final reasons = verified.reasons;

    final followUps = plan.followUps.isEmpty ? null : plan.followUps;
    if (movies.isNotEmpty) {
      _rememberMovieIds(movies.map((movie) => movie.id));
      return ChatMessage(
        text: plan.reply,
        isUser: false,
        recommendedMovies: movies,
        movieReasons: reasons,
        followUpOptions: followUps,
      );
    }
    if (plan.genres.isNotEmpty) {
      return recommendGenre(plan.genres.first);
    }
    if (plan.categories.isNotEmpty) {
      final curated = _getCuratedByCategories(plan.categories);
      return ChatMessage(
        text: plan.reply,
        isUser: false,
        recommendedMovies: curated.map((movie) => movie.toMovie()).toList(),
        movieReasons: curated.map((movie) => movie.reason).toList(),
        followUpOptions: followUps,
      );
    }
    return null;
  }

  void _recordTurn(String input, ChatMessage response) {
    _history
      ..add(LlmTurn(isUser: true, text: input.trim()))
      ..add(
        LlmTurn(
          isUser: false,
          text: jsonEncode({
            'reply': response.text,
            'candidateTitles': [
              for (final movie in response.recommendedMovies ?? const <Movie>[])
                movie.title,
            ],
          }),
        ),
      );
    final overflow = _history.length - LlmConfig.maxHistoryTurns * 2;
    if (overflow > 0) _history.removeRange(0, overflow);
  }

  Future<ChatMessage> _searchMovieTitle(String title) async {
    try {
      final movies = _takeFreshMovies(await catalog.searchMovies(title), 3);
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
      final people = await catalog.searchPeople(name);
      if (people.isEmpty) {
        return ChatMessage(
          text: '“$name” 이름으로 찾은 영화인이 없습니다. 이름을 확인해 다시 입력해주세요.',
          isUser: false,
        );
      }

      final person = people.first;
      final movies = _takeFreshMovies(
        await catalog.getPersonFilmography(person.id, directing: directing),
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

  static const Map<String, String> _genreMessages = {
    'animation': '세대를 가리지 않고 즐길 수 있는 애니메이션 작품들을 골라봤어요. 작화와 음악의 여운까지 함께 느껴보세요.',
    'horror': '등골이 서늘해지는 공포 영화들입니다. 불을 끄고 보신다면 각오는 단단히 하세요.',
    'crime': '긴장감 넘치는 수사와 범죄의 세계로 안내할 작품들입니다.',
    'action': '화끈한 타격감과 속도감으로 몰입하게 만드는 액션 영화들입니다.',
    'drama': '인물의 감정선을 따라가며 깊은 여운을 남기는 드라마 작품들입니다.',
    'documentary': '실제 이야기의 힘을 느낄 수 있는 다큐멘터리 작품들입니다.',
    'war': '전쟁의 참혹함과 그 속의 인간을 그린 작품들입니다.',
    'music': '음악과 노래가 이야기를 이끄는 작품들입니다.',
    'mystery': '마지막까지 단서를 쫓게 만드는 미스터리 작품들입니다.',
    'adventure': '미지의 세계로 떠나는 모험 영화들입니다.',
    'history': '역사와 실화를 바탕으로 한 묵직한 작품들입니다.',
  };

  static const Map<String, List<String>> _genreFallbackCategories = {
    'animation': ['애니메이션', '힐링'],
    'horror': ['스릴러', '심야'],
    'crime': ['스릴러', '반전'],
    'action': ['액션', '기분_액션'],
    'drama': ['감동', '기분_드라마'],
  };

  /// GenreCatalog 키 기반 장르 추천. TMDB 장르 탐색 실패 시 큐레이션으로 대체한다.
  Future<ChatMessage> recommendGenre(String genreKey) async {
    await ChatbotDatabase.ensureLoaded();
    final genreId = GenreCatalog.tmdbIdFor(genreKey);
    final label = GenreCatalog.labelFor(genreKey) ?? genreKey;
    if (genreId == null) {
      return _localFallbackWithRetry('해당 장르를 아직 지원하지 않습니다.', '평점 높은 명작');
    }
    return _recommendFromGenre(
      genreId: genreId,
      fallbackCategories: _genreFallbackCategories[genreKey] ?? const ['명작'],
      message: _genreMessages[genreKey] ?? '$label 장르의 인기작들입니다.',
      genreLabel: label,
    );
  }

  Future<ChatMessage> _recommendFromGenre({
    required int genreId,
    required List<String> fallbackCategories,
    required String message,
    String? genreLabel,
  }) async {
    try {
      final movies = _takeFreshMovies(
        await catalog.getMoviesByGenre(genreId),
        3,
      );
      if (movies.isNotEmpty) {
        return ChatMessage(
          text: message,
          isUser: false,
          recommendedMovies: movies,
          movieReasons: movies
              .map(
                (movie) => genreLabel == null
                    ? '선호 장르와 현재 인기도를 반영했습니다.'
                    : '$genreLabel 인기작 · 평점 ${movie.voteAverage.toStringAsFixed(1)}',
              )
              .toList(),
        );
      }
    } catch (_) {}
    final fallback = _getCuratedByCategories(fallbackCategories);
    return ChatMessage(
      text: genreLabel == null
          ? message
          : '지금은 $genreLabel 목록을 불러오지 못해 앱에 준비된 추천작을 대신 보여드릴게요.',
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
