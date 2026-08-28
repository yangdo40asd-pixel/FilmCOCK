import 'package:flutter/material.dart';
import 'package:filmcock_app/presentation/screens/movie_model.dart';
import 'package:filmcock_app/presentation/screens/movie_detail_screen.dart';
import 'package:filmcock_app/presentation/screens/dummy_data.dart';
import 'package:filmcock_app/api_service.dart';

class ActorDetailScreen extends StatefulWidget {
  final Person actor;

  const ActorDetailScreen({super.key, required this.actor});

  @override
  State<ActorDetailScreen> createState() => _ActorDetailScreenState();
}

class _ActorDetailScreenState extends State<ActorDetailScreen> {
  late Future<List<Movie>> filmography;

  @override
  void initState() {
    super.initState();
    // 수작업으로 정리된 필모그래피 목록을 가져옵니다.
    filmography = _getManualFilmography(widget.actor.id);
  }

  // 수동으로 정의된 영화 제목 목록을 기반으로 Movie 객체 목록을 가져오는 함수
  Future<List<Movie>> _getManualFilmography(int actorId) async {
    // dummy_data.dart에 정의된 영화 ID 목록을 확인합니다.
    final movieIds = manualFilmography[actorId];

    // 해당 배우의 목록이 없으면 API를 통해 가져오거나 빈 리스트를 반환합니다.
    if (movieIds == null || movieIds.isEmpty) {
      return ApiService.getMovieCreditsForPerson(actorId);
    }

    final List<Movie> movies = [];
    for (int id in movieIds) {
      try {
        // 각 영화 ID로 상세 정보를 직접 가져옵니다.
        final movie = await ApiService.getMovieDetail(id);
        movies.add(movie);
      } catch (e) {
        // 특정 영화 정보를 가져오다 실패하면 로그를 남기고 넘어갑니다.
        print('Failed to get movie detail for id $id: $e');
      }
    }
    return movies;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF303030),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 상단 배우 사진 및 정보
            Stack(
              children: [
                SizedBox(
                  height: 450,
                  width: double.infinity,
                  child: Image.network(
                    widget.actor.fullProfileUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: Colors.grey[800]),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 10.0,
                    ),
                    color: Colors.black54,
                    child: Text(
                      '배우: ${widget.actor.name}',
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
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
            // 2. 주요 작품 섹션
            _buildFilmographySection(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFilmographySection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '주요 작품들',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<Movie>>(
            future: filmography,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data!.isEmpty) {
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
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        movie.fullPosterUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
