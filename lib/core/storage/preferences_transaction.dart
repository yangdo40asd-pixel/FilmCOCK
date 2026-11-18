import 'package:shared_preferences/shared_preferences.dart';

Future<void> requirePreferenceWrite(Future<bool> write) async {
  if (!await write) throw StateError('로컬 저장을 완료하지 못했습니다.');
}

/// SharedPreferences는 트랜잭션 DB가 아니다. 실패 시 기존 값 복원을 시도한다.
Future<void> withPreferenceRollback(
  SharedPreferences preferences,
  Iterable<String> keys,
  Future<void> Function() operation,
) async {
  final previous = {
    for (final key in keys)
      key: switch (preferences.get(key)) {
        final List<String> value => List<String>.from(value),
        final Object? value => value,
      },
  };
  try {
    await operation();
  } catch (_) {
    for (final entry in previous.entries) {
      try {
        final value = entry.value;
        if (value == null) {
          await requirePreferenceWrite(preferences.remove(entry.key));
        } else if (value is bool) {
          await requirePreferenceWrite(preferences.setBool(entry.key, value));
        } else if (value is String) {
          await requirePreferenceWrite(preferences.setString(entry.key, value));
        } else if (value is List<String>) {
          await requirePreferenceWrite(
            preferences.setStringList(entry.key, value),
          );
        } else if (value is int) {
          await requirePreferenceWrite(preferences.setInt(entry.key, value));
        } else if (value is double) {
          await requirePreferenceWrite(preferences.setDouble(entry.key, value));
        }
      } catch (_) {
        // 원래 저장 오류를 유지한다. 저장 장치 실패 시 복원도 보장할 수 없다.
      }
    }
    rethrow;
  }
}
