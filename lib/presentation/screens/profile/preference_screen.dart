import 'package:filmcock_app/data/services/api_service.dart';
import 'package:filmcock_app/presentation/screens/detail/movie_detail_screen.dart';
import 'package:filmcock_app/data/models/movie_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:filmcock_app/presentation/screens/onboarding/mbti_select_screen.dart';

class PreferenceScreen extends StatefulWidget {
  const PreferenceScreen({super.key});

  @override
  State<PreferenceScreen> createState() => _PreferenceScreenState();
}

class _PreferenceScreenState extends State<PreferenceScreen> {
  Future<List<Movie>>? recommendedMovies;
  String? _userMbti;

  // MBTI와 TMDB 장르 ID 매핑
  static const Map<String, int> mbtiGenreMap = {
    'ESTP': 28, // 액션
    'ESFP': 35, // 코미디
    'ISTP': 878, // SF
    'ISFP': 10749, // 로맨스
    'ENTJ': 12, // 어드벤처
    'ENTP': 9648, // 미스터리
    'INTJ': 18, // 드라마
    'INTP': 99, // 다큐멘터리
    'ESTJ': 80, // 범죄
    'ESFJ': 10751, // 가족
    'ISTJ': 36, // 역사
    'ISFJ': 18, // 드라마
    'ENFJ': 10749, // 로맨스
    'ENFP': 14, // 판타지
    'INFJ': 18, // 드라마
    'INFP': 16, // 애니메이션
  };

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedMbti = prefs.getString('user_mbti');
    _userMbti = savedMbti;

    int genreId;

    if (savedMbti != null &&
        savedMbti != 'skipped' &&
        mbtiGenreMap.containsKey(savedMbti)) {
      genreId = mbtiGenreMap[savedMbti]!;
    } else {
      // MBTI가 없거나 건너뛴 경우, 인기 영화를 추천
      setState(() {
        recommendedMovies = ApiService.getPopularMovies();
      });
      return;
    }

    setState(() {
      recommendedMovies = ApiService.getMoviesByGenre(genreId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_buildHeader(context), _buildMovieGrid()],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF4EE3CE), Color(0xFF55C75A)],
            ).createShader(bounds),
            child: Text(
              '당신의 취향저격! ${_userMbti ?? ''}',
              style: const TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                color: Colors.white, // ShaderMask를 위해 기본 색상 필요
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MbtiSelectScreen(),
                ),
              );
              // MBTI 선택 화면에서 돌아온 후, 추천 목록을 새로고침합니다.
              _loadRecommendations();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 5.0,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFA500),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'mbti 재설정',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieGrid() {
    return FutureBuilder<List<Movie>>(
      future: recommendedMovies,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('추천 영화가 없습니다.'));
        }

        final movies = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: movies.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              childAspectRatio: 0.65,
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
                        fontSize: 14.0,
                      ),
                      maxLines: 2,
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
