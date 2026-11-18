import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:filmcock_app/features/chat/application/chat_session_controller.dart';
import 'package:filmcock_app/features/chat/application/chatbot_service.dart';
import 'package:filmcock_app/features/chat/domain/llm_client.dart';
import '../../helpers/fake_catalog_repository.dart';

class PendingLlm implements LlmClient {
  final entered = Completer<void>();
  final response = Completer<String>();
  @override
  bool get isAvailable => true;
  @override
  Future<String> complete({
    required String systemPrompt,
    required List<LlmTurn> history,
    required String userInput,
  }) {
    if (!entered.isCompleted) entered.complete();
    return response.future;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('초기화 전에 시작한 응답은 새 대화에 추가되지 않는다', () async {
    SharedPreferences.setMockInitialValues({});
    final llm = PendingLlm();
    final controller = ChatSessionController(
      createService: () =>
          ChatbotService(catalog: FakeCatalogRepository(), llmClient: llm),
    );
    final sending = controller.send('기존 요청');
    await llm.entered.future;
    controller.reset();
    llm.response.complete('{"intent":"out_of_scope","reply":"이전 응답"}');
    await sending;
    expect(
      controller.messages.any((message) => message.text == '이전 응답'),
      isFalse,
    );
    expect(controller.messages.length, 1);
    expect(controller.isProcessing, isFalse);
    controller.dispose();
  });
}
