import 'package:filmcock_app/features/home/presentation/widgets/home_movie_strip.dart';
import 'package:filmcock_app/features/home/presentation/widgets/home_people_strip.dart';
import 'package:filmcock_app/features/home/data/upcoming_alert_repository.dart';
import 'package:filmcock_app/features/home/presentation/widgets/home_hero_carousel.dart';
import 'package:filmcock_app/features/home/presentation/widgets/upcoming_movie_dialog.dart';
import 'package:filmcock_app/app/dependencies/app_dependencies.dart';
import 'package:filmcock_app/features/chat/presentation/screens/chat_screen.dart';
import 'package:filmcock_app/core/theme/theme_controller.dart';

import 'package:flutter/material.dart';
import 'package:filmcock_app/features/home/data/home_prefetch_service.dart';
import 'package:filmcock_app/features/preferences/application/preference_change_service.dart';
import 'package:filmcock_app/features/recommendations/domain/daily_recommendation_service.dart';
import 'package:filmcock_app/features/profile/application/notification_settings_service.dart';
import 'package:filmcock_app/features/recommendations/application/personalized_recommendation_service.dart';
import 'package:filmcock_app/features/preferences/data/user_settings_repository.dart';
import 'package:filmcock_app/core/config/secrets.dart';
import 'package:filmcock_app/core/errors/app_exception.dart';
import 'package:filmcock_app/shared/presentation/widgets/section_header.dart';
import 'package:filmcock_app/shared/presentation/widgets/app_loading_indicator.dart';
import 'package:filmcock_app/features/home/presentation/widgets/home_external_sections.dart';
import 'package:filmcock_app/features/home/application/home_controller.dart';
import 'package:filmcock_app/features/home/presentation/screens/list_view_screen.dart';
import 'package:filmcock_app/features/movie_detail/presentation/screens/movie_detail_screen.dart';
import 'package:filmcock_app/features/person_detail/presentation/screens/actor_detail_screen.dart';
import 'package:filmcock_app/features/person_detail/presentation/screens/artist_detail_screen.dart';
import 'package:filmcock_app/shared/domain/models/catalog_models.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final UserSettingsRepository _settingsRepository =
      const UserSettingsRepository();

  final UpcomingAlertRepository _upcomingAlerts =
      const UpcomingAlertRepository();

  bool _checkingUpcomingAlert = false;

  Future<void> _checkAndShowUpcomingAlert() async {
    if (_checkingUpcomingAlert) return;
    _checkingUpcomingAlert = true;
    try {
      final movies = await upcomingMovies;
      if (!mounted) return;
      final alert = await _upcomingAlerts.prepare(movies);
      if (mounted && alert != null) {
        showUpcomingMovieDialog(context, alert.movie, alert.dDayText);
      }
    } catch (_) {
      // 알림 준비 실패는 다른 홈 섹션에 영향을 주지 않는다.
    } finally {
      _checkingUpcomingAlert = false;
    }
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
    final preferences = await _settingsRepository.loadPreferences();
    final savedMbti = preferences.mbti;
    final genres = preferences.genres;
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
      catalog: AppDependencies.catalog,
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
                builder: (movies) => HomeHeroCarousel(movies: movies),
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

  void _openMovie(Movie movie) => Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie)));

  Widget _buildMovieHorizontalList(
    BuildContext context, {
    required List<Movie> movies,
  }) => HomeMovieStrip(movies: movies, onMovieTap: _openMovie);
  Widget _buildUpcomingMoviesList(
    BuildContext context, {
    required List<Movie> movies,
  }) => HomeMovieStrip(movies: movies, upcoming: true, onMovieTap: _openMovie);
  Widget _buildPersonHorizontalList(
    BuildContext context, {
    required List<Person> persons,
    bool isDirector = false,
  }) => HomePeopleStrip(
    persons: persons,
    onPersonTap: (person) => Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => isDirector
            ? ArtistDetailScreen(
                artistId: person.id,
                artistName: person.displayName,
                profileUrl: person.fullProfileUrl,
              )
            : ActorDetailScreen(actor: person),
      ),
    ),
  );
}
