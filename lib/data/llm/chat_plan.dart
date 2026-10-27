import 'dart:convert';

import 'package:filmcock_app/data/models/genre_catalog.dart';

enum ChatPlanIntent { recommend, searchTitle, person, outOfScope }

/// LLM이 돌려준 JSON을 앱이 검증 가능한 형태로 정리한 결과.
/// 모든 값은 화이트리스트/길이 제한을 거치며, 영화 자체는 앱이 TMDB로 다시 확인한다.
class ChatPlan {
  final ChatPlanIntent intent;
  final String reply;
  final List<String> genres;
  final List<String> categories;
  final List<String> candidateTitles;
  final List<String> reasons;
  final List<String> followUps;
  final String? searchTerm;
  final bool directing;

  const ChatPlan({
    required this.intent,
    required this.reply,
    this.genres = const [],
    this.categories = const [],
    this.candidateTitles = const [],
    this.reasons = const [],
    this.followUps = const [],
    this.searchTerm,
    this.directing = false,
  });

  static const Map<String, ChatPlanIntent> _intents = {
    'recommend': ChatPlanIntent.recommend,
    'search_title': ChatPlanIntent.searchTitle,
    'person': ChatPlanIntent.person,
    'out_of_scope': ChatPlanIntent.outOfScope,
  };

  /// 파싱 실패/형식 위반이면 null을 반환해 호출부가 규칙 기반으로 대체하게 한다.
  static ChatPlan? tryParse(String raw, {required Set<String> allowedCategories}) {
    try {
      var text = raw.trim();
      final fence = RegExp(r'^```(?:json)?\s*([\s\S]*?)\s*```$').firstMatch(text);
      if (fence != null) text = fence.group(1)!.trim();
      final decoded = jsonDecode(text);
      if (decoded is! Map<String, dynamic>) return null;

      final intent = _intents['${decoded['intent']}'];
      final reply = _clean(decoded['reply'], 220);
      if (intent == null || reply == null) return null;

      final searchTerm = _clean(decoded['searchTerm'], 40);
      if ((intent == ChatPlanIntent.searchTitle ||
              intent == ChatPlanIntent.person) &&
          searchTerm == null) {
        return null;
      }

      return ChatPlan(
        intent: intent,
        reply: reply,
        genres: _list(decoded['genres'], 3, 20)
            .where(GenreCatalog.tmdbIds.containsKey)
            .toList(),
        categories: _list(decoded['categories'], 3, 20)
            .where(allowedCategories.contains)
            .toList(),
        candidateTitles: _list(decoded['candidateTitles'], 3, 60),
        reasons: _list(decoded['reasons'], 3, 40),
        followUps: _list(decoded['followUps'], 4, 20),
        searchTerm: searchTerm,
        directing: decoded['personRole'] == 'director',
      );
    } catch (_) {
      return null;
    }
  }

  static String? _clean(Object? value, int maxLength) {
    if (value is! String) return null;
    final text = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (text.isEmpty) return null;
    return text.length <= maxLength ? text : '${text.substring(0, maxLength)}…';
  }

  static List<String> _list(Object? value, int maxItems, int maxLength) {
    if (value is! List) return const [];
    return value
        .map((item) => _clean(item, maxLength))
        .whereType<String>()
        .toSet()
        .take(maxItems)
        .toList();
  }
}
