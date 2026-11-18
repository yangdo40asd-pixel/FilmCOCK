import 'package:filmcock_app/features/movie_detail/presentation/widgets/watched_confirmation.dart';
import 'package:filmcock_app/features/movie_detail/application/movie_details_controller.dart';
import 'package:filmcock_app/features/movie_detail/presentation/widgets/movie_comment_sheet.dart';
import 'package:filmcock_app/app/dependencies/app_dependencies.dart';
import 'package:filmcock_app/features/activity/data/activity_repository.dart';
import 'package:filmcock_app/features/person_detail/presentation/screens/actor_detail_screen.dart';
import 'package:filmcock_app/shared/domain/models/catalog_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:filmcock_app/shared/presentation/widgets/app_network_image.dart';
import 'package:filmcock_app/features/movie_detail/presentation/widgets/movie_info_section.dart';
import 'package:filmcock_app/shared/presentation/widgets/app_loading_indicator.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final ActivityRepository _activityRepository = const ActivityRepository();
  late final MovieDetailsController _details;
  Future<Movie> get movieDetail => _details.movie;
  Future<List<Person>> get movieCredits => _details.credits;
  Future<List<Movie>> get recommendedMovies => _details.recommendations;
  Future<List<Video>> get movieVideos => _details.videos;
  bool _isLiked = false;
  bool _isWatched = false;
  bool _savingAction = false;
  bool _actionsReady = false;

  @override
  void initState() {
    super.initState();
    _details = MovieDetailsController(
      movieId: widget.movie.id,
      catalog: AppDependencies.catalog,
    );
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
      _actionsReady = true;
    });
  }

  Future<void> _toggleLocalAction({required bool liked}) async {
    if (_savingAction || !_actionsReady) return;
    _savingAction = true;
    final previous = liked ? _isLiked : _isWatched;
    final next = !previous;
    setState(() {
      if (liked) {
        _isLiked = next;
      } else {
        _isWatched = next;
      }
    });
    try {
      await _activityRepository.updateMovieAction(
        widget.movie,
        next,
        liked: liked,
      );
      if (!mounted) return;
      if (!liked && next) {
        await showWatchedConfirmation(context, widget.movie.title);
        return;
      }
      final message = liked
          ? (next ? '내가 추천한 띵작에 추가되었습니다.' : '추천한 띵작에서 삭제되었습니다.')
          : (next ? '캘린더에 추가되었습니다.' : '관람 내역에서 삭제되었습니다.');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;
      setState(() {
        if (liked) {
          _isLiked = previous;
        } else {
          _isWatched = previous;
        }
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('저장하지 못했습니다. 다시 시도해주세요.')));
    } finally {
      _savingAction = false;
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

  Future<void> _showCommentBottomSheet() async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => MovieCommentSheet(
        movieTitle: widget.movie.title,
        onSubmit: (text) {
          final now = DateTime.now();
          return _activityRepository.addComment({
            'movieId': widget.movie.id,
            'movieTitle': widget.movie.title,
            'posterPath': widget.movie.posterPath,
            'content': text,
            'date':
                '${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}',
          });
        },
      ),
    );
    if (mounted && saved == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('댓글이 등록되었습니다! 마이페이지에 반영됩니다.')),
      );
    }
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
              colors: [
                Colors.transparent,
                Theme.of(context).colorScheme.surface,
              ],
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
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
