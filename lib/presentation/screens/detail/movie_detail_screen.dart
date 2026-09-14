import 'package:filmcock_app/data/services/api_service.dart';
import 'package:filmcock_app/data/repositories/activity_repository.dart';
import 'package:filmcock_app/data/repositories/calendar_repository.dart';
import 'package:filmcock_app/presentation/screens/detail/actor_detail_screen.dart';
import 'package:filmcock_app/data/models/movie_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:filmcock_app/presentation/widgets/app_network_image.dart';
import 'package:filmcock_app/presentation/widgets/movie_info_section.dart';
import 'package:filmcock_app/presentation/widgets/app_loading_indicator.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final ActivityRepository _activityRepository = const ActivityRepository();
  final CalendarRepository _calendarRepository = const CalendarRepository();
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
    final states = await Future.wait([
      _activityRepository.isMovieLiked(widget.movie.id),
      _activityRepository.isMovieWatched(widget.movie.id),
    ]);
    if (!mounted) return;
    setState(() {
      _isLiked = states[0];
      _isWatched = states[1];
    });
  }

  Future<void> _toggleLocalAction({required bool liked}) async {
    final previousValue = liked ? _isLiked : _isWatched;
    final nextValue = liked ? !_isLiked : !_isWatched;
    List<Map<String, dynamic>>? previousMovies;

    setState(() {
      if (liked) {
        _isLiked = nextValue;
      } else {
        _isWatched = nextValue;
      }
    });

    try {
      if (liked) {
        await _activityRepository.setMovieLiked(widget.movie.id, nextValue);
      } else {
        await _activityRepository.setMovieWatched(widget.movie.id, nextValue);
      }

      // 1. Maintain global list in SharedPreferences for MyPage
      final movies = liked
          ? await _activityRepository.likedMovies()
          : await _activityRepository.watchedMovies();
      previousMovies = List<Map<String, dynamic>>.from(movies);

      movies.removeWhere(
        (m) => m['id'].toString() == widget.movie.id.toString(),
      );
      if (nextValue) {
        movies.insert(0, {
          'id': widget.movie.id,
          'title': widget.movie.title,
          'posterPath': widget.movie.posterPath,
          'voteAverage': widget.movie.voteAverage,
        });
      }
      if (liked) {
        await _activityRepository.saveLikedMovies(movies);
      } else {
        await _activityRepository.saveWatchedMovies(movies);
      }

      // 2. Maintain calendar_movies_data for Calendar
      if (!liked) {
        final calMap = await _calendarRepository.load();

        final now = DateTime.now();
        final todayKey =
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

        List<dynamic> todayList = calMap[todayKey] != null
            ? List<dynamic>.from(calMap[todayKey])
            : [];

        todayList.removeWhere(
          (item) =>
              item is Map &&
              item['id'].toString() == widget.movie.id.toString(),
        );

        if (nextValue) {
          todayList.add({
            'id': widget.movie.id,
            'title': widget.movie.title,
            'posterPath': widget.movie.posterPath,
            'addedAt': now.toIso8601String(),
          });
          calMap[todayKey] = todayList;
          await _calendarRepository.save(calMap);

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
          await _calendarRepository.save(calMap);
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
    } catch (_) {
      try {
        if (liked) {
          await _activityRepository.setMovieLiked(
            widget.movie.id,
            previousValue,
          );
          if (previousMovies != null) {
            await _activityRepository.saveLikedMovies(previousMovies);
          }
        } else {
          await _activityRepository.setMovieWatched(
            widget.movie.id,
            previousValue,
          );
          if (previousMovies != null) {
            await _activityRepository.saveWatchedMovies(previousMovies);
          }
        }
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        if (liked) {
          _isLiked = previousValue;
        } else {
          _isWatched = previousValue;
        }
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('저장하지 못했습니다. 다시 시도해주세요.')));
    }
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
    ).showSnackBar(const SnackBar(content: Text('영화 링크가 복사되었습니다.')));
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
                    tooltip: '닫기',
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

                    try {
                      final comments = await _activityRepository.comments();
                      final now = DateTime.now();
                      final dateStr =
                          '${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}';

                      comments.insert(0, {
                        'movieId': widget.movie.id,
                        'movieTitle': widget.movie.title,
                        'posterPath': widget.movie.posterPath,
                        'content': text,
                        'date': dateStr,
                      });
                      await _activityRepository.saveComments(comments);

                      if (ctx.mounted) Navigator.pop(ctx);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('댓글이 등록되었습니다! 마이페이지에 반영됩니다.'),
                          ),
                        );
                      }
                    } catch (_) {
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                            content: Text('댓글을 저장하지 못했습니다. 다시 시도해주세요.'),
                          ),
                        );
                      }
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
            MovieInfoSection(
              detailFuture: movieDetail,
              fallbackMovie: widget.movie,
              isLiked: _isLiked,
              isWatched: _isWatched,
              onLike: () => _toggleLocalAction(liked: true),
              onWatched: () => _toggleLocalAction(liked: false),
              onComment: _showCommentBottomSheet,
              onShare: _copyMovieLink,
            ),
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
          child: AppNetworkImage(imageUrl: widget.movie.fullBackdropUrl),
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
                    tooltip: '예고편 재생',
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
            tooltip: '뒤로 가기',
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
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
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: AppLoadingIndicator(label: '출연진 정보를 불러오는 중입니다.'),
                );
              }
              if (snapshot.hasError) {
                return Semantics(
                  liveRegion: true,
                  child: Center(child: Text('출연진 정보를 불러오지 못했습니다.')),
                );
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
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: AppLoadingIndicator(label: '추천 영화를 불러오는 중입니다.'),
                );
              }
              if (snapshot.hasError) {
                return Semantics(
                  liveRegion: true,
                  child: Center(child: Text('추천 영화를 불러오지 못했습니다.')),
                );
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
                      onTap: () => Navigator.push(
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
                                child: AppNetworkImage(
                                  imageUrl: movie.fullPosterUrl,
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
