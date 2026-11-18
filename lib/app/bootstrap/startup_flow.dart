import 'package:firebase_auth/firebase_auth.dart';
import 'package:filmcock_app/app/routing/startup_destination.dart';
import 'package:filmcock_app/features/preferences/domain/mbti_info.dart';
import 'package:filmcock_app/features/preferences/data/user_settings_repository.dart';
import 'package:filmcock_app/features/home/data/home_prefetch_service.dart';

/// 세션 판정과 홈 사전 준비를 조합한다. 실제 화면 이동은 UI가 담당한다.
class StartupFlow {
  final UserSettingsRepository settings;
  final Duration minimumSplashDuration;
  final Future<void> Function()? warmHome;
  final bool Function()? isAuthenticated;

  const StartupFlow({
    this.settings = const UserSettingsRepository(),
    this.minimumSplashDuration = const Duration(milliseconds: 1200),
    this.warmHome,
    this.isAuthenticated,
  });

  Future<void> _warmHome() async {
    try {
      if (warmHome != null) {
        await warmHome!();
      } else {
        await HomePrefetchService.load();
      }
    } catch (_) {
      // 기존 정책: 홈의 섹션별 오류 표시와 캐시 복구로 이어간다.
    }
  }

  Future<StartupRoute> prepare() async {
    final minimumDelay = Future<void>.delayed(minimumSplashDuration);
    final homeWarmup = _warmHome();
    final authenticated =
        isAuthenticated?.call() ?? (FirebaseAuth.instance.currentUser != null);
    if (!authenticated) await settings.endGuestSession();

    final onboarding = authenticated ? await settings.loadOnboarding() : null;
    await minimumDelay;
    final destination = StartupRoute.resolve(
      isAuthenticated: authenticated,
      onboarding: onboarding,
    );

    MbtiInfo? info;
    if (destination == StartupDestination.genres) {
      final mbti = await settings.loadMbti();
      info = mbti == null ? null : getMbtiInfoById(mbti);
    }
    if (destination == StartupDestination.home) await homeWarmup;
    return StartupRoute(destination, mbtiInfo: info);
  }
}
