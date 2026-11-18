import 'package:flutter/foundation.dart';
import 'package:filmcock_app/features/chat/application/chatbot_service.dart';

/// 대화 화면의 메시지·요청 수명을 관리한다. 스크롤과 입력 UI는 화면이 소유한다.
class ChatSessionController extends ChangeNotifier {
  final ChatbotService Function() createService;
  late ChatbotService _service;
  final List<ChatMessage> _messages = [];
  int _requestId = 0;
  bool _disposed = false;
  bool isProcessing = false;

  ChatSessionController({required this.createService}) {
    _service = createService();
    _messages.add(
      ChatMessage(
        text:
            '안녕하세요. 필름콕 영화 추천 도슨트입니다. 기분, 상황, 장르와 MBTI에 맞는 영화를 안내해 드립니다. 자유롭게 물어보셔도 좋아요.',
        isUser: false,
      ),
    );
  }

  List<ChatMessage> get messages => List.unmodifiable(_messages);

  Future<void> send(String input, {String? promptId}) async {
    final text = input.trim();
    if (_disposed || text.isEmpty || isProcessing) return;
    final request = ++_requestId;
    final service = _service;
    _messages.add(ChatMessage(text: text, isUser: true));
    isProcessing = true;
    notifyListeners();
    try {
      final response = await service.processInput(text, promptId: promptId);
      if (_disposed || request != _requestId) return;
      _messages.add(response);
    } catch (_) {
      if (_disposed || request != _requestId) return;
      _messages.add(
        ChatMessage(text: '추천을 불러오지 못했습니다. 잠시 후 다시 시도해주세요.', isUser: false),
      );
    } finally {
      if (!_disposed && request == _requestId) {
        isProcessing = false;
        notifyListeners();
      }
    }
  }

  void reset() {
    if (_disposed) return;
    _requestId++;
    _service.reset();
    // 이전 요청의 내부 추천 이력도 새 대화와 분리한다.
    _service = createService();
    isProcessing = false;
    _messages
      ..clear()
      ..add(
        ChatMessage(
          text: '대화가 초기화되었습니다. 어떤 영화를 찾고 계신가요? 상단 추천 질문을 누르거나 직접 물어보세요.',
          isUser: false,
        ),
      );
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _requestId++;
    _service.reset();
    super.dispose();
  }
}
