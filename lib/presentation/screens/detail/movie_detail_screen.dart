import 'dart:convert';
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
    final prefs = await SharedPreferences.getInstance();
    final nextValue = liked ? !_isLiked : !_isWatched;

    setState(() {
      if (liked) {
        _isLiked = nextValue;
      } else {
        _isWatched = nextValue;
      }
    });

    await prefs.setBool(
      '${liked ? 'liked' : 'watched'}_movie_${widget.movie.id}',
      nextValue,
    );

    // 1. Maintain global list in SharedPreferences for MyPage
    final listKey = liked ? 'liked_movies_data' : 'watched_movies_data';
    final rawList = prefs.getStringList(listKey) ?? [];
    List<Map<String, dynamic>> movies = rawList.map((e) {
      try {
        return jsonDecode(e) as Map<String, dynamic>;
      } catch (_) {
        return <String, dynamic>{};
      }
    }).where((m) => m.isNotEmpty).toList();

    movies.removeWhere((m) => m['id'].toString() == widget.movie.id.toString());
    if (nextValue) {
      movies.insert(0, {
        'id': widget.movie.id,
        'title': widget.movie.title,
        'posterPath': widget.movie.posterPath,
        'voteAverage': widget.movie.voteAverage,
      });
    }
    await prefs.setStringList(
      listKey,
      movies.map((e) => jsonEncode(e)).toList(),
    );

    // 2. Maintain calendar_movies_data for Calendar
    if (!liked) {
      final calRaw = prefs.getString('calendar_movies_data');
      Map<String, dynamic> calMap = {};
      if (calRaw != null && calRaw.isNotEmpty) {
        try {
          calMap = jsonDecode(calRaw) as Map<String, dynamic>;
        } catch (_) {}
      }

      final now = DateTime.now();
      final todayKey =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      List<dynamic> todayList = calMap[todayKey] != null
          ? List<dynamic>.from(calMap[todayKey])
          : [];

      todayList.removeWhere((item) =>
          item is Map && item['id'].toString() == widget.movie.id.toString());

      if (nextValue) {
        todayList.add({
          'id': widget.movie.id,
          'title': widget.movie.title,
          'posterPath': widget.movie.posterPath,
          'addedAt': now.toIso8601String(),
        });
        calMap[todayKey] = todayList;
        await prefs.setString('calendar_movies_data', jsonEncode(calMap));

        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: const Color(0xFF222226),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                '캘린더에 추가되었습니다.',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              content: Text(
                '\'${widget.movie.title}\'이(가) 오늘 캘린더에 성공적으로 등록되었습니다.',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    '확인',
                    style: TextStyle(
                      color: Color(0xFFA88BFA),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      } else {
        calMap[todayKey] = todayList;
        await prefs.setString('calendar_movies_data', jsonEncode(calMap));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('관람 내역에서 삭제되었습니다.'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
    } else {
      if (mounted) {
        final msg = nextValue ? '내가 추천한 띵작에 추가되었습니다.' : '추천한 띵작에서 삭제되었습니다.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), duration: const Duration(seconds: 1)),
        );
      }
    }
  }

  Future<void> _copyMovieLink() async {
    await Clipboard.setData(
      ClipboardData(
        text: 'https://www.themoviedb.org/movie/${widget.movie.id}',
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('영화 링크가 복사되었습니다.')),
    );
  }

  void _showCommentBottomSheet() {
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF222222),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '댓글 작성',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                widget.movie.title,
                style: TextStyle(color: Colors.grey[400], fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                decoration: InputDecoration(
                  hintText: '이 영화에 대한 감상평을 솔직하게 남겨보세요!',
                  hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                  filled: true,
                  fillColor: const Color(0xFF2E2E30),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    final text = commentController.text.trim();
                    if (text.isEmpty) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('댓글 내용을 입력해주세요.')),
                      );
                      return;
                    }

                    final prefs = await SharedPreferences.getInstance();
                    final rawComments = prefs.getStringList('user_comments') ?? [];
                    final now = DateTime.now();
                    final dateStr =
                        '${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}';

                    final newCommentObj = {
                      'movieId': widget.movie.id,
                      'movieTitle': widget.movie.title,
                      'posterPath': widget.movie.posterPath,
                      'content': text,
                      'date': dateStr,
                    };

                    rawComments.insert(0, jsonEncode(newCommentObj));
                    await prefs.setStringList('user_comments', rawComments);

                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                    }
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('댓글이 등록되었습니다! 마이페이지에 반영됩니다.')),
                      );
                    }
                  },
                  child: const Text(
                    '등록하기',
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
        );
      },
    );
  }

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
      controller.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
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

  Widget _buildHeader() {
    return Stack(
      children: [
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
        Container(
          height: 300,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
            ),
          ),
        ),
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
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    _formatReleaseDate(detail.releaseDate),
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '⭐️ ${detail.voteAverage.toStringAsFixed(1)}',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                children: detail.genres
                    .map(
                      (genre) => Chip(
                        label: Text(
                          genre.name,
                          style: const TextStyle(color: Colors.white),
                        ),
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
                  icon: const Icon(Icons.play_arrow),
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
                    onPressed: _showCommentBottomSheet,
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
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                detail.overview.isNotEmpty ? detail.overview : '줄거리 정보가 없습니다.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  height: 1.5,
                ),
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

  Widget _buildCastSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            '주요 출연진',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
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
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
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

  Widget _buildRecommendedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            '이런 영화는 어떠세요?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
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
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
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
