import 'package:flutter/material.dart';
import 'package:filmcock_app/data/models/movie_model.dart';
import 'package:filmcock_app/data/services/api_service.dart';
import 'package:filmcock_app/presentation/screens/detail/movie_detail_screen.dart';

class CalendarAddMovieScreen extends StatefulWidget {
  const CalendarAddMovieScreen({super.key});

  @override
  State<CalendarAddMovieScreen> createState() => _CalendarAddMovieScreenState();
}

class _CalendarAddMovieScreenState extends State<CalendarAddMovieScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Movie> _movies = [];
  bool _isLoading = true;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadPopularMovies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPopularMovies() async {
    setState(() {
      _isLoading = true;
      _isSearching = false;
    });
    try {
      final popular = await ApiService.getPopularMovies();
      if (mounted) {
        setState(() {
          _movies = popular;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      _loadPopularMovies();
      return;
    }

    setState(() {
      _isLoading = true;
      _isSearching = true;
    });

    try {
      final results = await ApiService.searchMovies(trimmed);
      if (mounted) {
        setState(() {
          _movies = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context, true),
        ),
        title: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          onChanged: (val) {
            if (val.isEmpty) {
              _loadPopularMovies();
            }
          },
          onSubmitted: _search,
          decoration: InputDecoration(
            hintText: '작품 제목을 검색해보세요',
            hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _searchController.text.isNotEmpty ? Icons.close : Icons.search,
              color: Colors.white70,
            ),
            onPressed: () {
              if (_searchController.text.isNotEmpty) {
                _searchController.clear();
                _loadPopularMovies();
              } else {
                _search(_searchController.text);
              }
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Text(
              _isSearching ? '검색 결과' : '인기 작품',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFA88BFA)),
                  )
                : _movies.isEmpty
                    ? Center(
                        child: Text(
                          _isSearching
                              ? '검색된 작품이 없습니다.'
                              : '인기 작품을 불러올 수 없습니다.',
                          style: TextStyle(color: Colors.grey[400], fontSize: 15),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.62,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _movies.length,
                        itemBuilder: (context, index) {
                          final movie = _movies[index];
                          return GestureDetector(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MovieDetailScreen(movie: movie),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: movie.fullPosterUrl.isNotEmpty
                                        ? Image.network(
                                            movie.fullPosterUrl,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (ctx, err, stack) =>
                                                Container(
                                              color: Colors.grey[850],
                                              child: const Icon(
                                                Icons.movie,
                                                color: Colors.white54,
                                              ),
                                            ),
                                          )
                                        : Container(
                                            color: Colors.grey[850],
                                            child: const Icon(
                                              Icons.movie,
                                              color: Colors.white54,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 6),
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
                      ),
          ),
        ],
      ),
    );
  }
}
