import 'package:filmcock_app/data/storage/app_storage_keys.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettings {
  final bool allEnabled;
  final bool upcomingMoviesEnabled;

  const NotificationSettings({
    required this.allEnabled,
    required this.upcomingMoviesEnabled,
  });

  bool get shouldShowUpcoming => allEnabled && upcomingMoviesEnabled;
}

class UserProfileData {
  final String nickname;
  final String bio;
  final String? imagePath;

  const UserProfileData({
    required this.nickname,
    required this.bio,
    this.imagePath,
  });
}

class OnboardingState {
  final bool isGuest;
  final bool isMbtiDecided;
  final bool isGenresDecided;

  const OnboardingState({
    required this.isGuest,
    required this.isMbtiDecided,
    required this.isGenresDecided,
  });

  bool get isComplete => isMbtiDecided && isGenresDecided;
}

class UserSettingsRepository {
  const UserSettingsRepository();

  Future<String> _preferenceOwner(SharedPreferences prefs) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && uid.isNotEmpty) return 'user_$uid';

    final guestId = prefs.getString(AppStorageKeys.guestSessionId);
    if ((prefs.getBool(AppStorageKeys.guestMode) ?? false) &&
        guestId != null &&
        guestId.isNotEmpty) {
      return 'guest_$guestId';
    }
    return 'anonymous';
  }

  Future<String> _preferenceKey(SharedPreferences prefs, String baseKey) async {
    return AppStorageKeys.forOwner(baseKey, await _preferenceOwner(prefs));
  }

  Future<NotificationSettings> loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return NotificationSettings(
      allEnabled: prefs.getBool(AppStorageKeys.allPush) ?? true,
      upcomingMoviesEnabled:
          prefs.getBool(AppStorageKeys.upcomingMovieAlarm) ?? true,
    );
  }

  Future<void> setNotification(String key, bool value) async {
    if (key != AppStorageKeys.allPush &&
        key != AppStorageKeys.upcomingMovieAlarm) {
      throw ArgumentError.value(key, 'key', '지원하지 않는 알림 설정입니다.');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<String?> loadMbti() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(
      await _preferenceKey(prefs, AppStorageKeys.userMbti),
    );
  }

  Future<void> saveMbti(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      await _preferenceKey(prefs, AppStorageKeys.userMbti),
      value,
    );
    await prefs.setBool(
      await _preferenceKey(prefs, AppStorageKeys.mbtiDecided),
      true,
    );
  }

  Future<void> clearMbti() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(await _preferenceKey(prefs, AppStorageKeys.userMbti));
  }

  Future<List<String>> loadGenres() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(
          await _preferenceKey(prefs, AppStorageKeys.userGenres),
        ) ??
        const [];
  }

  Future<void> saveGenres(List<String> values) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      await _preferenceKey(prefs, AppStorageKeys.userGenres),
      values,
    );
    await prefs.setBool(
      await _preferenceKey(prefs, AppStorageKeys.genresDecided),
      true,
    );
  }

  Future<void> clearGenres() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(await _preferenceKey(prefs, AppStorageKeys.userGenres));
  }

  Future<OnboardingState> loadOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return OnboardingState(
      isGuest: prefs.getBool(AppStorageKeys.guestMode) ?? false,
      isMbtiDecided:
          prefs.getBool(
            await _preferenceKey(prefs, AppStorageKeys.mbtiDecided),
          ) ??
          false,
      isGenresDecided:
          prefs.getBool(
            await _preferenceKey(prefs, AppStorageKeys.genresDecided),
          ) ??
          false,
    );
  }

  Future<void> startGuestSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppStorageKeys.guestSessionId,
      DateTime.now().microsecondsSinceEpoch.toString(),
    );
    await prefs.setBool(AppStorageKeys.guestMode, true);
  }

  Future<void> endGuestSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppStorageKeys.guestMode, false);
    await prefs.remove(AppStorageKeys.guestSessionId);
  }

  Future<void> saveOnboardingPreferences({
    required String? mbti,
    required List<String> genres,
    required bool mbtiSkipped,
    required bool genresSkipped,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final mbtiKey = await _preferenceKey(prefs, AppStorageKeys.userMbti);
    final genresKey = await _preferenceKey(prefs, AppStorageKeys.userGenres);
    final mbtiDecidedKey = await _preferenceKey(
      prefs,
      AppStorageKeys.mbtiDecided,
    );
    final genresDecidedKey = await _preferenceKey(
      prefs,
      AppStorageKeys.genresDecided,
    );

    if (mbtiSkipped || mbti == null || mbti.isEmpty || mbti == 'NONE') {
      await prefs.remove(mbtiKey);
    } else {
      await prefs.setString(mbtiKey, mbti);
    }
    await prefs.setStringList(genresKey, genresSkipped ? const [] : genres);
    await prefs.setBool(mbtiDecidedKey, true);
    await prefs.setBool(genresDecidedKey, true);
  }

  Future<void> setGuestMode(bool value) {
    return value ? startGuestSession() : endGuestSession();
  }

  Future<void> setOnboardingComplete(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      await _preferenceKey(prefs, AppStorageKeys.mbtiDecided),
      value,
    );
    await prefs.setBool(
      await _preferenceKey(prefs, AppStorageKeys.genresDecided),
      value,
    );
  }

  Future<UserProfileData> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return UserProfileData(
      nickname: prefs.getString(AppStorageKeys.userNickname) ?? '영화 매니아',
      bio: prefs.getString(AppStorageKeys.userBio) ?? '영화와 함께하는 일상!',
      imagePath: prefs.getString(AppStorageKeys.userProfileImage),
    );
  }

  Future<void> saveProfile(UserProfileData profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppStorageKeys.userNickname, profile.nickname);
    await prefs.setString(AppStorageKeys.userBio, profile.bio);
    if (profile.imagePath == null || profile.imagePath!.isEmpty) {
      await prefs.remove(AppStorageKeys.userProfileImage);
    } else {
      await prefs.setString(
        AppStorageKeys.userProfileImage,
        profile.imagePath!,
      );
    }
  }
}
