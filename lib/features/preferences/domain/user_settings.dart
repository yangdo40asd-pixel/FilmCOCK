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
