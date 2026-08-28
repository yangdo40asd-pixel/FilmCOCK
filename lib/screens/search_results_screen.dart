import 'package:flutter/material.dart';
import '../api_service.dart';
import '../presentation/screens/movie_model.dart';
import '../widgets/movie_poster.dart'; // 영화 포스터 위젯 import

class SearchResultsScreen extends StatefulWidget {
  // 1. 검색어를 전달받을 변수
  final String searchQuery;

  const SearchResultsScreen({super.key, required this.searchQuery});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late Future<List<Movie>> _searchResults;

  @override
  void initState() {
    super.initState();
    // API를 통해 영화 검색 결과를 가져옵니다.
    _searchResults = ApiService.searchMovies(widget.searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('검색 결과'), // 앱 바 제목
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 2. PDF 10페이지의 문구 (source: 160)
              Text(
                "'${widget.searchQuery}'(으)로 검색한 결과입니다.",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // 3. 검색 결과를 격자(Grid) 형태로 보여줌
              FutureBuilder<List<Movie>>(
                future: _searchResults,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data!.isEmpty) {
                    return const Center(child: Text('검색 결과가 없습니다.'));
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
