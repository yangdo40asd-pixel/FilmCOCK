enum ChatIntent {
  moodVague,
  healing,
  stressRelief,
  emotional,
  beerNight,
  weekend,
  thriller,
  romance,
  rainyDay,
  family,
  midnight,
  art,
  boxOffice,
  scienceFiction,
  comedy,
  mbti,
  highRated,
  personFilmography,
  movieTitle,
  genre,
  unsupported,
}

class ChatIntentMatch {
  final ChatIntent intent;
  final String normalizedInput;
  final String? searchTerm;

  /// [ChatIntent.genre]일 때 GenreCatalog 키(예: animation, horror).
  final String? genreKey;

  const ChatIntentMatch({
    required this.intent,
    required this.normalizedInput,
    this.searchTerm,
    this.genreKey,
  });
}

class ChatIntentResolver {
  ChatIntentResolver._();

  static const Map<String, ChatIntent> _promptIntents = {
    'mood_down': ChatIntent.moodVague,
    'mood_healing': ChatIntent.healing,
    'mood_stress': ChatIntent.stressRelief,
    'mood_romance': ChatIntent.romance,
    'mood_crying': ChatIntent.emotional,
    'sit_beer': ChatIntent.beerNight,
    'sit_weekend': ChatIntent.weekend,
    'sit_date': ChatIntent.romance,
    'sit_family': ChatIntent.family,
    'sit_midnight': ChatIntent.midnight,
    'theme_twist': ChatIntent.thriller,
    'theme_art': ChatIntent.art,
    'theme_masterpiece': ChatIntent.highRated,
    'theme_rain': ChatIntent.rainyDay,
    'theme_sf': ChatIntent.scienceFiction,
    'theme_comedy': ChatIntent.comedy,
    'mbti_custom': ChatIntent.mbti,
    'hot_boxoffice': ChatIntent.boxOffice,
    'verified_high': ChatIntent.highRated,
  };

  static ChatIntentMatch resolve(String rawInput, {String? promptId}) {
    final input = normalize(rawInput);
    final promptIntent = promptId == null ? null : _promptIntents[promptId];
    if (promptIntent != null) {
      return ChatIntentMatch(intent: promptIntent, normalizedInput: input);
    }

    final personTerm = _extractPersonTerm(input);
    if (personTerm != null) {
      return ChatIntentMatch(
        intent: ChatIntent.personFilmography,
        normalizedInput: input,
        searchTerm: personTerm,
      );
    }

    final keywordRules = <ChatIntent, List<String>>{
      ChatIntent.healing: const ['힐링', '피곤', '따뜻한'],
      ChatIntent.stressRelief: const ['스트레스', '사이다'],
      ChatIntent.emotional: const ['감동', '울고', '눈물'],
      ChatIntent.beerNight: const ['맥주', '혼맥', '혼자'],
      ChatIntent.weekend: const ['주말', '시간 순삭', '몰입'],
      ChatIntent.thriller: const ['반전', '스릴러', '추리'],
      ChatIntent.romance: const ['데이트', '설레', '로맨스', '연인'],
      ChatIntent.rainyDay: const ['비 오는', '비오는', '빗소리', '장마'],
      ChatIntent.family: const ['가족'],
      ChatIntent.midnight: const ['심야', '새벽'],
      ChatIntent.art: const ['예술', '영상미', '음악'],
      ChatIntent.boxOffice: const ['박스오피스', '요즘 영화'],
      ChatIntent.scienceFiction: const ['sf', '판타지', '우주'],
      ChatIntent.comedy: const ['코미디', '웃긴'],
      ChatIntent.mbti: const ['mbti'],
      ChatIntent.highRated: const ['평점', '명작', '인생 영화'],
      // 구체적인 장르·상황 키워드를 먼저 판정한 뒤 막연한 감정을 처리한다.
      ChatIntent.moodVague: const [
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
      ],
    };

    for (final rule in keywordRules.entries) {
      // 상황·기분 규칙을 먼저 보고, 막연한 감정 처리 전에 장르를 판정한다.
      if (rule.key == ChatIntent.moodVague) {
        final genreKey = detectGenreKey(input);
        if (genreKey != null) {
          return ChatIntentMatch(
            intent: ChatIntent.genre,
            normalizedInput: input,
            genreKey: genreKey,
          );
        }
      }
      if (rule.value.any(input.contains)) {
        return ChatIntentMatch(intent: rule.key, normalizedInput: input);
      }
    }

    final movieTitle = _extractMovieTitle(input);
    if (movieTitle != null) {
      return ChatIntentMatch(
        intent: ChatIntent.movieTitle,
        normalizedInput: input,
        searchTerm: movieTitle,
      );
    }

    return ChatIntentMatch(
      intent: ChatIntent.unsupported,
      normalizedInput: input,
    );
  }

  /// GenreCatalog 키 -> 사용자 표현. 기존 상황 규칙에 없는 장르만 다룬다.
  static const Map<String, List<String>> _genreKeywords = {
    'animation': ['애니', '지브리', '픽사', '디즈니', '만화', '드림웍스'],
    'horror': ['공포', '호러', '무서운', '귀신', '좀비', '오컬트'],
    'crime': ['범죄', '느와르', '누아르', '형사'],
    'action': ['액션', '격투', '총격'],
    'drama': ['드라마'],
    'documentary': ['다큐'],
    'war': ['전쟁'],
    'music': ['뮤지컬'],
    'mystery': ['미스터리', '미스테리'],
    'adventure': ['모험', '어드벤처'],
    'history': ['사극', '역사', '실화'],
  };

  /// 입력에서 장르 키워드를 찾아 GenreCatalog 키를 반환한다.
  static String? detectGenreKey(String input) {
    final normalized = normalize(input);
    for (final entry in _genreKeywords.entries) {
      if (entry.value.any(normalized.contains)) return entry.key;
    }
    return null;
  }

  static String normalize(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static bool isMoodFollowUp(String input) {
    const keywords = [
      '코미디',
      '웃',
      '빵',
      '힐링',
      '따뜻',
      '몽글',
      '액션',
      '생각 없이',
      '감동',
      '드라마',
      '눈물',
    ];
    return keywords.any(input.contains);
  }

  static String? _extractPersonTerm(String input) {
    final match = RegExp(
      r'^(.+?)\s*(배우|감독)\s*(영화|작품|출연작|필모그래피)?\s*(찾아줘|검색|추천|알려줘)?$',
    ).firstMatch(input);
    final term = match?.group(1)?.trim();
    return term == null || term.isEmpty ? null : term;
  }

  static String? _extractMovieTitle(String input) {
    final quoted = RegExp(r'''["“'](.+?)["”']''').firstMatch(input)?.group(1);
    if (quoted != null && quoted.trim().isNotEmpty) return quoted.trim();

    final prefix = RegExp(
      r'^(?:영화)\s+(.+?)\s*(?:찾아줘|검색|정보|알려줘)?$',
    ).firstMatch(input)?.group(1);
    if (prefix != null && prefix.trim().isNotEmpty) return prefix.trim();

    final suffix = RegExp(
      r'^(.+?)\s+(?:영화)\s*(?:찾아줘|검색|정보|알려줘)$',
    ).firstMatch(input)?.group(1);
    return suffix == null || suffix.trim().isEmpty ? null : suffix.trim();
  }
}
