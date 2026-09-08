import 'package:flutter/material.dart';
import 'package:filmcock_app/data/models/movie_model.dart';
import 'package:filmcock_app/presentation/screens/detail/movie_detail_screen.dart';
import 'package:filmcock_app/data/services/api_service.dart';

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
    filmography = ApiService.getPersonFilmography(widget.actor.id);
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
            '주요 작품들이에요',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
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
