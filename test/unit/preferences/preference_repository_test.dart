import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:filmcock_app/features/preferences/data/user_settings_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('계정별 취향을 같은 저장소에서 읽어도 서로 승계하지 않는다', () async {
    final prefs = await SharedPreferences.getInstance();
    final first = UserSettingsRepository(
      preferences: () async => prefs,
      authenticatedUserId: () => 'first',
    );
    final second = UserSettingsRepository(
      preferences: () async => prefs,
      authenticatedUserId: () => 'second',
    );
    await first.saveOnboardingPreferences(
      mbti: 'ISTJ',
      genres: ['crime'],
      mbtiSkipped: false,
      genresSkipped: false,
    );
    final saved = await first.loadPreferences();
    final other = await second.loadPreferences();
    expect(saved.mbti, 'ISTJ');
    expect(saved.genres, ['crime']);
    expect(other.mbti, isNull);
    expect(other.genres, isEmpty);
    expect((await second.loadOnboarding()).isComplete, isFalse);
  });
}
