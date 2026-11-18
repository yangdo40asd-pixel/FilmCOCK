import 'package:filmcock_app/core/storage/preferences_transaction.dart';
import 'package:filmcock_app/core/time/app_clock.dart';
import 'package:filmcock_app/shared/domain/models/movie.dart';
import 'package:filmcock_app/core/storage/app_storage_keys.dart';
import 'package:filmcock_app/core/storage/safe_json_storage.dart';
import 'package:filmcock_app/features/activity/application/activity_change_service.dart';

class ActivityRepository {
  final SafeJsonStorage _storage;
  final AppClock clock;
  static Future<void> _pending = Future<void>.value();

  const ActivityRepository({
    SafeJsonStorage storage = const SafeJsonStorage(),
    this.clock = const SystemClock(),
  }) : _storage = storage;

  Future<T> _serialize<T>(Future<T> Function() operation) {
    final result = _pending.then((_) => operation());
    _pending = result.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return result;
  }

  /// 목록·플래그·관람 캘린더를 한 작업으로 조정하고 성공 후 알린다.
  Future<void> updateMovieAction(
    Movie movie,
    bool value, {
    required bool liked,
  }) => _serialize(() async {
    final prefs = await _storage.getPreferences();
    final listKey = liked
        ? AppStorageKeys.likedMovies
        : AppStorageKeys.watchedMovies;
    final flagKey = liked
        ? AppStorageKeys.likedMovie(movie.id)
        : AppStorageKeys.watchedMovie(movie.id);
    await withPreferenceRollback(
      prefs,
      [listKey, flagKey, if (!liked) AppStorageKeys.calendarMovies],
      () async {
        final movies = await _storage.readMapList(listKey);
        movies.removeWhere(
          (item) => item['id'].toString() == movie.id.toString(),
        );
        if (value)
          movies.insert(0, {
            'id': movie.id,
            'title': movie.title,
            'posterPath': movie.posterPath,
            'voteAverage': movie.voteAverage,
          });
        await _storage.writeMapList(listKey, movies, preferences: prefs);
        await requirePreferenceWrite(prefs.setBool(flagKey, value));
        if (!liked) {
          final calendar = await _storage.readMap(
            AppStorageKeys.calendarMovies,
          );
          final now = clock.now();
          final day =
              '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
          final entries = List<dynamic>.from(
            calendar[day] as List? ?? const [],
          );
          entries.removeWhere(
            (item) =>
                item is Map && item['id'].toString() == movie.id.toString(),
          );
          if (value)
            entries.add({
              'id': movie.id,
              'title': movie.title,
              'posterPath': movie.posterPath,
              'addedAt': now.toIso8601String(),
            });
          calendar[day] = entries;
          await _storage.writeMap(AppStorageKeys.calendarMovies, calendar);
        }
      },
    );
    ActivityChangeService.notifyChanged();
  });

  Future<void> updatePersonLike({
    required int id,
    required String name,
    required String profileUrl,
    required String department,
    required bool value,
  }) => _serialize(() async {
    final prefs = await _storage.getPreferences();
    final flag = AppStorageKeys.likedPerson(id);
    await withPreferenceRollback(
      prefs,
      [AppStorageKeys.likedPeople, flag],
      () async {
        final people = await likedPeople();
        people.removeWhere(
          (person) => person['id'].toString() == id.toString(),
        );
        if (value)
          people.insert(0, {
            'id': id,
            'name': name,
            'profileUrl': profileUrl,
            'department': department,
          });
        await _storage.writeMapList(
          AppStorageKeys.likedPeople,
          people,
          preferences: prefs,
        );
        await requirePreferenceWrite(prefs.setBool(flag, value));
      },
    );
    ActivityChangeService.notifyChanged();
  });

  Future<void> addComment(Map<String, dynamic> comment) => _serialize(() async {
    final values = await comments();
    values.insert(0, Map<String, dynamic>.from(comment));
    await _storage.writeMapList(AppStorageKeys.userComments, values);
    ActivityChangeService.notifyChanged();
  });

  Future<void> removeComment(Map<String, dynamic> comment) =>
      _serialize(() async {
        final values = await comments();
        final index = values.indexWhere(
          (value) =>
              value['movieId']?.toString() == comment['movieId']?.toString() &&
              value['content'] == comment['content'] &&
              value['date'] == comment['date'],
        );
        if (index < 0) return;
        values.removeAt(index);
        await _storage.writeMapList(AppStorageKeys.userComments, values);
        ActivityChangeService.notifyChanged();
      });

  Future<List<Map<String, dynamic>>> likedMovies() =>
      _storage.readMapList(AppStorageKeys.likedMovies);

  Future<List<Map<String, dynamic>>> watchedMovies() =>
      _storage.readMapList(AppStorageKeys.watchedMovies);

  Future<List<Map<String, dynamic>>> likedPeople() =>
      _storage.readMapList(AppStorageKeys.likedPeople);

  Future<List<Map<String, dynamic>>> comments() =>
      _storage.readMapList(AppStorageKeys.userComments);

  Future<bool> isMovieLiked(int id) => _readFlag(AppStorageKeys.likedMovie(id));
  Future<bool> isMovieWatched(int id) =>
      _readFlag(AppStorageKeys.watchedMovie(id));
  Future<bool> isPersonLiked(int id) =>
      _readFlag(AppStorageKeys.likedPerson(id));

  Future<bool> _readFlag(String key) async {
    final prefs = await _storage.getPreferences();
    return prefs.getBool(key) ?? false;
  }
}
