import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:filmcock_app/core/storage/app_storage_keys.dart';
import 'package:filmcock_app/core/storage/safe_json_storage.dart';
import 'package:filmcock_app/features/activity/data/activity_repository.dart';
import 'package:filmcock_app/shared/domain/models/movie.dart';
import '../../helpers/fixed_clock.dart';

class RejectOncePreferences implements SharedPreferences {
  final SharedPreferences delegate;
  final String rejectedKey;
  bool rejected = false;
  RejectOncePreferences(this.delegate, this.rejectedKey);
  @override
  Object? get(String key) => delegate.get(key);
  @override
  String? getString(String key) => delegate.getString(key);
  @override
  List<String>? getStringList(String key) => delegate.getStringList(key);
  @override
  bool? getBool(String key) => delegate.getBool(key);
  @override
  Future<bool> setBool(String key, bool value) async {
    if (!rejected && key == rejectedKey) {
      rejected = true;
      return false;
    }
    return delegate.setBool(key, value);
  }

  @override
  Future<bool> setString(String key, String value) =>
      delegate.setString(key, value);
  @override
  Future<bool> setStringList(String key, List<String> value) =>
      delegate.setStringList(key, value);
  @override
  Future<bool> remove(String key) => delegate.remove(key);
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName}');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('관람 플래그 저장 실패 시 목록과 캘린더도 기존 값으로 복원한다', () async {
    final real = await SharedPreferences.getInstance();
    final failing = RejectOncePreferences(
      real,
      AppStorageKeys.watchedMovie(42),
    );
    final storage = SafeJsonStorage(preferences: () async => failing);
    final repository = ActivityRepository(
      storage: storage,
      clock: FixedClock(DateTime(2026, 11, 17)),
    );
    final movie = Movie(
      id: 42,
      title: '기록',
      overview: '',
      voteAverage: 8,
      releaseDate: '',
    );
    await expectLater(
      repository.updateMovieAction(movie, true, liked: false),
      throwsStateError,
    );
    expect(await repository.watchedMovies(), isEmpty);
    expect(await repository.isMovieWatched(42), isFalse);
    expect(await storage.readMap(AppStorageKeys.calendarMovies), isEmpty);
  });

  test('댓글을 동시에 추가해도 앞선 기록을 덮어쓰지 않는다', () async {
    const repository = ActivityRepository();
    await Future.wait([
      repository.addComment({
        'movieId': 1,
        'content': '첫째',
        'date': '2026.11.17',
      }),
      repository.addComment({
        'movieId': 2,
        'content': '둘째',
        'date': '2026.11.17',
      }),
    ]);
    expect(
      (await repository.comments()).map((item) => item['movieId']).toSet(),
      {1, 2},
    );
  });
}
