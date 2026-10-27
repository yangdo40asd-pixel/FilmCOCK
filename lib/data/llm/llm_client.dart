/// 챗봇이 사용하는 LLM 호출 추상화. 실제 구현(Firebase AI)과 테스트용 가짜 구현을 바꿔 끼운다.
class LlmTurn {
  final bool isUser;
  final String text;

  const LlmTurn({required this.isUser, required this.text});
}

abstract class LlmClient {
  /// 현재 빌드/런타임에서 호출 가능한지. false면 챗봇은 규칙 기반으로만 동작한다.
  bool get isAvailable;

  /// [systemPrompt]와 최근 대화 [history], 새 입력 [userInput]으로 응답 원문(JSON 문자열)을 받는다.
  Future<String> complete({
    required String systemPrompt,
    required List<LlmTurn> history,
    required String userInput,
  });
}

/// LLM 챗봇 사용 여부. 기본값은 켜짐이며 `--dart-define=ENABLE_LLM_CHAT=false`로 끈다(규칙 기반).
class LlmConfig {
  LlmConfig._();

  static const bool enabled = bool.fromEnvironment(
    'ENABLE_LLM_CHAT',
    defaultValue: true,
  );

  static const String model = String.fromEnvironment(
    'LLM_MODEL',
    defaultValue: 'gemini-3.5-flash-lite',
  );
  static const Duration timeout = Duration(seconds: 15);
  static const int maxHistoryTurns = 6;
}
