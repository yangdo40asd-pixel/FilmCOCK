import 'package:flutter/material.dart';
import 'package:filmcock_app/data/services/api_service.dart';
import 'package:filmcock_app/data/models/movie_model.dart';
import 'package:filmcock_app/presentation/widgets/movie_poster.dart';
import 'package:filmcock_app/presentation/widgets/app_network_image.dart';
import 'package:filmcock_app/data/repositories/activity_repository.dart';

class ArtistDetailScreen extends StatefulWidget {
  final int artistId;
  final String artistName;
  final String? profileUrl;

  const ArtistDetailScreen({
    super.key,
    required this.artistId,
    required this.artistName,
    this.profileUrl,
  });

  @override
  State<ArtistDetailScreen> createState() => _ArtistDetailScreenState();
}

class _ArtistDetailScreenState extends State<ArtistDetailScreen> {
  final ActivityRepository _activityRepository = const ActivityRepository();
  late Future<List<Movie>> filmography;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    filmography = ApiService.getPersonFilmography(
      widget.artistId,
      directing: true,
    );
    _loadLikeState();
  }

  Future<void> _loadLikeState() async {
    final liked = await _activityRepository.isPersonLiked(widget.artistId);
    if (!mounted) return;
    setState(() {
      _isLiked = liked;
    });
  }

  Future<void> _toggleLike() async {
    final previousState = _isLiked;
    final nextState = !previousState;
    setState(() {
      _isLiked = nextState;
    });
    List<Map<String, dynamic>>? previousPeople;
    try {
      await _activityRepository.setPersonLiked(widget.artistId, nextState);
      final people = await _activityRepository.likedPeople();
      previousPeople = List<Map<String, dynamic>>.from(people);
      people.removeWhere(
        (person) => person['id'].toString() == widget.artistId.toString(),
      );
      if (nextState) {
        people.insert(0, {
          'id': widget.artistId,
          'name': widget.artistName,
          'profileUrl': widget.profileUrl ?? '',
          'department': '감독',
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
          widget.artistId,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: Text(widget.artistName),
        actions: [
          IconButton(
            icon: Icon(
              _isLiked ? Icons.favorite : Icons.favorite_border,
              color: _isLiked ? const Color(0xFFFF4D4F) : Colors.white,
            ),
            tooltip: _isLiked ? '좋아요 취소' : '좋아요',
            onPressed: _toggleLike,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipOval(
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: AppNetworkImage(
                    imageUrl: widget.profileUrl ?? '',
                    placeholderIcon: Icons.person,
                    placeholderIconSize: 48,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.artistName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '주요 작품들이에요',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FutureBuilder<List<Movie>>(
                future: filmography,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return const Center(
                      child: Text(
                        '작품 정보를 불러올 수 없습니다.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }
                  final movies = snapshot.data!;
                  return GridView.builder(
                    itemCount: movies.length,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: (130 / 190),
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemBuilder: (context, index) {
                      final movie = movies[index];
                      return MoviePoster(movie: movie);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
