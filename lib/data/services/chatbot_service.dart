import 'package:shared_preferences/shared_preferences.dart';
import 'package:filmcock_app/data/models/movie_model.dart';
import 'package:filmcock_app/data/services/api_service.dart';
import 'package:filmcock_app/data/chatbot/chatbot_database.dart';

enum ChatbotDialogueState {
  initial,
  awaitingMoodGenre,
}

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
  ChatbotDialogueState _state = ChatbotDialogueState.initial;

  ChatbotDialogueState get state => _state;

  void reset() {
    _state = ChatbotDialogueState.initial;
  }

  Future<ChatMessage> processInput(String rawInput) async {
    final input = rawInput.trim();

    // 1. 대화 상태가 기분 꼬리질문 대기 중인 경우
    if (_state == ChatbotDialogueState.awaitingMoodGenre) {
      _state = ChatbotDialogueState.initial;
      return _handleMoodGenreFollowUp(input);
    }

    // 2. 초기 상태에서 기분/감정이 별로라는 폭넓은 질의 감지 -> 꼬리질문 트리거
    if (_isMoodVagueQuery(input)) {
      _state = ChatbotDialogueState.awaitingMoodGenre;
      return ChatMessage(
        text: '오늘 힘든 일이 있으셨군요. 지친 마음에 작은 위로와 기분 전환을 도와드리겠습니다. 어떤 느낌의 장르로 기분을 환기하고 싶으신가요?',
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
    if (input.contains('힐링') || input.contains('피곤') || input.contains('따뜻한')) {
      final matches = _getCuratedByCategories(['힐링']);
      return ChatMessage(
        text: '몸과 마음이 지쳤을 때는 자극 없는 따뜻한 이야기가 최고의 처방입니다. 마음에 잔잔한 여운을 줄 힐링 작품들을 추천합니다.',
        isUser: false,
        recommendedMovies: matches.map((m) => m.toMovie()).toList(),
        movieReasons: matches.map((m) => m.reason).toList(),
      );
    }

    // 4. 스트레스 / 사이다
    if (input.contains('스트레스') || input.contains('사이다')) {
      final matches = _getCuratedByCategories(['스트레스', '코미디']);
      return ChatMessage(
        text: '답답했던 속을 시원하게 뚫어줄 유쾌하고 통쾌한 사이다 영화들입니다. 복잡한 생각 없이 마음껏 웃어보세요.',
        isUser: false,
        recommendedMovies: matches.map((m) => m.toMovie()).toList(),
        movieReasons: matches.map((m) => m.reason).toList(),
      );
    }

    // 5. 혼맥 / 심야
    if (input.contains('맥주') || input.contains('혼맥') || input.contains('혼자')) {
      final matches = _getCuratedByCategories(['혼맥', '액션']);
      return ChatMessage(
        text: '시원한 캔맥주 한 캔과 함께 가볍게 감상하기 좋은 작품들입니다. 편안한 혼자만의 밤을 만끽해보세요.',
        isUser: false,
        recommendedMovies: matches.map((m) => m.toMovie()).toList(),
        movieReasons: matches.map((m) => m.reason).toList(),
      );
    }

    // 6. 주말 몰입작
    if (input.contains('주말') || input.contains('시간 순삭') || input.contains('몰입')) {
      final matches = _getCuratedByCategories(['주말', '스릴러']);
      return ChatMessage(
        text: '주말 동안 시간 가는 줄 모르고 빠져들 수 있는 높은 완성도의 명작들입니다. 빈틈없는 몰입감을 선사합니다.',
        isUser: false,
        recommendedMovies: matches.map((m) => m.toMovie()).toList(),
        movieReasons: matches.map((m) => m.reason).toList(),
      );
    }

    // 7. 반전 / 스릴러
    if (input.contains('반전') || input.contains('스릴러') || input.contains('추리')) {
      final matches = _getCuratedByCategories(['반전', '스릴러']);
      return ChatMessage(
        text: '마지막 순간까지 방심할 수 없는 치밀한 두뇌 싸움과 충격적인 결말의 스릴러 명작입니다. 결말의 전율을 직접 느껴보세요.',
        isUser: false,
        recommendedMovies: matches.map((m) => m.toMovie()).toList(),
        movieReasons: matches.map((m) => m.reason).toList(),
      );
    }

    // 8. 데이트 / 설렘 / 로맨스
    if (input.contains('데이트') || input.contains('설레') || input.contains('로맨스') || input.contains('연인')) {
      final matches = _getCuratedByCategories(['로맨스', '데이트']);
      return ChatMessage(
        text: '보는 내내 마음에 기분 좋은 설렘과 따뜻한 온기를 불어넣어 줄 검증된 로맨스 작품들입니다.',
        isUser: false,
        recommendedMovies: matches.map((m) => m.toMovie()).toList(),
        movieReasons: matches.map((m) => m.reason).toList(),
      );
    }

    // 9. 비 오는 날
    if (input.contains('비') || input.contains('비 오는 날')) {
      final matches = _getCuratedByCategories(['비오는날', '스릴러']);
      return ChatMessage(
        text: '창밖 빗소리와 함께 방 안에서 불을 끄고 집중하기 좋은 묵직한 분위기의 미스터리 수작입니다.',
        isUser: false,
        recommendedMovies: matches.map((m) => m.toMovie()).toList(),
        movieReasons: matches.map((m) => m.reason).toList(),
      );
    }

    // 10. SF / 판타지
    if (input.contains('SF') || input.contains('sf') || input.contains('판타지') || input.contains('우주')) {
      final matches = _getCuratedByCategories(['SF']);
      return ChatMessage(
        text: '경이로운 우주 영상미와 독창적인 상상력이 돋보이는 SF 대작들입니다. 가슴 벅찬 감동을 경험해보세요.',
        isUser: false,
        recommendedMovies: matches.map((m) => m.toMovie()).toList(),
        movieReasons: matches.map((m) => m.reason).toList(),
      );
    }

    // 11. 한국 코미디
    if (input.contains('코미디') || input.contains('웃긴')) {
      final matches = _getCuratedByCategories(['코미디']);
      return ChatMessage(
        text: '쉴 새 없이 터지는 대사와 유쾌한 상황극으로 스트레스를 단숨에 날려버릴 한국 코미디 명작입니다.',
        isUser: false,
        recommendedMovies: matches.map((m) => m.toMovie()).toList(),
        movieReasons: matches.map((m) => m.reason).toList(),
      );
    }

    // 12. MBTI 맞춤
    if (input.contains('MBTI') || input.contains('mbti')) {
      final prefs = await SharedPreferences.getInstance();
      final mbti = prefs.getString('user_mbti') ?? 'INFP';
      final matches = _getCuratedByCategories(['명작', '힐링']);
      return ChatMessage(
        text: '사용자님의 $mbti 성향에 맞춰 깊은 공감과 여운을 전해줄 특별한 작품들을 선별했습니다.',
        isUser: false,
        recommendedMovies: matches.map((m) => m.toMovie()).toList(),
        movieReasons: matches.map((m) => m.reason).toList(),
      );
    }

    // 13. 평점 8.5 이상 명작
    if (input.contains('평점') || input.contains('명작') || input.contains('인생')) {
      final matches = _getCuratedByCategories(['명작']);
      return ChatMessage(
        text: '평단과 대중 모두에게 만점에 가까운 평가를 받은 실패 없는 인생 명작들입니다. 믿고 감상해보세요.',
        isUser: false,
        recommendedMovies: matches.map((m) => m.toMovie()).toList(),
        movieReasons: matches.map((m) => m.reason).toList(),
      );
    }

    // 14. 하이브리드 검색: 특정 검색어(영화 제목, 인물 등) TMDB API 연계
    try {
      final apiResults = await ApiService.searchMovies(input);
      if (apiResults.isNotEmpty) {
        final top = apiResults.take(3).toList();
        return ChatMessage(
          text: '요청하신 키워드와 관련된 작품들을 찾아냈습니다. 포스터 카드를 터치하여 상세 정보와 예고편을 확인해보세요.',
          isUser: false,
          recommendedMovies: top,
          movieReasons: top.map((m) => '평점 ${m.voteAverage.toStringAsFixed(1)}점을 기록한 대표작입니다.').toList(),
        );
      }
    } catch (_) {}

    // 15. 일반 기본 추천
    final defaultMatches = ChatbotDatabase.curatedMovies.take(2).toList();
    return ChatMessage(
      text: '오늘 감상하기에 가장 알맞은 대표적인 명작 영화들을 엄선했습니다. 마음에 드는 작품을 골라보세요.',
      isUser: false,
      recommendedMovies: defaultMatches.map((m) => m.toMovie()).toList(),
      movieReasons: defaultMatches.map((m) => m.reason).toList(),
    );
  }

  bool _isMoodVagueQuery(String input) {
    final triggers = [
      '기분이 별로',
      '기분 별로',
      '우울',
      '기분 안 좋아',
      '기분 안좋아',
      '슬퍼',
      '힘들어',
      '지쳐',
      '짜증',
      '위로',
    ];
    for (final t in triggers) {
      if (input.contains(t)) return true;
    }
    return false;
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
    for (final movie in ChatbotDatabase.curatedMovies) {
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
    if (results.isEmpty) {
      return ChatbotDatabase.curatedMovies.take(2).toList();
    }
    return results;
  }
}
