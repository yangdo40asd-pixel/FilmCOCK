import 'package:filmcock_app/features/preferences/domain/user_settings.dart';
export 'package:filmcock_app/features/preferences/domain/user_settings.dart';
import 'package:filmcock_app/features/preferences/domain/preference_repository.dart';
import 'package:filmcock_app/core/storage/app_storage_keys.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:filmcock_app/core/storage/preferences_transaction.dart';

class UserSettingsRepository implements PreferenceRepository {
  final Future<SharedPreferences> Function()? preferences;
  final String? Function()? authenticatedUserId;

  const UserSettingsRepository({this.preferences, this.authenticatedUserId});

  Future<SharedPreferences> _preferences() =>
      preferences?.call() ?? SharedPreferences.getInstance();

  String? get currentUserId => authenticatedUserId != null
      ? authenticatedUserId!()
      : Firebase.apps.isEmpty
      ? null
      : FirebaseAuth.instance.currentUser?.uid;

  Future<String> _preferenceOwner(SharedPreferences prefs) async {
    final uid = currentUserId;
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
    final prefs = await _preferences();
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
    final prefs = await _preferences();
    await requirePreferenceWrite(prefs.setBool(key, value));
  }

  @override
  Future<PreferenceSnapshot> loadPreferences() async {
    final prefs = await _preferences();
    final owner = await _preferenceOwner(prefs);
    return PreferenceSnapshot(
      mbti: prefs.getString(
        AppStorageKeys.forOwner(AppStorageKeys.userMbti, owner),
      ),
      genres:
          prefs.getStringList(
            AppStorageKeys.forOwner(AppStorageKeys.userGenres, owner),
          ) ??
          const [],
    );
  }

  @override
  Future<String?> loadMbti() async {
    final prefs = await _preferences();
    return prefs.getString(
      await _preferenceKey(prefs, AppStorageKeys.userMbti),
    );
  }

  Future<void> saveMbti(String value) async {
    final prefs = await _preferences();
    await requirePreferenceWrite(
      prefs.setString(
        await _preferenceKey(prefs, AppStorageKeys.userMbti),
        value,
      ),
    );
    await requirePreferenceWrite(
      prefs.setBool(
        await _preferenceKey(prefs, AppStorageKeys.mbtiDecided),
        true,
      ),
    );
  }

  Future<void> clearMbti() async {
    final prefs = await _preferences();
    await requirePreferenceWrite(
      prefs.remove(await _preferenceKey(prefs, AppStorageKeys.userMbti)),
    );
  }

  Future<List<String>> loadGenres() async {
    final prefs = await _preferences();
    return prefs.getStringList(
          await _preferenceKey(prefs, AppStorageKeys.userGenres),
        ) ??
        const [];
  }

  Future<void> saveGenres(List<String> values) async {
    final prefs = await _preferences();
    await requirePreferenceWrite(
      prefs.setStringList(
        await _preferenceKey(prefs, AppStorageKeys.userGenres),
        values,
      ),
    );
    await requirePreferenceWrite(
      prefs.setBool(
        await _preferenceKey(prefs, AppStorageKeys.genresDecided),
        true,
      ),
    );
  }

  Future<void> clearGenres() async {
    final prefs = await _preferences();
    await requirePreferenceWrite(
      prefs.remove(await _preferenceKey(prefs, AppStorageKeys.userGenres)),
    );
  }

  Future<OnboardingState> loadOnboarding() async {
    final prefs = await _preferences();
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
    final prefs = await _preferences();
    await requirePreferenceWrite(
      prefs.setString(
        AppStorageKeys.guestSessionId,
        DateTime.now().microsecondsSinceEpoch.toString(),
      ),
    );
    await requirePreferenceWrite(prefs.setBool(AppStorageKeys.guestMode, true));
  }

  Future<void> endGuestSession() async {
    final prefs = await _preferences();
    await requirePreferenceWrite(
      prefs.setBool(AppStorageKeys.guestMode, false),
    );
    await requirePreferenceWrite(prefs.remove(AppStorageKeys.guestSessionId));
  }

  @override
  Future<void> saveOnboardingPreferences({
    required String? mbti,
    required List<String> genres,
    required bool mbtiSkipped,
    required bool genresSkipped,
  }) async {
    final prefs = await _preferences();
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

    await withPreferenceRollback(
      prefs,
      [mbtiKey, genresKey, mbtiDecidedKey, genresDecidedKey],
      () async {
        if (mbtiSkipped || mbti == null || mbti.isEmpty || mbti == 'NONE') {
          await requirePreferenceWrite(prefs.remove(mbtiKey));
        } else {
          await requirePreferenceWrite(prefs.setString(mbtiKey, mbti));
        }
        await requirePreferenceWrite(
          prefs.setStringList(genresKey, genresSkipped ? const [] : genres),
        );
        await requirePreferenceWrite(prefs.setBool(mbtiDecidedKey, true));
        await requirePreferenceWrite(prefs.setBool(genresDecidedKey, true));
      },
    );
  }

  Future<void> setGuestMode(bool value) {
    return value ? startGuestSession() : endGuestSession();
  }

  Future<void> setOnboardingComplete(bool value) async {
    final prefs = await _preferences();
    await requirePreferenceWrite(
      prefs.setBool(
        await _preferenceKey(prefs, AppStorageKeys.mbtiDecided),
        value,
      ),
    );
    await requirePreferenceWrite(
      prefs.setBool(
        await _preferenceKey(prefs, AppStorageKeys.genresDecided),
        value,
      ),
    );
  }

  Future<UserProfileData> loadProfile() async {
    final prefs = await _preferences();
    return UserProfileData(
      nickname: prefs.getString(AppStorageKeys.userNickname) ?? '영화 매니아',
      bio: prefs.getString(AppStorageKeys.userBio) ?? '영화와 함께하는 일상!',
      imagePath: prefs.getString(AppStorageKeys.userProfileImage),
    );
  }

  Future<void> saveProfile(UserProfileData profile) async {
    final prefs = await _preferences();
    await requirePreferenceWrite(
      prefs.setString(AppStorageKeys.userNickname, profile.nickname),
    );
    await requirePreferenceWrite(
      prefs.setString(AppStorageKeys.userBio, profile.bio),
    );
    if (profile.imagePath == null || profile.imagePath!.isEmpty) {
      await requirePreferenceWrite(
        prefs.remove(AppStorageKeys.userProfileImage),
      );
    } else {
      await requirePreferenceWrite(
        prefs.setString(AppStorageKeys.userProfileImage, profile.imagePath!),
      );
    }
  }
}
