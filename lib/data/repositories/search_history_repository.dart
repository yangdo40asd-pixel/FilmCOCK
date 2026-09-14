import 'package:filmcock_app/data/storage/app_storage_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryRepository {
  const SearchHistoryRepository();

  Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(AppStorageKeys.recentSearches) ?? const [];
  }

  Future<List<String>> add(String query, Iterable<String> current) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return List<String>.from(current);

    final updated = List<String>.from(current)
      ..remove(trimmed)
      ..insert(0, trimmed);
    if (updated.length > 10) updated.removeRange(10, updated.length);
    await _save(updated);
    return updated;
  }

  Future<List<String>> remove(String query, Iterable<String> current) async {
    final updated = List<String>.from(current)..remove(query);
    await _save(updated);
    return updated;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppStorageKeys.recentSearches);
  }

  Future<void> _save(List<String> values) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(AppStorageKeys.recentSearches, values);
  }
}
