import 'package:filmcock_app/presentation/screens/chat/chat_screen.dart';
import 'package:filmcock_app/core/theme/theme_controller.dart';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:filmcock_app/data/services/home_prefetch_service.dart';
import 'package:filmcock_app/presentation/widgets/section_header.dart';
import 'package:filmcock_app/presentation/screens/home/list_view_screen.dart';
import 'package:filmcock_app/presentation/screens/detail/movie_detail_screen.dart';
import 'package:filmcock_app/presentation/screens/detail/actor_detail_screen.dart';
import 'package:filmcock_app/presentation/screens/detail/artist_detail_screen.dart';
import 'package:filmcock_app/data/models/movie_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static bool _hasShownUpcomingAlert = false;

  Future<void> _checkAndShowUpcomingAlert() async {
    if (_hasShownUpcomingAlert) return;
    _hasShownUpcomingAlert = true;

    final prefs = await SharedPreferences.getInstance();
    final allPush = prefs.getBool('setting_all_push') ?? true;
    final upcomingAlarm =
        prefs.getBool('setting_upcoming_movie_alarm') ?? true;
    if (!allPush || !upcomingAlarm) return;

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
          final now = DateTime.now();
          final diff = DateTime(release.year, release.month, release.day)
              .difference(DateTime(now.year, now.month, now.day))
              .inDays;
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
      _showUpcomingDialog(movie, dDayText);
    } catch (_) {}
  }

  void _showUpcomingDialog(Movie movie, String dDayText) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          backgroundColor: const Color(0xFF222226),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
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
                const Text(
                  '곧 개봉해요!',
                  style: TextStyle(
                    color: Colors.white,
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
                    child: movie.fullPosterUrl.isNotEmpty
                        ? Image.network(
                            movie.fullPosterUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(
                              color: Colors.grey[800],
                              child: const Icon(
                                Icons.movie,
                                color: Colors.white54,
                                size: 40,
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.grey[800],
                            child: const Icon(
                              Icons.movie,
                              color: Colors.white54,
                              size: 40,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Movie Title
                Text(
                  movie.title,
                  style: const TextStyle(
                    color: Colors.white,
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
                        child: const Text(
                          '닫기',
                          style: TextStyle(
                            color: Colors.white70,
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

  // 배너 및 일반 영화
  late Future<List<Movie>> popularMovies;
  late Future<List<Movie>> randomMovies;
  late Future<List<Movie>> upcomingMovies;
  late Future<List<Movie>> nowPlayingMovies;
  late Future<List<Movie>> animationMovies;
  late Future<List<Movie>> topRatedMovies;

  // 인물
  Future<List<Person>>? popularKoreanActors;
  late Future<List<Person>> popularForeignActors;
  Future<List<Person>>? popularKoreanDirectors;

  String _userMbti = '추천영화'; // 기본값
  bool _isHomeReady = false;

  @override
  void initState() {
    super.initState();
    final cachedData = HomePrefetchService.cachedData;
    if (cachedData != null) {
      _applyHomeData(cachedData);
      _isHomeReady = true;
      _loadMbti();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkAndShowUpcomingAlert();
      });
    } else {
      _prepareHome();
    }
  }

  Future<void> _prepareHome() async {
    try {
      final data = await HomePrefetchService.load();
      _applyHomeData(data);
      final prefs = await SharedPreferences.getInstance();
      _userMbti = prefs.getString('user_mbti') ?? '추천영화';
    } catch (_) {
      popularMovies = Future.value(const []);
      randomMovies = Future.value(const []);
      upcomingMovies = Future.value(const []);
      nowPlayingMovies = Future.value(const []);
      animationMovies = Future.value(const []);
      topRatedMovies = Future.value(const []);
      popularForeignActors = Future.value(const []);
      popularKoreanActors = Future.value(const []);
      popularKoreanDirectors = Future.value(const []);
    } finally {
      if (mounted) {
        setState(() => _isHomeReady = true);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _checkAndShowUpcomingAlert();
        });
      }
    }
  }

  void _applyHomeData(HomePrefetchData data) {
    popularMovies = Future.value(data.popularMovies);
    randomMovies = Future.value(data.randomMovies);
    upcomingMovies = Future.value(data.upcomingMovies);
    nowPlayingMovies = Future.value(data.nowPlayingMovies);
    animationMovies = Future.value(data.animationMovies);
    topRatedMovies = Future.value(data.classicMovies);
    popularForeignActors = Future.value(data.foreignActors);
    popularKoreanActors = Future.value(data.koreanActors);
    popularKoreanDirectors = Future.value(data.koreanDirectors);
  }

  Future<void> _loadMbti() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _userMbti = prefs.getString('user_mbti') ?? '추천영화');
  }

  @override
  Widget build(BuildContext context) {
    if (!_isHomeReady) {
      return const Scaffold(
        backgroundColor: Color(0xFF1E1E2E),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF7F7FA);
    final titleColor = isDark ? Colors.white : const Color(0xFF191919);

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
                  isCurrentDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ChatScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF8B5CF6),
        child: const Icon(Icons.chat_bubble, color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 2. 자동 교체 스크린 (Hero Banner)
            _buildMovieSection(
              future: popularMovies,
              builder: (movies) => _buildHeroCarousel(movies),
            ),
            const SizedBox(height: 24.0),

            // 3. 오늘의 랜덤 추천 영화 🍿
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SectionHeader(
                title:
                    (_userMbti == 'NONE' ||
                        _userMbti.isEmpty ||
                        _userMbti == 'skipped' ||
                        _userMbti == '추천영화')
                    ? '오늘의 랜덤 추천 영화'
                    : '오늘의 추천 영화 ($_userMbti)',
                emoji: '🍿',
                onTap: () async {
                  final movies = await randomMovies;
                  if (!context.mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ListViewScreen(title: '오늘의 랜덤 추천 영화', items: movies),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12.0),
            _buildMovieSection(
              future: randomMovies,
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
                      builder: (_) =>
                          ListViewScreen(title: '방영 예정일 영화', items: movies),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12.0),
            _buildMovieSection(
              future: upcomingMovies,
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
                      builder: (_) =>
                          ListViewScreen(title: '최신 상영 영화', items: movies),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12.0),
            _buildMovieSection(
              future: nowPlayingMovies,
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
                      builder: (_) =>
                          ListViewScreen(title: '애니메이션', items: movies),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12.0),
            _buildMovieSection(
              future: animationMovies,
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
                      builder: (_) =>
                          ListViewScreen(title: '고전 명작', items: movies),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12.0),
            _buildMovieSection(
              future: topRatedMovies,
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
              child: SectionHeader(
                title: '리뷰 채널',
                emoji: '🎤',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('리뷰 채널 목록은 준비 중입니다.')),
                  );
                },
              ),
            ),
            const SizedBox(height: 12.0),
            _buildReviewChannelList(),
            const SizedBox(height: 20.0),
            _buildKoficBanner(context),

            const SizedBox(height: 40.0),
          ],
        ),
      ),
    );
  }

  // --- 헬퍼 및 UI 빌더 메서드들 ---

  Widget _buildMovieSection({
    required Future<List<Movie>> future,
    required Widget Function(List<Movie>) builder,
  }) {
    return FutureBuilder<List<Movie>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 180,
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data!.isEmpty) {
          return const SizedBox(
            height: 180,
            child: Center(
              child: Text('데이터 없음', style: TextStyle(color: Colors.white54)),
            ),
          );
        }
        return builder(snapshot.data!);
      },
    );
  }

  Widget _buildPersonSection({
    required Future<List<Person>> future,
    required Widget Function(List<Person>) builder,
  }) {
    return FutureBuilder<List<Person>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 140,
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data!.isEmpty) {
          return const SizedBox(
            height: 140,
            child: Center(
              child: Text('인물 정보 없음', style: TextStyle(color: Colors.white54)),
            ),
          );
        }
        return builder(snapshot.data!);
      },
    );
  }

  void _navigateToListScreen(
    BuildContext context,
    String title,
    List<dynamic> items,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ListViewScreen(title: title, items: items),
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
              Image.network(
                movie.fullBackdropUrl,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(color: Colors.grey),
              ),
              // 그라데이션 오버레이
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withValues(alpha: 0.9), Colors.transparent],
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
                        child: Image.network(
                          movie.fullPosterUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(color: Colors.grey[800]),
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
              dDay = release.difference(DateTime.now()).inDays;
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
                            child: Image.network(
                              movie.fullPosterUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(color: Colors.grey[800]),
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

  Widget _buildReviewChannelList() {
    final channels = [
      ReviewChannel(
        name: '단군',
        logoAsset: 'assets/images/dangun.png',
        youtubeUrl: 'https://www.youtube.com/@kimdangun',
      ),
      ReviewChannel(
        name: '리뷰마스터',
        logoAsset: 'assets/images/review_master.jpg',
        youtubeUrl: 'https://www.youtube.com/@review.master',
      ),
      ReviewChannel(
        name: '지무비',
        logoAsset: 'assets/images/gmovie.webp',
        youtubeUrl: 'https://www.youtube.com/@gmovie',
      ),
      ReviewChannel(
        name: '고몽',
        logoAsset: 'assets/images/gomong.png',
        youtubeUrl: 'https://www.youtube.com/@gomong',
      ),
      ReviewChannel(
        name: '김시선',
        logoAsset: 'assets/images/siseon.webp',
        youtubeUrl: 'https://www.youtube.com/@siseon',
      ),
      ReviewChannel(
        name: '달빛뮤즈',
        logoAsset: 'assets/images/moonlightmuse.webp',
        youtubeUrl: 'https://www.youtube.com/@moonlightmuse',
      ),
      ReviewChannel(
        name: '삐맨',
        logoAsset: 'assets/images/bman.webp',
        youtubeUrl: 'https://www.youtube.com/@BMan',
      ),
    ];

    final fallbackColors = [
      Colors.deepOrange,
      Colors.amber,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.teal,
    ];

    return SizedBox(
      height: 120.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: channels.length,
        itemBuilder: (context, index) {
          final channel = channels[index];
          final fallbackColor = fallbackColors[index % fallbackColors.length];

          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () async {
                if (channel.youtubeUrl.isNotEmpty) {
                  final uri = Uri.parse(channel.youtubeUrl);
                  try {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } catch (_) {
                    await launchUrl(uri, mode: LaunchMode.platformDefault);
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('리뷰 채널 링크를 준비 중입니다.')),
                  );
                }
              },
              child: SizedBox(
                width: 90.0,
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: channel.logoAsset != null
                            ? Image.asset(
                                channel.logoAsset!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  width: double.infinity,
                                  color: fallbackColor,
                                  child: const Center(
                                    child: Icon(
                                      Icons.play_circle_fill,
                                      size: 40,
                                      color: Colors.white54,
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                width: double.infinity,
                                color: fallbackColor,
                                child: const Center(
                                  child: Icon(
                                    Icons.play_circle_fill,
                                    size: 40,
                                    color: Colors.white54,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      channel.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.0,
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

  Widget _buildKoficBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: InkWell(
        onTap: () async {
          final uri = Uri.parse('https://www.kobis.or.kr');
          try {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } catch (_) {
            await launchUrl(uri, mode: LaunchMode.platformDefault);
          }
        },
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF282932)
                : Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            border: Theme.of(context).brightness == Brightness.dark
                ? Border.all(color: Colors.white12)
                : Border.all(color: Colors.black12),
          ),
          child: Row(
            children: [
              // 영화 슬레이트 아이콘
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: const Center(
                  child: Icon(
                    Icons.movie_creation_outlined,
                    color: Colors.white70,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 14.0),
              // 중앙 KOFIC 및 영화진흥위원회 텍스트
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'KOFIC',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      '영화진흥위원회',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 13.0,
                      ),
                    ),
                  ],
                ),
              ),
              // 우측 보라색 버튼
              // 외부 링크 안내 아이콘
              const Icon(
                Icons.open_in_new_rounded,
                color: Colors.white54,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

}
