import 'dart:convert';

import 'package:filmcock_app/data/models/movie_model.dart';
import 'package:flutter/services.dart';

class ChatbotPrompt {
  final String id;
  final String label;
  final String category;
  final String queryText;

  const ChatbotPrompt({
    required this.id,
    required this.label,
    required this.category,
    required this.queryText,
  });
}

class ChatbotMovieData {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final double voteAverage;
  final String releaseDate;
  final String reason;
  final List<String> tags;
  final List<String> categories;

  const ChatbotMovieData({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.voteAverage,
    required this.releaseDate,
    required this.reason,
    required this.tags,
    required this.categories,
  });

  factory ChatbotMovieData.fromJson(Map<String, dynamic> json) {
    return ChatbotMovieData(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      overview: json['overview'] as String? ?? '',
      posterPath: json['posterPath'] as String? ?? '',
      voteAverage: (json['voteAverage'] as num?)?.toDouble() ?? 0,
      releaseDate: json['releaseDate'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(),
      categories: (json['categories'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(),
    );
  }

  Movie toMovie() {
    return Movie(
      id: id,
      title: title,
      overview: overview,
      posterPath: posterPath,
      voteAverage: voteAverage,
      releaseDate: releaseDate,
    );
  }
}

class ChatbotDatabase {
  // 18종 이상의 세분화된 텍스트 추천 질문 칩 (이모티콘 일체 배제)
  static const List<ChatbotPrompt> promptChips = [
    // 카테고리: 기분 (꼬리질문 연계)
    ChatbotPrompt(
      id: 'mood_down',
      label: '기분이 별로일 때 맞춤 추천',
      category: '기분',
      queryText: '나 오늘 기분이 별로야 맞춤영화를 추천해줘',
    ),
    ChatbotPrompt(
      id: 'mood_healing',
      label: '지치고 피곤할 때 따뜻한 힐링',
      category: '기분',
      queryText: '지치고 피곤해서 따뜻한 힐링이 필요해',
    ),
    ChatbotPrompt(
      id: 'mood_stress',
      label: '스트레스 싹 날릴 사이다 영화',
      category: '기분',
      queryText: '스트레스 싹 날릴 시원한 사이다 영화 추천해줘',
    ),
    ChatbotPrompt(
      id: 'mood_romance',
      label: '마음이 몽글몽글 설레는 영화',
      category: '기분',
      queryText: '마음이 몽글몽글 설레고 연애 세포 깨우는 영화',
    ),
    ChatbotPrompt(
      id: 'mood_crying',
      label: '혼자 펑펑 울고 싶을 때',
      category: '기분',
      queryText: '혼자 펑펑 울면서 감정 쏟아내고 싶어',
    ),

    // 카테고리: 상황
    ChatbotPrompt(
      id: 'sit_beer',
      label: '혼자 캔맥주 마시며 볼 영화',
      category: '상황',
      queryText: '오늘 밤 혼자 캔맥주 마시며 볼 영화 추천해줘',
    ),
    ChatbotPrompt(
      id: 'sit_weekend',
      label: '주말 시간 순삭 몰입작',
      category: '상황',
      queryText: '주말에 시간 순삭되는 몰입도 높은 영화 알려줘',
    ),
    ChatbotPrompt(
      id: 'sit_date',
      label: '연인과 함께 볼 데이트 영화',
      category: '상황',
      queryText: '연인과 함께 볼 달달하고 센스 있는 데이트 영화',
    ),
    ChatbotPrompt(
      id: 'sit_family',
      label: '가족과 다 함께 볼 훈훈한 영화',
      category: '상황',
      queryText: '가족과 다 함께 둘러앉아 볼 훈훈한 영화 추천해줘',
    ),
    ChatbotPrompt(
      id: 'sit_midnight',
      label: '새벽 감성에 젖어드는 심야 영화',
      category: '상황',
      queryText: '새벽 감성에 푹 젖어들기 좋은 심야 영화',
    ),

    // 카테고리: 테마
    ChatbotPrompt(
      id: 'theme_twist',
      label: '결말에 뒤통수 얼얼한 반전 스릴러',
      category: '테마',
      queryText: '결말에 뒤통수 얼얼한 충격 반전 스릴러 알려줘',
    ),
    ChatbotPrompt(
      id: 'theme_art',
      label: '영상미와 음악이 환상적인 명작',
      category: '테마',
      queryText: '영상미와 음악이 환상적인 예술 영화 추천해줘',
    ),
    ChatbotPrompt(
      id: 'theme_masterpiece',
      label: '생각할 거리를 던져주는 인생 영화',
      category: '테마',
      queryText: '생각할 거리를 던져주는 인생 명작 영화 알려줘',
    ),
    ChatbotPrompt(
      id: 'theme_rain',
      label: '비 오는 날 불 끄고 볼 미스터리',
      category: '테마',
      queryText: '비 오는 날 방에서 불 끄고 볼 미스터리 영화',
    ),
    ChatbotPrompt(
      id: 'theme_sf',
      label: '스케일 웅장한 SF 판타지',
      category: '테마',
      queryText: '가슴 웅장해지는 스케일의 SF 판타지 영화 추천해줘',
    ),
    ChatbotPrompt(
      id: 'theme_comedy',
      label: '배꼽 빠지게 웃긴 한국 코미디',
      category: '테마',
      queryText: '배꼽 빠지게 웃긴 한국 코미디 영화 알려줘',
    ),

    // 카테고리: MBTI 및 특화
    ChatbotPrompt(
      id: 'mbti_custom',
      label: '내 MBTI 맞춤 영화 추천',
      category: 'MBTI',
      queryText: '내 MBTI 성향에 딱 맞는 추천 영화는 무엇인가요?',
    ),
    ChatbotPrompt(
      id: 'hot_boxoffice',
      label: '요즘 평가 가장 좋은 핫한 영화',
      category: 'MBTI',
      queryText: '요즘 박스오피스에서 가장 평가 좋은 영화 추천해줘',
    ),
    ChatbotPrompt(
      id: 'verified_high',
      label: '평점 8.5점 이상 실패 없는 명작',
      category: 'MBTI',
      queryText: '평점 8.5점 이상 검증된 실패 없는 명작 추천해줘',
    ),
  ];

  static const String _movieAsset = 'assets/data/chatbot_movies.json';
  static List<ChatbotMovieData> _validCuratedMovies = const [];
  static Future<void>? _loadFuture;

  static List<ChatbotMovieData> get validCuratedMovies => _validCuratedMovies;

  static Future<void> ensureLoaded() async {
    final activeLoad = _loadFuture ??= _loadMovies();
    try {
      await activeLoad;
    } catch (_) {
      if (identical(_loadFuture, activeLoad)) _loadFuture = null;
      rethrow;
    }
  }

  static Future<void> _loadMovies() async {
    final source = await rootBundle.loadString(_movieAsset);
    final decoded = jsonDecode(source) as List<dynamic>;
    final movies = decoded
        .whereType<Map<String, dynamic>>()
        .map(ChatbotMovieData.fromJson)
        .where(_isStructurallyValidMovie)
        .toList();
    _validCuratedMovies = List.unmodifiable(movies);
  }

  static bool _isStructurallyValidMovie(ChatbotMovieData movie) {
    final validPoster =
        movie.posterPath.startsWith('/') ||
        movie.posterPath.startsWith('https://');
    return movie.id > 0 &&
        movie.title.trim().isNotEmpty &&
        validPoster &&
        movie.voteAverage >= 0 &&
        movie.voteAverage <= 10 &&
        DateTime.tryParse(movie.releaseDate) != null &&
        movie.reason.trim().isNotEmpty &&
        movie.categories.isNotEmpty;
  }
}
