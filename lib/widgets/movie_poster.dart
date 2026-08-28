// 1. 방금 만든 상세 화면 파일을 import
import 'package:filmcock_app/screens/movie_detail_screen.dart';
import 'package:filmcock_app/presentation/screens/movie_model.dart';
import 'package:flutter/material.dart';

class MoviePoster extends StatelessWidget {
  final Movie movie;

  const MoviePoster({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    // 2. GestureDetector 위젯으로 Card를 감싸서 탭을 감지
    return GestureDetector(
      onTap: () {
        // 3. 탭하면 MovieDetailScreen으로 이동
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MovieDetailScreen(movie: movie),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Container(
          width: 130,
          height: 190,
          color: Colors.grey[800],
          child: Image.network(
            movie.fullPosterUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(Icons.error_outline, color: Colors.white),
              );
            },
          ),
        ),
      ),
    );
  }
}
