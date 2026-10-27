import 'package:filmcock_app/data/chatbot/chatbot_database.dart';
import 'package:filmcock_app/data/llm/chat_plan.dart';
import 'package:filmcock_app/data/llm/llm_client.dart';
import 'package:filmcock_app/data/models/movie_model.dart';
import 'package:filmcock_app/data/services/chatbot_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeLlmClient implements LlmClient {
  FakeLlmClient({this.response, this.error});

  final String? response;
  final Object? error;
  int calls = 0;
  List<LlmTurn> lastHistory = const [];

  @override
  bool get isAvailable => true;

  @override
  Future<String> complete({
    required String systemPrompt,
    required List<LlmTurn> history,
    required String userInput,
  }) async {
    calls++;
    lastHistory = history;
    if (error != null) throw error!;
    return response!;
  }
}

Future<List<Movie>> _fakeSearch(String query) async => [
  Movie(
    id: 999001,
    title: query == '없는영화' ? '전혀 다른 영화' : query,
    overview: '',
    voteAverage: 8.1,
    releaseDate: '2020-01-01',
  ),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({'user_mbti': 'INFP'});
  });

  test('out_of_scope 요청은 정중한 거절과 영화 제안을 돌려준다', () async {
    final llm = FakeLlmClient(
      response:
          '```json\n{"intent":"out_of_scope","reply":"영화 이야기만 도와드릴 수 있어요.","followUps":["힐링 영화"]}\n```',
    );
    final service = ChatbotService(llmClient: llm, movieSearch: _fakeSearch);
    final response = await service.processInput('파이썬 코드 짜줘');
    expect(response.text, '영화 이야기만 도와드릴 수 있어요.');
    expect(response.followUpOptions, ['힐링 영화']);
    expect(response.recommendedMovies, isNull);
  });

  test('TMDB에서 확인된 후보만 카드로 보여준다', () async {
    final llm = FakeLlmClient(
      response:
          '{"intent":"recommend","reply":"차분한 밤에 어울리는 작품입니다.","candidateTitles":["어바웃 타임","없는영화"],"reasons":["따뜻한 시간 여행","무시됨"]}',
    );
    final service = ChatbotService(llmClient: llm, movieSearch: _fakeSearch);
    final response = await service.processInput('잔잔한 영화 보고 싶어');
    expect(response.recommendedMovies!.map((m) => m.title), ['어바웃 타임']);
    expect(response.movieReasons, ['따뜻한 시간 여행']);
  });

  test('깨진 응답이나 예외는 규칙 기반으로 대체된다', () async {
    for (final llm in [
      FakeLlmClient(response: '이건 JSON이 아님'),
      FakeLlmClient(error: Exception('network')),
    ]) {
      final service = ChatbotService(llmClient: llm, movieSearch: _fakeSearch);
      final response = await service.processInput('MBTI 맞춤 추천해줘');
      expect(llm.calls, 1);
      expect(response.text, isNotEmpty);
    }
  });

  test('프롬프트 칩은 LLM을 호출하지 않는다', () async {
    final llm = FakeLlmClient(error: StateError('호출되면 안 됨'));
    final service = ChatbotService(llmClient: llm, movieSearch: _fakeSearch);
    final chip = ChatbotDatabase.promptChips.first;
    await service.processInput(chip.queryText, promptId: chip.id);
    expect(llm.calls, 0);
  });

  test('대화 기록은 최근 6턴만 전달된다', () async {
    final llm = FakeLlmClient(
      response: '{"intent":"out_of_scope","reply":"영화 이야기를 해요."}',
    );
    final service = ChatbotService(llmClient: llm, movieSearch: _fakeSearch);
    for (var i = 0; i < 9; i++) {
      await service.processInput('질문 $i');
    }
    expect(llm.lastHistory.length, LlmConfig.maxHistoryTurns * 2);
    expect(llm.lastHistory.first.text, '질문 2');
  });

  group('ChatPlan 화이트리스트', () {
    test('허용되지 않은 장르·카테고리·intent를 걸러낸다', () {
      final plan = ChatPlan.tryParse(
        '{"intent":"recommend","reply":"안내","genres":["comedy","없는장르"],"categories":["힐링","해킹"],"candidateTitles":["a","b","c","d"],"followUps":["1","2","3","4","5"]}',
        allowedCategories: {'힐링'},
      )!;
      expect(plan.genres, ['comedy']);
      expect(plan.categories, ['힐링']);
      expect(plan.candidateTitles.length, 3);
      expect(plan.followUps.length, 4);
      expect(
        ChatPlan.tryParse(
          '{"intent":"hack","reply":"x"}',
          allowedCategories: const {},
        ),
        isNull,
      );
      expect(
        ChatPlan.tryParse(
          '{"intent":"person","reply":"x"}',
          allowedCategories: const {},
        ),
        isNull,
      );
    });
  });
}
