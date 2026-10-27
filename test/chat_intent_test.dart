import 'package:filmcock_app/data/models/chat_intent.dart';
import 'package:filmcock_app/data/services/chatbot_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('장르 의도 판정', () {
    final cases = <String, String>{
      '애니영화추천해줘': 'animation',
      '애니메이션 볼만한 거': 'animation',
      '지브리 같은 영화': 'animation',
      '픽사 작품 추천': 'animation',
      '무서운 영화 보고 싶어': 'horror',
      '호러 추천': 'horror',
      '범죄 느와르 영화': 'crime',
      '액션 영화 추천해줘': 'action',
      '드라마 장르 추천': 'drama',
    };
    cases.forEach((input, genre) {
      test(input, () {
        final match = ChatIntentResolver.resolve(input);
        expect(match.intent, ChatIntent.genre);
        expect(match.genreKey, genre);
      });
    });

    test('기존 상황 규칙이 장르보다 우선한다', () {
      expect(ChatIntentResolver.resolve('가족이랑 볼 애니').intent, ChatIntent.family);
      expect(ChatIntentResolver.resolve('반전 있는 스릴러').intent, ChatIntent.thriller);
    });

    test('프롬프트 칩 id는 장르 키워드보다 우선한다', () {
      final match = ChatIntentResolver.resolve(
        '생각 없이 보는 액션',
        promptId: 'sit_beer',
      );
      expect(match.intent, ChatIntent.beerNight);
    });

    test('관련 없는 입력은 여전히 unsupported', () {
      expect(ChatIntentResolver.resolve('오늘 날씨 어때').intent, ChatIntent.unsupported);
    });
  });

  group('장르 추천 응답', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('애니 요청은 카드와 이유 문구를 함께 돌려준다', () async {
      final response = await ChatbotService().processInput('애니영화추천해줘');
      expect(response.recommendedMovies, isNotEmpty);
      expect(
        response.movieReasons?.length,
        response.recommendedMovies!.length,
      );
    });
  });
}
