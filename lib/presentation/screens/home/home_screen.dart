import 'dart:math';
import 'package:flutter/material.dart';
import 'package:filmcock_app/data/services/api_service.dart';
import 'package:filmcock_app/presentation/widgets/section_header.dart';
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

class _HomeScreenState extends State<HomeScreen> {
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

  @override
  void initState() {
    super.initState();
    _loadMbti();

    // API 데이터 Fetch
    popularMovies = ApiService.getPopularMovies();
    randomMovies = _loadRandomMovies(); // 임시로 Popular + Shuffle 사용
    upcomingMovies = ApiService.getUpcomingMovies();
    nowPlayingMovies = ApiService.getNowPlayingMovies();
    animationMovies = ApiService.getMoviesByGenre(16); // 애니메이션
    topRatedMovies = ApiService.getClassicMovies();

    // 인물 데이터 Fetch
    _loadKoficPeople();
    popularForeignActors =
        ApiService.getPopularPeople(); // 해외 배우 (TMDB 인기 인물 기반)
  }

  Future<void> _loadMbti() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userMbti = prefs.getString('user_mbti') ?? '추천영화';
    });
  }

  Future<List<Movie>> _loadRandomMovies() async {
    final movies = await ApiService.getPopularMovies();
    movies.shuffle(Random());
    return movies;
  }

  void _loadKoficPeople() async {
    // KOFIC API를 통해 한국 배우와 감독 목록 추출
    try {
      final peopleMap = await ApiService.getPopularPeopleFromKofic();
      if (mounted) {
        setState(() {
          popularKoreanActors = Future.value(peopleMap['actors']);
          popularKoreanDirectors = Future.value(peopleMap['directors']);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          popularKoreanActors = Future.value([]);
          popularKoreanDirectors = Future.value([]);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2E), // 배경 다크 테마 컬러 통일
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF1E1E2E),
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/1.png', height: 32),
            const SizedBox(width: 8),
            const Text(
              'FilmCOCK!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.nightlight_round, color: Colors.white),
            onPressed: () {
              // 다크/라이트 토글 - 아직 기능 없음
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 말풍선 채팅 기능
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
                  if (!mounted) return;
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
                  if (!mounted) return;
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
                  if (!mounted) return;
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
                  if (!mounted) return;
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
                  if (!mounted) return;
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
                onTap: () {
                  popularKoreanActors?.then((actors) {
                    if (actors.isNotEmpty)
                      _navigateToListScreen(context, '한국 배우', actors);
                  });
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
                onTap: () {
                  popularForeignActors.then((actors) {
                    if (actors.isNotEmpty)
                      _navigateToListScreen(context, '해외 배우', actors);
                  });
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
                onTap: () {
                  popularKoreanDirectors?.then((directors) {
                    if (directors.isNotEmpty)
                      _navigateToListScreen(context, '유명 감독', directors);
                  });
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
                    colors: [Colors.black.withOpacity(0.9), Colors.transparent],
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
          } catch (e) {}

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

  Widget _buildReviewChannelList() {
    final channels = [
      {'name': '지무비', 'color': Colors.amber},
      {'name': '고몽', 'color': Colors.blue},
      {'name': '김시선', 'color': Colors.green},
      {'name': '달빛뮤즈', 'color': Colors.purple},
    ];

    return SizedBox(
      height: 120.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: channels.length,
        itemBuilder: (context, index) {
          final channel = channels[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('리뷰 영상은 준비 중입니다.')),
                );
              },
              child: SizedBox(
                width: 90.0,
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: Container(
                          width: double.infinity,
                          color: channel['color'] as Color,
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
                      channel['name'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.0,
                      ),
                      maxLines: 1,
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
