class PreferenceSnapshot {
  final String? mbti;
  final List<String> genres;

  PreferenceSnapshot({required this.mbti, required Iterable<String> genres})
    : genres = List.unmodifiable(genres);
}

abstract interface class PreferenceRepository {
  Future<PreferenceSnapshot> loadPreferences();
  Future<String?> loadMbti();
  Future<void> saveOnboardingPreferences({
    required String? mbti,
    required List<String> genres,
    required bool mbtiSkipped,
    required bool genresSkipped,
  });
}
