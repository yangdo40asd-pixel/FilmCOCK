import 'package:filmcock_app/features/preferences/domain/mbti_info.dart';
import 'package:filmcock_app/features/preferences/domain/user_settings.dart';

enum StartupDestination { login, mbti, genres, home }

/// 화면 인스턴스 없이 시작 경로를 결정한다.
class StartupRoute {
  final StartupDestination destination;
  final MbtiInfo? mbtiInfo;

  const StartupRoute(this.destination, {this.mbtiInfo});

  static StartupDestination resolve({
    required bool isAuthenticated,
    required OnboardingState? onboarding,
  }) {
    if (!isAuthenticated) return StartupDestination.login;
    if (onboarding?.isComplete == true) return StartupDestination.home;
    if (onboarding?.isMbtiDecided != true) return StartupDestination.mbti;
    return StartupDestination.genres;
  }
}
