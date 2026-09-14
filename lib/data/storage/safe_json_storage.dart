import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SafeJsonStorage {
  const SafeJsonStorage();

  Future<List<Map<String, dynamic>>> readMapList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final rawItems = prefs.getStringList(key) ?? const <String>[];
    final valid = <Map<String, dynamic>>[];
    var needsRepair = false;

    for (final raw in rawItems) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          valid.add(decoded);
        } else {
          needsRepair = true;
        }
      } catch (_) {
        needsRepair = true;
      }
    }

    if (needsRepair) await writeMapList(key, valid, preferences: prefs);
    return valid;
  }

  Future<void> writeMapList(
    String key,
    Iterable<Map<String, dynamic>> values, {
    SharedPreferences? preferences,
  }) async {
    final prefs = preferences ?? await SharedPreferences.getInstance();
    await prefs.setStringList(
      key,
      values.map(jsonEncode).toList(growable: false),
    );
  }

  Future<Map<String, dynamic>> readMap(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return <String, dynamic>{};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    await prefs.remove(key);
    return <String, dynamic>{};
  }

  Future<void> writeMap(String key, Map<String, dynamic> value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(value));
  }
}
