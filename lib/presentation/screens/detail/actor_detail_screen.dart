import 'package:flutter/material.dart';
import 'package:filmcock_app/data/models/movie_model.dart';
import 'package:filmcock_app/presentation/screens/detail/movie_detail_screen.dart';
import 'package:filmcock_app/data/services/api_service.dart';
import 'package:filmcock_app/presentation/widgets/app_network_image.dart';
import 'package:filmcock_app/data/repositories/activity_repository.dart';

class ActorDetailScreen extends StatefulWidget {
  final Person actor;

  const ActorDetailScreen({super.key, required this.actor});

  @override
  State<ActorDetailScreen> createState() => _ActorDetailScreenState();
}

class _ActorDetailScreenState extends State<ActorDetailScreen> {
  final ActivityRepository _activityRepository = const ActivityRepository();
  late Future<List<Movie>> filmography;
  bool _isLiked = false;
  Set<int> _likedMovieIds = {};

  @override
  void initState() {
    super.initState();
    filmography = ApiService.getPersonFilmography(widget.actor.id);
    _loadLikeState();
    _loadLikedMovies();
  }

  Future<void> _loadLikeState() async {
    final liked = await _activityRepository.isPersonLiked(widget.actor.id);
    if (mounted) {
      setState(() {
        _isLiked = liked;
      });
    }
  }

  Future<void> _loadLikedMovies() async {
    final movies = await _activityRepository.likedMovies();
    final ids = movies
        .map((movie) => int.tryParse(movie['id'].toString()))
        .whereType<int>()
        .toSet();
    if (mounted) {
      setState(() {
        _likedMovieIds = ids;
      });
    }
  }

  Future<void> _toggleActorLike() async {
    final previousState = _isLiked;
    final nextState = !previousState;
    setState(() {
      _isLiked = nextState;
    });
    List<Map<String, dynamic>>? previousPeople;
    try {
      await _activityRepository.setPersonLiked(widget.actor.id, nextState);
      final people = await _activityRepository.likedPeople();
      previousPeople = List<Map<String, dynamic>>.from(people);
      people.removeWhere(
        (person) => person['id'].toString() == widget.actor.id.toString(),
      );
      if (nextState) {
        people.insert(0, {
          'id': widget.actor.id,
          'name': widget.actor.displayName,
          'profileUrl': widget.actor.fullProfileUrl,
          'department': '배우',
        });
      }
      await _activityRepository.saveLikedPeople(people);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(nextState ? '💖 좋아요한 인물에 추가되었습니다.' : '좋아요가 취소되었습니다.'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (_) {
      try {
        await _activityRepository.setPersonLiked(
          widget.actor.id,
          previousState,
        );
        if (previousPeople != null) {
          await _activityRepository.saveLikedPeople(previousPeople);
        }
      } catch (_) {}
      if (!mounted) return;
      setState(() => _isLiked = previousState);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('저장하지 못했습니다. 다시 시도해주세요.')));
    }
  }

  Future<void> _toggleMovieLike(Movie movie) async {
    final isCurrentlyLiked = _likedMovieIds.contains(movie.id);
    final nextState = !isCurrentlyLiked;

    setState(() {
      if (nextState) {
        _likedMovieIds.add(movie.id);
      } else {
        _likedMovieIds.remove(movie.id);
      }
    });

    List<Map<String, dynamic>>? previousMovies;
    try {
      await _activityRepository.setMovieLiked(movie.id, nextState);
      final movies = await _activityRepository.likedMovies();
      previousMovies = List<Map<String, dynamic>>.from(movies);
      movies.removeWhere(
        (item) => item['id'].toString() == movie.id.toString(),
      );
      if (nextState) {
        movies.insert(0, {
          'id': movie.id,
          'title': movie.title,
          'posterPath': movie.posterPath,
          'voteAverage': movie.voteAverage,
        });
      }
      await _activityRepository.saveLikedMovies(movies);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              nextState ? '🍿 내가 추천한 띵작에 추가되었습니다.' : '추천한 띵작에서 삭제되었습니다.',
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (_) {
      try {
        await _activityRepository.setMovieLiked(movie.id, isCurrentlyLiked);
        if (previousMovies != null) {
          await _activityRepository.saveLikedMovies(previousMovies);
        }
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        if (isCurrentlyLiked) {
          _likedMovieIds.add(movie.id);
        } else {
          _likedMovieIds.remove(movie.id);
        }
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('저장하지 못했습니다. 다시 시도해주세요.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 상단 배우 사진 및 정보 헤더
            Stack(
              children: [
                SizedBox(
                  height: 440,
                  width: double.infinity,
                  child: AppNetworkImage(
                    imageUrl: widget.actor.fullProfileUrl,
                    placeholderIcon: Icons.person,
                    placeholderIconSize: 64,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 14.0,
                    ),
                    color: Colors.black.withValues(alpha: 0.65),
                    child: Text(
                      '배우: ${widget.actor.displayName}',
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 10,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 30,
                    ),
                    tooltip: '뒤로 가기',
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),

            // 2. 이 배우 좋아요 알약 버튼 (중앙 정렬)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: InkWell(
                  onTap: _toggleActorLike,
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 26,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _isLiked
                          ? const Color(0xFF6B4EE6)
                          : const Color(0xFF2C2C32),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: _isLiked
                            ? const Color(0xFFA88BFA)
                            : Colors.white60,
                        width: 1.2,
                      ),
                      boxShadow: _isLiked
                          ? [
                              BoxShadow(
                                color: const Color(
                                  0xFF6B4EE6,
                                ).withValues(alpha: 0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isLiked
                              ? Icons.thumb_up
                              : Icons.thumb_up_alt_outlined,
                          color: Colors.white,
                          size: 19,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '이 배우 좋아요',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 3. 주요 작품들 섹션 헤더
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '주요 작품들',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 4. 작품 3열 그리드 (하트 자동 좋아요 버튼 및 영화 제목 포함)
            _buildFilmographySection(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFilmographySection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: FutureBuilder<List<Movie>>(
        future: filmography,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 30.0),
                child: CircularProgressIndicator(color: Color(0xFFA88BFA)),
              ),
            );
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 30.0),
                child: Text(
                  '작품 정보를 불러올 수 없습니다.',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            );
          }

          final movies = snapshot.data!;
          return GridView.builder(
            itemCount: movies.length,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.56,
              crossAxisSpacing: 10,
              mainAxisSpacing: 16,
            ),
            itemBuilder: (context, index) {
              final movie = movies[index];
              final isMovieLiked = _likedMovieIds.contains(movie.id);

              return GestureDetector(
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MovieDetailScreen(movie: movie),
                    ),
                  );
                  _loadLikedMovies();
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 포스터 + 우상단 하트 오버레이
                    Expanded(
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: SizedBox(
                              width: double.infinity,
                              height: double.infinity,
                              child: AppNetworkImage(
                                imageUrl: movie.fullPosterUrl,
                              ),
                            ),
                          ),

                          // 우측 상단 하트 버튼 (자동 좋아요 연동)
                          Positioned(
                            top: 6,
                            right: 6,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => _toggleMovieLike(movie),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withValues(alpha: 0.55),
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  isMovieLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isMovieLiked
                                      ? const Color(0xFFFF4D4F)
                                      : Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    // 개별 영화 제목
                    Text(
                      movie.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
