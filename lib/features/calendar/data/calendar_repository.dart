import 'package:filmcock_app/core/storage/app_storage_keys.dart';
import 'package:filmcock_app/core/storage/safe_json_storage.dart';

class CalendarRepository {
  final SafeJsonStorage _storage;

  const CalendarRepository({SafeJsonStorage storage = const SafeJsonStorage()})
    : _storage = storage;

  Future<Map<String, dynamic>> load() =>
      _storage.readMap(AppStorageKeys.calendarMovies);

  Future<void> save(Map<String, dynamic> calendar) =>
      _storage.writeMap(AppStorageKeys.calendarMovies, calendar);
}
