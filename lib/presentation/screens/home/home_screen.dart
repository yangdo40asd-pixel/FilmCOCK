import 'package:filmcock_app/presentation/screens/chat/chat_screen.dart';
import 'package:filmcock_app/core/theme/theme_controller.dart';
import 'package:filmcock_app/core/utils/release_date_utils.dart';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:filmcock_app/data/services/home_prefetch_service.dart';
import 'package:filmcock_app/data/services/preference_change_service.dart';
import 'package:filmcock_app/data/services/daily_recommendation_service.dart';
import 'package:filmcock_app/data/services/notification_settings_service.dart';
import 'package:filmcock_app/data/services/personalized_recommendation_service.dart';
import 'package:filmcock_app/data/repositories/user_settings_repository.dart';
import 'package:filmcock_app/data/storage/app_storage_keys.dart';
import 'package:filmcock_app/core/config/secrets.dart';
import 'package:filmcock_app/core/errors/app_exception.dart';
import 'package:filmcock_app/presentation/widgets/section_header.dart';
import 'package:filmcock_app/presentation/widgets/app_network_image.dart';
import 'package:filmcock_app/presentation/widgets/app_loading_indicator.dart';
import 'package:filmcock_app/presentation/widgets/home_external_sections.dart';
import 'package:filmcock_app/presentation/controllers/home_controller.dart';
import 'package:filmcock_app/presentation/screens/home/list_view_screen.dart';
import 'package:filmcock_app/presentation/screens/detail/movie_detail_screen.dart';
import 'package:filmcock_app/presentation/screens/detail/actor_detail_screen.dart';
import 'package:filmcock_app/presentation/screens/detail/artist_detail_screen.dart';
import 'package:filmcock_app/data/models/movie_model.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final UserSettingsRepository _settingsRepository =
      const UserSettingsRepository();

  Future<void> _checkAndShowUpcomingAlert() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationSettings = await _settingsRepository.loadNotifications();
    if (!notificationSettings.shouldShowUpcoming) return;

    try {
      final movies = await upcomingMovies;
      if (movies.isEmpty || !mounted) return;

      // Find upcoming movie with poster
      final movie = movies.firstWhere(
        (m) => m.fullPosterUrl.isNotEmpty,
        orElse: () => movies.first,
      );

      // Calculate D-day
      String dDayText = 'D-1';
      if (movie.releaseDate.isNotEmpty) {
        try {
          final release = DateTime.parse(movie.releaseDate);
          final diff = ReleaseDateUtils.daysUntil(release);
          if (diff == 0) {
            dDayText = 'D-Day';
          } else if (diff > 0) {
            dDayText = 'D-$diff';
          } else {
            dDayText = '개봉임박';
          }
        } catch (_) {}
      }

      if (!mounted) return;
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final viewerId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
      final alertKey = '$viewerId:$today:${movie.id}';
      if (prefs.getString(AppStorageKeys.lastUpcomingAlert) == alertKey) return;
      await prefs.setString(AppStorageKeys.lastUpcomingAlert, alertKey);
      if (!mounted) return;
      _showUpcomingDialog(movie, dDayText);
    } catch (_) {}
  }

  void _showUpcomingDialog(Movie movie, String dDayText) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        final colors = Theme.of(ctx).colorScheme;
        return Dialog(
          backgroundColor: colors.surfaceContainerHigh,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 40.0,
            vertical: 24.0,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 28.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Circular Bell Icon Badge
                Container(
                  width: 58,
                  height: 58,
                  decoration: const BoxDecoration(
                    color: Color(0xFF735BF2),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.notifications,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 18),

                // Dialog Title
                Text(
                  '곧 개봉해요!',
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Movie Poster
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: SizedBox(
                    width: 170,
                    height: 240,
                    child: AppNetworkImage(
                      imageUrl: movie.fullPosterUrl,
                      placeholderIconSize: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Movie Title
                Text(
                  movie.title,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Red D-day Pill Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 6.0,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF3B30),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Text(
                    dDayText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 26),

                // Action Buttons (닫기 & 상세보기)
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(
                          '닫기',
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B4EE6),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MovieDetailScreen(movie: movie),
                            ),
                          );
                        },
                        child: const Text(
                          '상세보기',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  final HomeController _home = HomeController();

  Future<List<Movie>> get popularMovies => _home.popularMovies;
  set popularMovies(Future<List<Movie>> value) => _home.popularMovies = value;
  Future<List<Movie>> get randomMovies => _home.randomMovies;
  set randomMovies(Future<List<Movie>> value) => _home.randomMovies = value;
  Future<List<Movie>> get upcomingMovies => _home.upcomingMovies;
  set upcomingMovies(Future<List<Movie>> value) => _home.upcomingMovies = value;
  Future<List<Movie>> get nowPlayingMovies => _home.nowPlayingMovies;
  set nowPlayingMovies(Future<List<Movie>> value) =>
      _home.nowPlayingMovies = value;
  Future<List<Movie>> get animationMovies => _home.animationMovies;
  set animationMovies(Future<List<Movie>> value) =>
      _home.animationMovies = value;
  Future<List<Movie>> get topRatedMovies => _home.topRatedMovies;
  set topRatedMovies(Future<List<Movie>> value) => _home.topRatedMovies = value;
  Future<List<Person>>? get popularKoreanActors => _home.popularKoreanActors;
  set popularKoreanActors(Future<List<Person>>? value) =>
      _home.popularKoreanActors = value;
  Future<List<Person>> get popularForeignActors => _home.popularForeignActors;
  set popularForeignActors(Future<List<Person>> value) =>
      _home.popularForeignActors = value;
  Future<List<Person>>? get popularKoreanDirectors =>
      _home.popularKoreanDirectors;
  set popularKoreanDirectors(Future<List<Person>>? value) =>
      _home.popularKoreanDirectors = value;
  String get _userMbti => _home.userMbti;
  set _userMbti(String value) => _home.userMbti = value;
  List<String> _userGenres = const [];
  String _personalizationLabel = '';
  int get _homeLoadId => _home.loadId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    PreferenceChangeService.revision.addListener(_handlePreferenceChange);
    NotificationSettingsService.revision.addListener(
      _handleNotificationSettingChange,
    );
    _loadMbti(_homeLoadId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowUpcomingAlert();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    PreferenceChangeService.revision.removeListener(_handlePreferenceChange);
    NotificationSettingsService.revision.removeListener(
      _handleNotificationSettingChange,
    );
    super.dispose();
  }

  void _handlePreferenceChange() {
    _loadMbti(_home.nextLoad());
  }

  void _handleNotificationSettingChange() {
    _checkAndShowUpcomingAlert();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    if (!_home.moveToTodayIfNeeded()) return;
    _refreshHome();
  }

  Future<void> _refreshHome() async {
    final session = _home.refresh();
    if (!mounted) return;
    setState(() {});
    _loadMbti(_homeLoadId);

    try {
      final data = await session.completed;
      if (!mounted) return;
      if (!data.isComplete) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('일부 홈 데이터를 불러오지 못했습니다.')));
      }
      await _checkAndShowUpcomingAlert();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('홈 데이터를 새로고침하지 못했습니다.')));
    }
  }

  void _retryPopularMovies() {
    setState(() {
      popularMovies = HomePrefetchService.fetchPopularMovies();
    });
  }

  void _retryRandomMovies() {
    setState(() {
      _home.nextLoad();
      randomMovies = HomePrefetchService.fetchPopularMovies().then((movies) {
        final fallback = DailyRecommendationService.orderMovies(movies);
        return _loadPersonalizedMovies(_userMbti, _userGenres, fallback);
      });
    });
  }

  void _retryUpcomingMovies() {
    final retry = HomePrefetchService.fetchUpcomingMovies();
    setState(() {
      upcomingMovies = retry;
    });
    retry.then((_) => _checkAndShowUpcomingAlert()).catchError((_) {});
  }

  void _retryNowPlayingMovies() {
    setState(() {
      nowPlayingMovies = HomePrefetchService.fetchNowPlayingMovies();
    });
  }

  void _retryAnimationMovies() {
    setState(() {
      animationMovies = HomePrefetchService.fetchAnimationMovies();
    });
  }

  void _retryClassicMovies() {
    setState(() {
      topRatedMovies = HomePrefetchService.fetchClassicMovies();
    });
  }

  void _retryKoreanActors() {
    setState(() {
      popularKoreanActors = HomePrefetchService.fetchKoreanActors();
    });
  }

  void _retryForeignActors() {
    setState(() {
      popularForeignActors = HomePrefetchService.fetchForeignActors();
    });
  }

  void _retryKoreanDirectors() {
    setState(() {
      popularKoreanDirectors = HomePrefetchService.fetchKoreanDirectors();
    });
  }

  Future<void> _loadMbti(int loadId) async {
    final preferences = await Future.wait<Object?>([
      _settingsRepository.loadMbti(),
      _settingsRepository.loadGenres(),
    ]);
    final savedMbti = preferences[0] as String?;
    final genres = preferences[1] as List<String>;
    final mbti = savedMbti ?? '추천영화';
    List<Movie> fallback;
    try {
      fallback = await randomMovies;
    } catch (_) {
      fallback = const <Movie>[];
    }
    if (!mounted || loadId != _homeLoadId) return;
    setState(() {
      _userMbti = mbti;
      _userGenres = genres;
      _personalizationLabel = savedMbti ?? '';
    });

    final personalized = await _loadPersonalizedMovies(
      savedMbti,
      genres,
      fallback,
    );
    if (!mounted || loadId != _homeLoadId) return;
    setState(() {
      randomMovies = Future.value(personalized);
    });
  }

  Future<List<Movie>> _loadPersonalizedMovies(
    String? mbti,
    List<String> genres,
    List<Movie> fallback,
  ) async {
    final recommendation = await PersonalizedRecommendationService.load(
      mbti: mbti,
      genres: genres,
      fallback: fallback,
    );
    return recommendation.movies;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bgColor = colors.surface;
    final titleColor = colors.onSurface;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: bgColor,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/1.png', height: 32),
            const SizedBox(width: 8),
            Text(
              'FilmCOCK!',
              style: TextStyle(
                color: titleColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeController.themeMode,
            builder: (context, mode, _) {
              final isCurrentDark = mode == ThemeMode.dark;
              return IconButton(
                icon: Icon(
                  isCurrentDark
                      ? Icons.nightlight_round
                      : Icons.wb_sunny_rounded,
                  color: isCurrentDark ? Colors.white : const Color(0xFFF59E0B),
                ),
                tooltip: isCurrentDark ? '라이트 모드로 전환' : '다크 모드로 전환',
                onPressed: () {
                  ThemeController.toggleTheme();
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: '영화 추천 도슨트 열기',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatScreen()),
          );
        },
        backgroundColor: colors.primary,
        child: const Icon(Icons.chat_bubble, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshHome,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              if (!ApiSecrets.hasTmdbCredentials || !ApiSecrets.hasKoficApiKey)
                _buildApiConfigurationNotice(),
              // 2. 자동 교체 스크린 (Hero Banner)
              _buildMovieSection(
                future: popularMovies,
                onRetry: _retryPopularMovies,
                builder: (movies) => _buildHeroCarousel(movies),
              ),
              const SizedBox(height: 24.0),

              // 3. 오늘의 랜덤 추천 영화 🍿
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SectionHeader(
                  title: _personalizationLabel.isEmpty
                      ? '오늘의 추천 영화'
                      : '오늘의 추천 영화 ($_personalizationLabel)',
                  emoji: '🍿',
                  onTap: () async {
                    final movies = await randomMovies;
                    if (!context.mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ListViewScreen.movies(
                          title: _personalizationLabel.isEmpty
                              ? '오늘의 추천 영화'
                              : '오늘의 추천 영화 ($_personalizationLabel)',
                          movies: movies,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12.0),
              _buildMovieSection(
                future: randomMovies,
                onRetry: _retryRandomMovies,
                builder: (movies) =>
                    _buildMovieHorizontalList(context, movies: movies),
              ),
              const SizedBox(height: 24.0),

              // 4. 방영 예정일 영화 📅
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SectionHeader(
                  title: '방영 예정일 영화',
                  emoji: '📅',
                  onTap: () async {
                    final movies = await upcomingMovies;
                    if (!context.mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ListViewScreen.movies(
                          title: '방영 예정일 영화',
                          movies: movies,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12.0),
              _buildMovieSection(
                future: upcomingMovies,
                onRetry: _retryUpcomingMovies,
                builder: (movies) =>
                    _buildUpcomingMoviesList(context, movies: movies),
              ),
              const SizedBox(height: 24.0),

              // 5. 최신 상영 영화 📽️
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SectionHeader(
                  title: '최신 상영 영화',
                  emoji: '📽️',
                  onTap: () async {
                    final movies = await nowPlayingMovies;
                    if (!context.mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ListViewScreen.movies(
                          title: '최신 상영 영화',
                          movies: movies,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12.0),
              _buildMovieSection(
                future: nowPlayingMovies,
                onRetry: _retryNowPlayingMovies,
                builder: (movies) =>
                    _buildMovieHorizontalList(context, movies: movies),
              ),
              const SizedBox(height: 24.0),

              // 6. 애니메이션 🦄
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SectionHeader(
                  title: '애니메이션',
                  emoji: '🦄',
                  onTap: () async {
                    final movies = await animationMovies;
                    if (!context.mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ListViewScreen.movies(
                          title: '애니메이션',
                          movies: movies,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12.0),
              _buildMovieSection(
                future: animationMovies,
                onRetry: _retryAnimationMovies,
                builder: (movies) =>
                    _buildMovieHorizontalList(context, movies: movies),
              ),
              const SizedBox(height: 24.0),

              // 7. 고전 명작 👍
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SectionHeader(
                  title: '고전 명작',
                  emoji: '👍',
                  onTap: () async {
                    final movies = await topRatedMovies;
                    if (!context.mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ListViewScreen.movies(
                          title: '고전 명작',
                          movies: movies,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12.0),
              _buildMovieSection(
                future: topRatedMovies,
                onRetry: _retryClassicMovies,
                builder: (movies) =>
                    _buildMovieHorizontalList(context, movies: movies),
              ),
              const SizedBox(height: 24.0),

              // 8. 한국 배우 🇰🇷
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SectionHeader(
                  title: '한국 배우',
                  emoji: '🇰🇷',
                  onTap: () async {
                    final actors = await popularKoreanActors;
                    if (!context.mounted) return;
                    if (actors != null && actors.isNotEmpty) {
                      _navigateToListScreen(context, '한국 배우', actors);
                    }
                  },
                ),
              ),
              const SizedBox(height: 12.0),
              _buildPersonSection(
                future: popularKoreanActors ?? Future.value([]),
                onRetry: _retryKoreanActors,
                builder: (persons) =>
                    _buildPersonHorizontalList(context, persons: persons),
              ),
              const SizedBox(height: 24.0),

              // 9. 해외 배우 🌟
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SectionHeader(
                  title: '해외 배우',
                  emoji: '🌟',
                  onTap: () async {
                    final actors = await popularForeignActors;
                    if (!context.mounted) return;
                    if (actors.isNotEmpty) {
                      _navigateToListScreen(context, '해외 배우', actors);
                    }
                  },
                ),
              ),
              const SizedBox(height: 12.0),
              _buildPersonSection(
                future: popularForeignActors,
                onRetry: _retryForeignActors,
                builder: (persons) =>
                    _buildPersonHorizontalList(context, persons: persons),
              ),
              const SizedBox(height: 24.0),

              // 10. 유명 감독 🎬
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SectionHeader(
                  title: '유명 감독',
                  emoji: '🎬',
                  onTap: () async {
                    final directors = await popularKoreanDirectors;
                    if (!context.mounted) return;
                    if (directors != null && directors.isNotEmpty) {
                      _navigateToListScreen(context, '유명 감독', directors);
                    }
                  },
                ),
              ),
              const SizedBox(height: 12.0),
              _buildPersonSection(
                future: popularKoreanDirectors ?? Future.value([]),
                onRetry: _retryKoreanDirectors,
                builder: (persons) => _buildPersonHorizontalList(
                  context,
                  persons: persons,
                  isDirector: true,
                ),
              ),
              const SizedBox(height: 24.0),

              // 11. 리뷰 채널 🎤
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SectionHeader(title: '리뷰 채널', emoji: '🎤', onTap: null),
              ),
              const SizedBox(height: 12.0),
              const ReviewChannelsSection(),
              const SizedBox(height: 20.0),
              const KoficBanner(),

              const SizedBox(height: 40.0),
            ],
          ),
        ),
      ),
    );
  }

  // --- 헬퍼 및 UI 빌더 메서드들 ---

  Widget _buildMovieSection({
    required Future<List<Movie>> future,
    required VoidCallback onRetry,
    required Widget Function(List<Movie>) builder,
  }) {
    return FutureBuilder<List<Movie>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 180,
            child: Center(
              child: AppLoadingIndicator(label: '배우 목록을 불러오는 중입니다.'),
            ),
          );
        }
        if (snapshot.hasError) {
          return _buildSectionStatus(
            height: 180,
            message: userMessageForError(
              snapshot.error,
              fallback: '영화 정보를 불러오지 못했습니다.',
            ),
            onRetry: onRetry,
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildSectionStatus(
            height: 180,
            message: '표시할 영화가 없습니다.',
            onRetry: onRetry,
          );
        }
        return builder(snapshot.data!);
      },
    );
  }

  Widget _buildPersonSection({
    required Future<List<Person>> future,
    required VoidCallback onRetry,
    required Widget Function(List<Person>) builder,
  }) {
    return FutureBuilder<List<Person>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 140,
            child: Center(
              child: AppLoadingIndicator(label: '감독 목록을 불러오는 중입니다.'),
            ),
          );
        }
        if (snapshot.hasError) {
          return _buildSectionStatus(
            height: 140,
            message: userMessageForError(
              snapshot.error,
              fallback: '인물 정보를 불러오지 못했습니다.',
            ),
            onRetry: onRetry,
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildSectionStatus(
            height: 140,
            message: '표시할 인물 정보가 없습니다.',
            onRetry: onRetry,
          );
        }
        return builder(snapshot.data!);
      },
    );
  }

  Widget _buildSectionStatus({
    required double height,
    required String message,
    required VoidCallback onRetry,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true,
      child: SizedBox(
        height: height,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, style: TextStyle(color: colors.onSurfaceVariant)),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToListScreen(
    BuildContext context,
    String title,
    List<Person> people,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ListViewScreen.people(title: title, people: people),
      ),
    );
  }

  Widget _buildHeroCarousel(List<Movie> movies) {
    if (movies.isEmpty) return const SizedBox();
    return CarouselSlider.builder(
      itemCount: min(movies.length, 5), // 상위 5개만
      itemBuilder: (context, index, realIndex) {
        final movie = movies[index];
        return GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie)),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AppNetworkImage(imageUrl: movie.fullBackdropUrl),
              // 그라데이션 오버레이
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.9),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        movie.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Text(
                      '인기',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      options: CarouselOptions(
        height: 250,
        viewportFraction: 1.0,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildApiConfigurationNotice() {
    final colors = Theme.of(context).colorScheme;
    final missing = <String>[
      if (!ApiSecrets.hasTmdbCredentials) 'TMDB',
      if (!ApiSecrets.hasKoficApiKey) 'KOFIC',
    ].join('·');
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.key_off_outlined, color: colors.onErrorContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$missing 연결 설정이 없습니다. config/api_keys.json에 발급 키를 입력하고 앱을 다시 시작해주세요.',
              style: TextStyle(color: colors.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieHorizontalList(
    BuildContext context, {
    required List<Movie> movies,
  }) {
    return SizedBox(
      height: 180.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MovieDetailScreen(movie: movie),
                ),
              ),
              child: SizedBox(
                width: 100.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: AppNetworkImage(
                          imageUrl: movie.fullPosterUrl,
                          width: double.infinity,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      movie.title,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : const Color(0xFF191919),
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUpcomingMoviesList(
    BuildContext context, {
    required List<Movie> movies,
  }) {
    return SizedBox(
      height: 180.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          int dDay = 0;
          try {
            if (movie.releaseDate.isNotEmpty) {
              final release = DateTime.parse(movie.releaseDate);
              dDay = ReleaseDateUtils.daysUntil(release);
            }
          } catch (_) {}

          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MovieDetailScreen(movie: movie),
                ),
              ),
              child: SizedBox(
                width: 100.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: AppNetworkImage(
                              imageUrl: movie.fullPosterUrl,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          if (dDay > 0)
                            Positioned(
                              top: 6,
                              left: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'D-$dDay',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      movie.title,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : const Color(0xFF191919),
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPersonHorizontalList(
    BuildContext context, {
    required List<Person> persons,
    bool isDirector = false,
  }) {
    return SizedBox(
      height: 140.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: persons.length,
        itemBuilder: (context, index) {
          final person = persons[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => isDirector
                        ? ArtistDetailScreen(
                            artistId: person.id,
                            artistName: person.displayName,
                            profileUrl: person.fullProfileUrl,
                          )
                        : ActorDetailScreen(actor: person),
                  ),
                );
              },
              child: SizedBox(
                width: 80,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40.0,
                      backgroundImage: person.fullProfileUrl.isNotEmpty
                          ? NetworkImage(person.fullProfileUrl)
                          : null,
                      backgroundColor: Colors.grey[800],
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      person.displayName,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : const Color(0xFF191919),
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
