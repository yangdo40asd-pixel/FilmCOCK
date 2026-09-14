class AppStorageKeys {
  AppStorageKeys._();

  static const guestMode = 'guest_mode';
  static const guestSessionId = 'guest_session_id';
  static const onboardingComplete = 'onboarding_complete';
  static const mbtiDecided = 'mbti_decided';
  static const genresDecided = 'genres_decided';
  static const userMbti = 'user_mbti';
  static const userGenres = 'user_genres';
  static const recentSearches = 'recent_searches';
  static const calendarMovies = 'calendar_movies_data';
  static const watchedMovies = 'watched_movies_data';
  static const likedMovies = 'liked_movies_data';
  static const likedPeople = 'liked_people';
  static const userComments = 'user_comments';
  static const userNickname = 'user_nickname';
  static const userBio = 'user_bio';
  static const userProfileImage = 'user_profile_image';
  static const lastUpcomingAlert = 'last_upcoming_alert';
  static const allPush = 'setting_all_push';
  static const upcomingMovieAlarm = 'setting_upcoming_movie_alarm';
  static const isDarkMode = 'is_dark_mode';
  static const homeLastGood = 'home_last_good_v1';

  static String likedMovie(int movieId) => 'liked_movie_$movieId';
  static String watchedMovie(int movieId) => 'watched_movie_$movieId';
  static String likedPerson(int personId) => 'liked_person_$personId';

  static const userScoped = <String>{
    guestMode,
    guestSessionId,
    onboardingComplete,
    mbtiDecided,
    genresDecided,
    userMbti,
    userGenres,
    recentSearches,
    calendarMovies,
    watchedMovies,
    likedMovies,
    likedPeople,
    userComments,
    userNickname,
    userBio,
    userProfileImage,
    lastUpcomingAlert,
  };

  static bool isUserScoped(String key) {
    return userScoped.contains(key) ||
        userScoped.any((baseKey) => key.startsWith('$baseKey::')) ||
        key.startsWith('liked_movie_') ||
        key.startsWith('liked_person_') ||
        key.startsWith('watched_movie_');
  }

  static String forOwner(String key, String ownerId) => '$key::$ownerId';
}
