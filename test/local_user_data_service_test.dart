import 'dart:io';

import 'package:filmcock_app/data/services/local_user_data_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'logout cleanup removes user data but preserves device settings',
    () async {
      final tempDirectory = await Directory.systemTemp.createTemp(
        'filmcock-profile-',
      );
      final image = File('${tempDirectory.path}${Platform.pathSeparator}p.jpg');
      await image.writeAsBytes([1, 2, 3]);

      SharedPreferences.setMockInitialValues({
        'user_mbti': 'INFP',
        'user_comments': <String>['comment'],
        'liked_movie_42': true,
        'watched_movie_42': true,
        'user_profile_image': image.path,
        'is_dark_mode': false,
        'setting_all_push': false,
      });
      final prefs = await SharedPreferences.getInstance();

      await LocalUserDataService.clear(preferences: prefs);

      expect(prefs.getString('user_mbti'), isNull);
      expect(prefs.getStringList('user_comments'), isNull);
      expect(prefs.getBool('liked_movie_42'), isNull);
      expect(prefs.getBool('watched_movie_42'), isNull);
      expect(await image.exists(), isFalse);
      expect(prefs.getBool('is_dark_mode'), isFalse);
      expect(prefs.getBool('setting_all_push'), isFalse);

      await tempDirectory.delete(recursive: true);
    },
  );
}
