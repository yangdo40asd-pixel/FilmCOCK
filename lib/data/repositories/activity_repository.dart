import 'package:filmcock_app/data/storage/app_storage_keys.dart';
import 'package:filmcock_app/data/storage/safe_json_storage.dart';
import 'package:filmcock_app/data/services/activity_change_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivityRepository {
  final SafeJsonStorage _storage;

  const ActivityRepository({SafeJsonStorage storage = const SafeJsonStorage()})
    : _storage = storage;

  Future<List<Map<String, dynamic>>> likedMovies() =>
      _storage.readMapList(AppStorageKeys.likedMovies);

  Future<List<Map<String, dynamic>>> watchedMovies() =>
      _storage.readMapList(AppStorageKeys.watchedMovies);

  Future<List<Map<String, dynamic>>> likedPeople() =>
      _storage.readMapList(AppStorageKeys.likedPeople);

  Future<List<Map<String, dynamic>>> comments() =>
      _storage.readMapList(AppStorageKeys.userComments);

  Future<void> saveLikedMovies(Iterable<Map<String, dynamic>> values) async {
    await _storage.writeMapList(AppStorageKeys.likedMovies, values);
    ActivityChangeService.notifyChanged();
  }

  Future<void> saveWatchedMovies(Iterable<Map<String, dynamic>> values) async {
    await _storage.writeMapList(AppStorageKeys.watchedMovies, values);
    ActivityChangeService.notifyChanged();
  }

  Future<void> saveLikedPeople(Iterable<Map<String, dynamic>> values) async {
    await _storage.writeMapList(AppStorageKeys.likedPeople, values);
    ActivityChangeService.notifyChanged();
  }

  Future<void> saveComments(Iterable<Map<String, dynamic>> values) async {
    await _storage.writeMapList(AppStorageKeys.userComments, values);
    ActivityChangeService.notifyChanged();
  }

  Future<bool> isMovieLiked(int id) => _readFlag(AppStorageKeys.likedMovie(id));
  Future<bool> isMovieWatched(int id) =>
      _readFlag(AppStorageKeys.watchedMovie(id));
  Future<bool> isPersonLiked(int id) =>
      _readFlag(AppStorageKeys.likedPerson(id));

  Future<void> setMovieLiked(int id, bool value) =>
      _writeFlag(AppStorageKeys.likedMovie(id), value);
  Future<void> setMovieWatched(int id, bool value) =>
      _writeFlag(AppStorageKeys.watchedMovie(id), value);
  Future<void> setPersonLiked(int id, bool value) =>
      _writeFlag(AppStorageKeys.likedPerson(id), value);

  Future<bool> _readFlag(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  Future<void> _writeFlag(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }
}
