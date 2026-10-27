import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_core/firebase_core.dart';

import 'llm_client.dart';

/// Firebase AI Logic(Gemini Developer API) 기반 구현.
/// API 키는 앱에 넣지 않고 Firebase 프로젝트 설정 + App Check로 보호한다.
class FirebaseLlmClient implements LlmClient {
  GenerativeModel? _model;
  String? _modelPrompt;

  @override
  bool get isAvailable => LlmConfig.enabled && Firebase.apps.isNotEmpty;

  @override
  Future<String> complete({
    required String systemPrompt,
    required List<LlmTurn> history,
    required String userInput,
  }) async {
    if (!isAvailable) throw StateError('LLM이 설정되지 않았습니다.');
    if (_model == null || _modelPrompt != systemPrompt) {
      _model = FirebaseAI.googleAI().generativeModel(
        model: LlmConfig.model,
        systemInstruction: Content.system(systemPrompt),
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          temperature: 0.6,
          maxOutputTokens: 2048,
          thinkingConfig: ThinkingConfig.withThinkingBudget(0),
        ),
      );
      _modelPrompt = systemPrompt;
    }

    final contents = [
      for (final turn in history)
        turn.isUser
            ? Content.text(turn.text)
            : Content.model([TextPart(turn.text)]),
      Content.text(userInput),
    ];
    final response = await _model!
        .generateContent(contents)
        .timeout(LlmConfig.timeout);
    final text = response.text;
    if (text == null || text.trim().isEmpty) {
      throw StateError('LLM 응답이 비어 있습니다.');
    }
    return text;
  }
}
