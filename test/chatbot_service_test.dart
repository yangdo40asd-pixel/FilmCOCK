import 'package:filmcock_app/data/services/chatbot_service.dart';
import 'package:filmcock_app/data/chatbot/chatbot_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({'user_mbti': 'INFP'});
  });

  group('Chatbot prompt routing', () {
    test('all configured prompt chips produce a usable response', () async {
      for (final prompt in ChatbotDatabase.promptChips) {
        final service = ChatbotService();
        final response = await service.processInput(
          prompt.queryText,
          promptId: prompt.id,
        );
        expect(response.text, isNotEmpty, reason: prompt.id);
        expect(
          response.followUpOptions?.isNotEmpty == true ||
              response.recommendedMovies?.isNotEmpty == true,
          isTrue,
          reason: prompt.id,
        );
      }
    });

    test(
      'crying prompt recommends emotional drama, not drinking action',
      () async {
        final service = ChatbotService();

        final response = await service.processInput(
          '혼자 펑펑 울면서 감정을 쏟아내고 싶어',
          promptId: 'mood_crying',
        );

        expect(response.recommendedMovies, isNotEmpty);
        expect(response.recommendedMovies!.first.title, '쇼생크 탈출');
      },
    );

    test('midnight prompt uses the midnight collection', () async {
      final service = ChatbotService();

      final response = await service.processInput(
        '새벽 감성에 젖어드는 영화',
        promptId: 'sit_midnight',
      );

      expect(response.recommendedMovies, isNotEmpty);
      expect(response.text, contains('밤'));
    });

    test('high rating prompt only returns movies rated at least 8.5', () async {
      final service = ChatbotService();

      final response = await service.processInput(
        '평점 높은 영화',
        promptId: 'verified_high',
      );

      expect(response.recommendedMovies, isNotEmpty);
      expect(
        response.recommendedMovies!.every((movie) => movie.voteAverage >= 8.5),
        isTrue,
      );
    });

    test('family, art, and box-office prompts keep their intent', () async {
      final service = ChatbotService();

      final family = await service.processInput(
        '가족 영화',
        promptId: 'sit_family',
      );
      final art = await service.processInput('예술 영화', promptId: 'theme_art');
      final boxOffice = await service.processInput(
        '박스오피스',
        promptId: 'hot_boxoffice',
      );

      expect(family.text, contains('가족'));
      expect(art.text, contains('예술'));
      expect(boxOffice.text, contains('박스오피스'));
      expect(boxOffice.recommendedMovies, isNotEmpty);
    });
  });

  group('Chatbot keyword boundaries', () {
    test('zombie is not treated as a rainy-day query', () {
      expect(ChatbotService.isRainyDayQuery('좀비 영화 추천해줘'), isFalse);
    });

    test('explicit rainy-day phrase is recognized', () {
      expect(ChatbotService.isRainyDayQuery('비 오는 날 영화'), isTrue);
    });
  });
}
