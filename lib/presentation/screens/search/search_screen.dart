import 'package:filmcock_app/data/services/api_service.dart';
import 'package:filmcock_app/presentation/screens/detail/movie_detail_screen.dart';
import 'package:filmcock_app/data/models/movie_model.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> genres = [
      '한국',
      '외국',
      '액션',
      '스릴러',
      '어드벤처',
      '코미디',
      '판타지',
      '공포',
      '좀비',
      '로맨스',
    ];

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: InputDecoration(
            hintText: '제목, 배우, 장르 검색...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[800],
            contentPadding: const EdgeInsets.symmetric(
              vertical: 0,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none,
            ),
          ),

          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              // TODO: 검색 결과 화면으로 이동 (현재는 미구현)
              print('검색어: $value');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  '장르',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Wrap(
                  spacing: 10.0,
                  runSpacing: 10.0,
                  children: genres.map((genre) {
                    return ActionChip(
                      label: Text(genre),
                      onPressed: () {
                        print('선택된 장르: $genre');
                      },
                      backgroundColor: Colors.grey[800],
                      labelStyle: const TextStyle(color: Colors.white),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              _buildMovieCarousel(title: '지금 급상승 중인 컨텐츠'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMovieCarousel({required String title}) {
    // FutureBuilder를 사용하여 인기 영화 데이터를 비동기적으로 로드합니다.
    return FutureBuilder<List<Movie>>(
      future: ApiService.getPopularMovies(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 180,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final movies = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  final movie = movies[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => MovieDetailScreen(movie: movie),
                          ),
                        );
                      },
                      child: SizedBox(
                        width: 100.0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  movie.fullPosterUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              movie.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12.0,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
