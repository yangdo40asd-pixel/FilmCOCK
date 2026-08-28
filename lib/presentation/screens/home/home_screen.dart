import 'package:flutter/material.dart';
import 'package:filmcock_app/data/services/api_service.dart';
import 'package:filmcock_app/presentation/widgets/section_header.dart';
import 'package:filmcock_app/presentation/screens/home/list_view_screen.dart';
import 'package:filmcock_app/presentation/screens/detail/movie_detail_screen.dart';
import 'package:filmcock_app/presentation/screens/detail/actor_detail_screen.dart';
import 'package:filmcock_app/data/models/movie_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // API로부터 받아온 영화 목록을 저장할 Future 변수들
  late Future<List<Movie>> nowPlayingMovies;
  late Future<List<Movie>> popularMovies;
  Future<List<Person>>? popularActors;
  Future<List<Person>>? popularDirectors;

  @override
  void initState() {
    super.initState();
    // TMDB API 호출
    nowPlayingMovies = ApiService.getNowPlayingMovies();
    popularMovies = ApiService.getPopularMovies();

    // KOFIC API를 호출하여 인기 배우 및 감독 목록 설정
    _loadKoficPeople();
  }

  void _loadKoficPeople() async {
    // KOFIC API를 통해 배우와 감독 목록을 한 번에 가져옵니다.
    final peopleMap = await ApiService.getPopularPeopleFromKofic();
    // Future.value를 사용하여 이미 완료된 데이터를 Future 형태로 변환합니다.
    setState(() {
      popularActors = Future.value(peopleMap['actors']);
      popularDirectors = Future.value(peopleMap['directors']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF303030),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // A. 1. 급상승 콘텐츠 섹션 (배너)
              // '인기 영화' 목록을 배너로 활용
              _buildMovieSection(
                future: popularMovies,
                builder: (movies) =>
                    _buildTrendingBanner(context, movies.first),
              ),

              // B. 2. 최신 상영 영화 섹션
              const SizedBox(height: 25.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SectionHeader(
                  title: '최신 상영 영화',
                  emoji: '🎥',
                  onTap: () {}, // TODO: 목록 보기 페이지 구현
                ),
              ),
              const SizedBox(height: 10.0),
              _buildMovieSection(
                future: nowPlayingMovies,
                builder: (movies) =>
                    _buildMovieHorizontalList(context, movies: movies),
              ),

              // C. 3. 추천 영화 섹션
              const SizedBox(height: 25.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SectionHeader(
                  title: '추천 영화',
                  emoji: '🍿',
                  onTap: () {}, // TODO: 목록 보기 페이지 구현
                ),
              ),
              const SizedBox(height: 10.0),
              _buildMovieSection(
                future: popularMovies,
                builder: (movies) =>
                    _buildMovieHorizontalList(context, movies: movies),
              ),

              // D. 4. 인기 배우 섹션
              const SizedBox(height: 25.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SectionHeader(
                  title: '인기 배우',
                  emoji: '✨',
                  onTap: () {
                    popularActors?.then((actors) {
                      if (actors.isNotEmpty) {
                        _navigateToListScreen(context, '인기 배우', actors);
                      }
                    });
                  },
                ),
              ),
              const SizedBox(height: 10.0),
              _buildPersonSection(
                future: popularActors ?? Future.value([]), // null일 경우 빈 Future
                builder: (persons) =>
                    _buildPersonHorizontalList(context, persons: persons),
              ),

              // E. 5. 유명 감독 섹션
              const SizedBox(height: 25.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SectionHeader(
                  title: '유명 감독',
                  emoji: '🎥🧑‍💻',
                  onTap: () {
                    popularDirectors?.then((directors) {
                      _navigateToListScreen(context, '유명 감독', directors);
                    });
                  },
                ),
              ),
              const SizedBox(height: 10.0),
              _buildPersonSection(
                future:
                    popularDirectors ?? Future.value([]), // null일 경우 빈 Future
                builder: (persons) =>
                    _buildPersonHorizontalList(context, persons: persons),
              ),

              // F. 6. 리뷰 채널 섹션
              const SizedBox(height: 25.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SectionHeader(title: '리뷰 채널', emoji: '⭐', onTap: () {}),
              ),
              const SizedBox(height: 10.0),
              _buildReviewChannelList(),

              // G. 7. 고전 명작 섹션
              const SizedBox(height: 25.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SectionHeader(
                  title: '고전 명작',
                  emoji: '👍',
                  onTap: () {}, // TODO: 목록 보기 페이지 구현
                ),
              ),
              const SizedBox(height: 10.0),
              _buildMovieSection(
                future: popularMovies, // 임시로 인기 영화 사용
                builder: (movies) => _buildMovieHorizontalList(
                  context,
                  movies: movies.reversed.toList(),
                ),
              ),

              // 하단 여백
              const SizedBox(height: 40.0),
            ],
          ),
        ),
      ),
    );
  }

  // API 데이터를 기다리고, 데이터가 오면 UI를 그리는 범용 위젯
  Widget _buildMovieSection({
    required Future<List<Movie>> future,
    required Widget Function(List<Movie>) builder,
  }) {
    return FutureBuilder<List<Movie>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('데이터를 불러오는 데 실패했습니다: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          return builder(snapshot.data!);
        }
        return const SizedBox.shrink();
      },
    );
  }

  // 인물 데이터를 기다리고, 데이터가 오면 UI를 그리는 범용 위젯
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
            child: Center(child: Text('인물 정보를 불러올 수 없습니다.')),
          );
        }
        return builder(snapshot.data!);
      },
    );
  }

  // 목록 화면으로 이동하는 헬퍼 함수
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

  // A. 급상승 콘텐츠 배너 위젯
  Widget _buildTrendingBanner(BuildContext context, Movie movie) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie)),
          );
        },
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              movie.fullBackdropUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: Colors.grey[800]),
            ),
          ),
        ),
      ),
    );
  }

  // B, C, G. 영화 수평 목록 위젯
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
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MovieDetailScreen(movie: movie),
                  ),
                );
              },
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

  // D, E. 인물(배우/감독) 수평 목록 위젯
  Widget _buildPersonHorizontalList(
    BuildContext context, {
    required List<Person> persons,
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
                // ActorDetailScreen으로 이동하여 수작업으로 정리된 대표작 목록을 보여줍니다.
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ActorDetailScreen(actor: person),
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
                      person.name,
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

  // F. 리뷰 채널 수평 목록 위젯
  Widget _buildReviewChannelList() {
    return SizedBox(
      height: 100.0, // 더미데이터를 사용하므로 이 부분은 그대로 둡니다.
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: 5, // 예시로 5개만 표시
        itemBuilder: (context, index) {
          // final channel = dummyChannels[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () {
                // 채널 이동
              },
              child: SizedBox(
                width: 100.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Container(color: Colors.grey[700]), // 임시 UI
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
