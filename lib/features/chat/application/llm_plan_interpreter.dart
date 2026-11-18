import 'package:flutter/foundation.dart';
import 'package:filmcock_app/features/chat/application/docent_prompt.dart';
import 'package:filmcock_app/features/chat/domain/chat_plan.dart';
import 'package:filmcock_app/features/chat/domain/llm_client.dart';

/// LLM 호출·시간 제한·응답 형식 검증. 실패는 규칙 대체를 뜻하는 null로 반환한다.
class LlmPlanInterpreter {
  final LlmClient client;
  const LlmPlanInterpreter(this.client);

  bool get isAvailable => client.isAvailable;

  Future<ChatPlan?> interpret(
    String input, {
    required Set<String> categories,
    required List<LlmTurn> history,
    required String? mbti,
  }) async {
    if (input.isEmpty || !isAvailable) return null;
    try {
      final raw = await client
          .complete(
            systemPrompt: DocentPrompt.build(
              categories: categories,
              mbti: mbti,
            ),
            history: List.unmodifiable(history),
            userInput: input,
          )
          .timeout(LlmConfig.timeout);
      final plan = ChatPlan.tryParse(raw, allowedCategories: categories);
      if (plan == null) debugPrint('[LLM] 응답 형식 오류: 규칙 기반으로 대체');
      return plan;
    } catch (_) {
      debugPrint('[LLM] 요청 실패: 규칙 기반으로 대체');
      return null;
    }
  }
}
