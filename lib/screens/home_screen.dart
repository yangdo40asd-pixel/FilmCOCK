import 'package:filmcock_app/api_service.dart';
import 'package:filmcock_app/presentation/screens/movie_model.dart';
import '../widgets/movie_poster.dart';
// 1. 방금 만든 알림 팝업 위젯 import (상대 경로 사용)
import '../widgets/notification_dialog.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FilmCOCK!'),
        actions: [
          // --- 2. 여기가 수정된 부분입니다! ---
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              // 3. 탭하면 showDialog 함수를 호출
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  // 4. 우리가 만든 NotificationDialog를 보여줌
                  return const NotificationDialog(
                    movieTitle: '극장판 귀멸의 칼날: 무한성편', // PDF 12의 임시 제목
                  );
                },
              );
            },
          ),
          // --- (여기까지 수정) ---
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ... (이하 '최신 상영 영화' 등은 이전과 동일) ...
              _buildMovieCarousel(
                context: context,
                title: '최신 상영 영화',
                startId: 0,
              ),
              const SizedBox(height: 24),
              _buildMovieCarousel(
                context: context,
                title: '추천 영화',
                startId: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // (이하 _buildMovieCarousel 함수는 이전과 동일)
  Widget _buildMovieCarousel({
    required BuildContext context,
    required String title,
    required int startId,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 190,
          child: FutureBuilder<List<Movie>>(
            future: title == '최신 상영 영화'
                ? ApiService.getNowPlayingMovies()
                : ApiService.getPopularMovies(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final movies = snapshot.data!;
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      left: (index == 0) ? 16.0 : 0.0,
                      right: 16.0,
                    ),
                    child: MoviePoster(movie: movies[index]),
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
