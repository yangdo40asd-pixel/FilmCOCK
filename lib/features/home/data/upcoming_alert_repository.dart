import 'package:filmcock_app/core/storage/app_storage_keys.dart';
import 'package:filmcock_app/core/storage/preferences_transaction.dart';
import 'package:filmcock_app/core/time/app_clock.dart';
import 'package:filmcock_app/core/utils/release_date_utils.dart';
import 'package:filmcock_app/features/preferences/data/user_settings_repository.dart';
import 'package:filmcock_app/shared/domain/models/movie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpcomingAlert {
  final Movie movie;
  final String dDayText;
  const UpcomingAlert(this.movie, this.dDayText);
}

/// 화면 밖에서 안내 대상과 날짜별 중복 표시 여부를 판정한다.
class UpcomingAlertRepository {
  final UserSettingsRepository settings;
  final AppClock clock;
  final Future<SharedPreferences> Function()? preferences;

  const UpcomingAlertRepository({
    this.settings = const UserSettingsRepository(),
    this.clock = const SystemClock(),
    this.preferences,
  });

  Future<UpcomingAlert?> prepare(List<Movie> movies) async {
    if (!(await settings.loadNotifications()).shouldShowUpcoming ||
        movies.isEmpty)
      return null;
    final movie = movies.firstWhere(
      (item) => item.fullPosterUrl.isNotEmpty,
      orElse: () => movies.first,
    );
    final now = clock.now();
    var label = 'D-1';
    final date = DateTime.tryParse(movie.releaseDate);
    if (date != null) {
      final days = ReleaseDateUtils.daysUntil(date, from: now);
      label = days == 0
          ? 'D-Day'
          : days > 0
          ? 'D-$days'
          : '개봉임박';
    }
    final prefs =
        await (preferences?.call() ?? SharedPreferences.getInstance());
    final viewer = settings.currentUserId ?? 'guest';
    final key = '$viewer:${now.toIso8601String().substring(0, 10)}:${movie.id}';
    if (prefs.getString(AppStorageKeys.lastUpcomingAlert) == key) return null;
    await requirePreferenceWrite(
      prefs.setString(AppStorageKeys.lastUpcomingAlert, key),
    );
    return UpcomingAlert(movie, label);
  }
}
