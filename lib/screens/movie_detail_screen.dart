import 'package:flutter/material.dart';
import 'package:filmcock_app/presentation/screens/movie_model.dart';

class MovieDetailScreen extends StatelessWidget {
  final Movie movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. 앱 바를 투명하게 만들고, 스크롤 시에도 내용이 앱 바 뒤로 보이게 함
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // 배경 투명
        elevation: 0, // 그림자 제거
      ),
      body: SingleChildScrollView(
        // 2. 전체 화면을 스크롤 가능하게 함
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. 영화 포스터/배경 이미지 ---
            Container(
              height: 300,
              width: double.infinity,
              color: Colors.grey[800],
              child: Image.network(
                movie.fullBackdropUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.error_outline, color: Colors.white),
                  );
                },
              ),
            ),

            // --- 2. 영화 정보 섹션 ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목
                  Text(
                    movie.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 메타데이터 (연도, 시간, 장르 등)
                  Text(
                    '${movie.releaseDate.split('-').first} | 평점: ${movie.voteAverage.toStringAsFixed(1)}',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

                  // '스트리밍 확인' 버튼 (PDF 7페이지 참고)
                  if (movie.overview.isNotEmpty)
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(
                          double.infinity,
                          48,
                        ), // 가로 꽉 채우기
                      ),
                      child: const Text(
                        '스트리밍 확인',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),

                  // '줄거리 요약'
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '줄거리 요약 (보기..)',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.yellow, size: 20),
                          SizedBox(width: 4),
                          Text(
                            movie.voteAverage.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 임시 줄거리 텍스트
                  Text(
                    movie.overview.isNotEmpty
                        ? movie.overview
                        : '줄거리 정보가 없습니다.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      height: 1.5, // 줄 간격
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
