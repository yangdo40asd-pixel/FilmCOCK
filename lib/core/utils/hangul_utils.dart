class HangulUtils {
  static const List<String> _chosungList = [
    'ㄱ', 'ㄲ', 'ㄴ', 'ㄷ', 'ㄸ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅃ', 'ㅅ',
    'ㅆ', 'ㅇ', 'ㅈ', 'ㅉ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ'
  ];

  /// 한글 문자열에서 초성만 추출
  /// 예: '레지던트 이블' -> 'ㄹㅈㄷㅌ ㅇㅂ'
  /// 예: '장동윤' -> 'ㅈㄷㅇ'
  static String extractChosung(String text) {
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      final code = text.codeUnitAt(i);
      if (code >= 0xAC00 && code <= 0xD7A3) {
        final chosungIndex = (code - 0xAC00) ~/ (21 * 28);
        buffer.write(_chosungList[chosungIndex]);
      } else {
        buffer.write(text[i]);
      }
    }
    return buffer.toString();
  }

  /// 검색어 문자열이 순수 초성(자음)으로만 이루어졌는지 확인
  static bool isChosungOnly(String text) {
    final trimmed = text.replaceAll(' ', '');
    if (trimmed.isEmpty) return false;
    for (int i = 0; i < trimmed.length; i++) {
      final char = trimmed[i];
      if (!_chosungList.contains(char)) {
        return false;
      }
    }
    return true;
  }

  /// 대상 문자열(target)이 검색어(query)의 초성과 일치하거나 포함되는지 검사
  static bool matches(String target, String query) {
    final cleanQuery = query.replaceAll(' ', '').toLowerCase();
    if (cleanQuery.isEmpty) return false;

    final cleanTarget = target.replaceAll(' ', '').toLowerCase();

    // 1. 일반 부분 문자열 일치
    if (cleanTarget.contains(cleanQuery)) {
      return true;
    }

    // 2. 검색어가 초성인 경우: 대상의 초성 문자열과 비교
    if (isChosungOnly(cleanQuery)) {
      final targetChosung = extractChosung(cleanTarget);
      return targetChosung.contains(cleanQuery);
    }

    return false;
  }
}
