import 'package:filmcock_app/data/services/api_service.dart';
import 'package:filmcock_app/presentation/screens/detail/actor_detail_screen.dart';
import 'package:filmcock_app/data/models/movie_model.dart';
import 'package:filmcock_app/presentation/widgets/watch_options_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late Future<Movie> movieDetail;
  late Future<List<Person>> movieCredits;
  late Future<List<Movie>> recommendedMovies;
  late Future<List<Video>> movieVideos;
  bool _isLiked = false;
  bool _isWatched = false;

  @override
  void initState() {
    super.initState();
    // API를 통해 상세 정보들을 가져옵니다.
    movieDetail = ApiService.getMovieDetail(widget.movie.id);
    movieCredits = ApiService.getMovieCredits(widget.movie.id);
    recommendedMovies = ApiService.getRecommendedMovies(widget.movie.id);
    movieVideos = ApiService.getMovieVideos(widget.movie.id);
    _loadLocalActions();
  }

  Future<void> _loadLocalActions() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _isLiked = prefs.getBool('liked_movie_${widget.movie.id}') ?? false;
      _isWatched = prefs.getBool('watched_movie_${widget.movie.id}') ?? false;
    });
  }

  Future<void> _toggleLocalAction({required bool liked}) async {
    final nextValue = liked ? !_isLiked : !_isWatched;
    setState(() {
      if (liked) {
        _isLiked = nextValue;
      } else {
        _isWatched = nextValue;
      }
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      '${liked ? 'liked' : 'watched'}_movie_${widget.movie.id}',
      nextValue,
    );
  }

  Future<void> _copyMovieLink() async {
    await Clipboard.setData(
      ClipboardData(
        text: 'https://www.themoviedb.org/movie/${widget.movie.id}',
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('영화 링크를 복사했습니다.')));
  }

  void _showCommentsNotice() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('댓글 기능을 준비 중입니다.')));
  }

  // 예고편 재생 다이얼로그
  void _playTrailer(String videoKey) {
    final controller = YoutubePlayerController(
      initialVideoId: videoKey,
      flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
    );

    showDialog(
      context: context,
      builder: (context) {
        return YoutubePlayerBuilder(
          player: YoutubePlayer(controller: controller),
          builder: (context, player) {
            return AlertDialog(
              backgroundColor: Colors.black,
              contentPadding: EdgeInsets.zero,
              content: player,
            );
          },
        );
      },
    ).whenComplete(() {
      // 다이얼로그가 닫힐 때 컨트롤러를 dispose 합니다.
      controller.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildInfoSection(),
            const SizedBox(height: 20),
            _buildCastSection(),
            const SizedBox(height: 20),
            _buildRecommendedSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // 1. 상단 헤더 (배경 이미지, 예고편 버튼, 제목)
  Widget _buildHeader() {
    return Stack(
      children: [
        // 배경 이미지
        SizedBox(
          height: 300,
          width: double.infinity,
          child: Image.network(
            widget.movie.fullBackdropUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                Container(color: Colors.grey[900]),
          ),
        ),
        // 그라데이션
        Container(
          height: 300,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
            ),
          ),
        ),
        // 예고편 재생 버튼
        Positioned.fill(
          child: FutureBuilder<List<Video>>(
            future: movieVideos,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return Center(
                  child: IconButton(
                    icon: const Icon(
                      Icons.play_circle_fill,
                      color: Colors.white,
                      size: 60,
                    ),
                    onPressed: () => _playTrailer(snapshot.data!.first.key),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        // 뒤로가기 버튼
        Positioned(
          top: 40,
          left: 10,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }

  // 2. 영화 정보 섹션 (포스터, 제목, 장르, 평점, 줄거리)
  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FutureBuilder<Movie>(
        future: movieDetail,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final detail = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                detail.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(_formatReleaseDate(detail.releaseDate)),
                  const SizedBox(width: 10),
                  Text('⭐️ ${detail.voteAverage.toStringAsFixed(1)}'),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                children: detail.genres
                    .map(
                      (genre) => Chip(
                        label: Text(genre.name),
                        backgroundColor: Colors.grey[800],
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => WatchOptionsSheet.show(
                    context,
                    movieId: detail.id,
                    movieTitle: detail.title,
                  ),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('보러가기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7656E8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActionButton(
                    icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                    label: '좋아요',
                    isSelected: _isLiked,
                    onPressed: () => _toggleLocalAction(liked: true),
                  ),
                  _buildActionButton(
                    icon: _isWatched
                        ? Icons.check_circle
                        : Icons.check_circle_outline,
                    label: '봤어요',
                    isSelected: _isWatched,
                    onPressed: () => _toggleLocalAction(liked: false),
                  ),
                  _buildActionButton(
                    icon: Icons.comment_outlined,
                    label: '댓글',
                    onPressed: _showCommentsNotice,
                  ),
                  _buildActionButton(
                    icon: Icons.share_outlined,
                    label: '공유',
                    onPressed: _copyMovieLink,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                '줄거리',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                detail.overview.isNotEmpty ? detail.overview : '줄거리 정보가 없습니다.',
                style: TextStyle(color: Colors.white.withOpacity(0.8)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isSelected = false,
  }) {
    final color = isSelected ? const Color(0xFF7656E8) : Colors.white70;
    return Expanded(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 5),
              Text(label, style: TextStyle(color: color, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  String _formatReleaseDate(String releaseDate) {
    if (releaseDate.length < 4) return '개봉일 정보 없음';
    return releaseDate.replaceAll('-', '. ');
  }

  // 3. 출연진 섹션
  Widget _buildCastSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            '주요 출연진',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 140,
          child: FutureBuilder<List<Person>>(
            future: movieCredits,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final cast = snapshot.data!;
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: cast.length,
                itemBuilder: (context, index) {
                  final person = cast[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ActorDetailScreen(actor: person),
                        ),
                      ),
                      child: SizedBox(
                        width: 80,
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: person.fullProfileUrl.isNotEmpty
                                  ? NetworkImage(person.fullProfileUrl)
                                  : null,
                              child: person.fullProfileUrl.isEmpty
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              person.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // 4. 추천 영화 섹션
  Widget _buildRecommendedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            '이런 영화는 어떠세요?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 180,
          child: FutureBuilder<List<Movie>>(
            future: recommendedMovies,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final movies = snapshot.data!;
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  final movie = movies[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: GestureDetector(
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MovieDetailScreen(movie: movie),
                        ),
                      ),
                      child: SizedBox(
                        width: 100,
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  movie.fullPosterUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              movie.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
