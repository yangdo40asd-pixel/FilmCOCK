import 'package:flutter/material.dart';
import 'package:filmcock_app/data/repositories/user_settings_repository.dart';
import 'package:filmcock_app/data/models/movie_model.dart';
import 'package:filmcock_app/data/models/mbti_info.dart';
import 'package:filmcock_app/data/services/api_service.dart';
import 'package:filmcock_app/data/services/personalized_recommendation_service.dart';
import 'package:filmcock_app/data/services/preference_change_service.dart';
import 'package:filmcock_app/presentation/screens/detail/movie_detail_screen.dart';
import 'package:filmcock_app/presentation/screens/onboarding/genre_select_screen.dart';
import 'package:filmcock_app/presentation/screens/onboarding/mbti_select_screen.dart';

class PreferenceScreen extends StatefulWidget {
  const PreferenceScreen({super.key});

  @override
  State<PreferenceScreen> createState() => _PreferenceScreenState();
}

class _PreferenceScreenState extends State<PreferenceScreen> {
  final UserSettingsRepository _settingsRepository =
      const UserSettingsRepository();
  Future<List<Movie>>? _recommendedMoviesFuture;
  String? _userMbti;
  List<String> _userGenres = const [];
  int _loadId = 0;

  @override
  void initState() {
    super.initState();
    PreferenceChangeService.revision.addListener(_handlePreferenceChange);
    _loadRecommendations();
  }

  @override
  void dispose() {
    PreferenceChangeService.revision.removeListener(_handlePreferenceChange);
    super.dispose();
  }

  void _handlePreferenceChange() {
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    final loadId = ++_loadId;
    final values = await Future.wait<Object?>([
      _settingsRepository.loadMbti(),
      _settingsRepository.loadGenres(),
    ]);
    final savedMbti = values[0] as String?;
    final savedGenres = values[1] as List<String>;

    if (!mounted || loadId != _loadId) return;
    setState(() {
      _userMbti = savedMbti;
      _userGenres = savedGenres;
      _recommendedMoviesFuture = _fetchPersonalizedMovies(
        savedMbti,
        savedGenres,
      );
    });
  }

  Future<List<Movie>> _fetchPersonalizedMovies(
    String? mbti,
    List<String> genres,
  ) async {
    List<Movie> fallback;
    try {
      fallback = await ApiService.getPopularMovies();
    } catch (_) {
      fallback = const [];
    }
    final recommendation = await PersonalizedRecommendationService.load(
      mbti: mbti,
      genres: genres,
      fallback: fallback,
    );
    return recommendation.movies;
  }

  // --- 설정 재설정 모달 다이얼로그 (참고 이미지 2) ---
  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (dialogContext) => Dialog(
        backgroundColor: const Color(0xFF202028),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 36.0),
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 헤더: 타이틀 + 닫기(X) 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '설정 재설정',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(dialogContext).pop(),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white70,
                      size: 22.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),

              // 버튼 1: 선호 장르 재설정 (초록색 버튼)
              SizedBox(
                width: double.infinity,
                height: 54.0,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();

                    final currentMbtiInfo =
                        (_userMbti != null &&
                            _userMbti != 'NONE' &&
                            _userMbti != 'skipped')
                        ? (getMbtiInfoById(_userMbti!) ??
                              const MbtiInfo(
                                id: 'NONE',
                                title: '',
                                description: '',
                                feature: '',
                                recommendedGenres: '',
                                genreIds: [],
                                famousPeople: [],
                                svgAsset: '',
                              ))
                        : const MbtiInfo(
                            id: 'NONE',
                            title: '',
                            description: '',
                            feature: '',
                            recommendedGenres: '',
                            genreIds: [],
                            famousPeople: [],
                            svgAsset: '',
                          );

                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => GenreSelectScreen(
                          mbtiInfo: currentMbtiInfo,
                          isResetMode: true,
                          preferSavedGenres: true,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF48C95F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '선호 장르 재설정',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14.0),

              // 버튼 2: MBTI 재설정 (보라색 버튼)
              SizedBox(
                width: double.infinity,
                height: 54.0,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();

                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            const MbtiSelectScreen(isResetMode: true),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B4EE6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'MBTI 재설정',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // MBTI 표기 텍스트: MBTI가 선택되어 있으면 MBTI명, 스킵되었으면 skipped
    final hasMbti =
        _userMbti != null && _userMbti != 'NONE' && _userMbti != 'skipped';
    final genreDisplay = PersonalizedRecommendationService.genreNameFor(
      mbti: _userMbti,
      genres: _userGenres,
    );
    final preferenceDisplay = [
      if (hasMbti) _userMbti!,
      if (genreDisplay != null) genreDisplay,
    ].join(' · ');

    return Scaffold(
      backgroundColor: const Color(0xFF16161A),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 상단 헤더 (타이틀 + 재설정 버튼)
              _buildHeader(
                context,
                preferenceDisplay.isEmpty ? '설정 안 함' : preferenceDisplay,
              ),

              // 2. 취향 저격 추천 영화 타이틀
              const Padding(
                padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 14.0),
                child: Text(
                  '취향 저격 추천 영화',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),

              // 3. 추천 영화 2열 그리드
              _buildMovieGrid(),
            ],
          ),
        ),
      ),
    );
  }

  // --- 상단 헤더 위젯 ---
  Widget _buildHeader(BuildContext context, String mbtiDisplay) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 그라데이션 타이틀
          Expanded(
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF4EE3CE), Color(0xFF55C75A)],
              ).createShader(bounds),
              child: Text(
                '당신의 취향저격! $mbtiDisplay',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // ⚙ 재설정 버튼
          GestureDetector(
            onTap: () => _showResetDialog(context),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 7.0,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF282832),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.settings, color: Colors.white70, size: 16.0),
                  SizedBox(width: 5.0),
                  Text(
                    '재설정',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 추천 영화 2열 그리드 ---
  Widget _buildMovieGrid() {
    return FutureBuilder<List<Movie>>(
      future: _recommendedMoviesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 300.0,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
              ),
            ),
          );
        }

        final movies = snapshot.data ?? [];
        if (movies.isEmpty) {
          return const SizedBox(
            height: 200.0,
            child: Center(
              child: Text(
                '추천 영화를 불러올 수 없습니다.',
                style: TextStyle(color: Colors.white54, fontSize: 15.0),
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: movies.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14.0,
              mainAxisSpacing: 18.0,
              childAspectRatio: 0.62,
            ),
            itemBuilder: (context, index) {
              final movie = movies[index];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MovieDetailScreen(movie: movie),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Container(
                          color: const Color(0xFF282832),
                          width: double.infinity,
                          child: movie.fullPosterUrl.isNotEmpty
                              ? Image.network(
                                  movie.fullPosterUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Center(
                                    child: Icon(
                                      Icons.movie,
                                      color: Colors.white38,
                                    ),
                                  ),
                                )
                              : const Center(
                                  child: Icon(
                                    Icons.movie,
                                    color: Colors.white38,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      movie.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
