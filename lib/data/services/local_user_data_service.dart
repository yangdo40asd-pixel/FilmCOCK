import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:filmcock_app/data/storage/app_storage_keys.dart';

class LocalUserDataService {
  static bool isUserKey(String key) {
    return AppStorageKeys.isUserScoped(key);
  }

  static Future<void> clear({SharedPreferences? preferences}) async {
    final prefs = preferences ?? await SharedPreferences.getInstance();
    final profileImagePath = prefs.getString(AppStorageKeys.userProfileImage);
    if (profileImagePath != null && profileImagePath.isNotEmpty) {
      try {
        final image = File(profileImagePath);
        if (await image.exists()) await image.delete();
      } catch (_) {
        // 계정 상태 정리는 이미지 파일 삭제 실패와 관계없이 계속한다.
      }
    }

    final keysToRemove = prefs.getKeys().where(isUserKey).toList();
    await Future.wait(keysToRemove.map(prefs.remove));
  }
}
