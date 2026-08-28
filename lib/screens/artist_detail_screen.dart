import 'package:flutter/material.dart';
import '../api_service.dart';
import '../presentation/screens/movie_model.dart';
import '../widgets/movie_poster.dart';

class ArtistDetailScreen extends StatefulWidget {
  final int artistId;
  final String artistName;

  const ArtistDetailScreen({
    super.key,
    required this.artistId,
    required this.artistName,
  });

  @override
  State<ArtistDetailScreen> createState() => _ArtistDetailScreenState();
}

class _ArtistDetailScreenState extends State<ArtistDetailScreen> {
  late Future<List<Movie>> filmography;

  @override
  void initState() {
    super.initState();
    // 위젯이 생성될 때 배우의 필모그래피를 API로 가져옵니다.
    filmography = ApiService.getMovieCreditsForPerson(widget.artistId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.artistName), // 앱 바에 아티스트 이름 표시
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 2. 아티스트 프로필 사진 (PDF 5페이지 참고)
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[800],
                backgroundImage: NetworkImage(
                  'https://picsum.photos/id/${widget.artistId + 100}/200/200',
                ),
              ),
              const SizedBox(height: 12),

              // 3. 아티스트 이름
              Text(
                widget.artistName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),

              // 4. '주요 작품들' 섹션 (PDF 5페이지 참고)
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '주요 작품들',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),

              // 5. 작품들을 격자(Grid) 형태로 보여줌
              FutureBuilder<List<Movie>>(
                future: filmography,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return const Center(child: Text('작품 정보를 불러올 수 없습니다.'));
                  }
                  final movies = snapshot.data!;
                  return GridView.builder(
                    itemCount: movies.length,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: (130 / 190), // 포스터 비율
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
