import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:filmcock_app/data/models/movie_model.dart';
import 'package:filmcock_app/presentation/screens/detail/movie_detail_screen.dart';

class MyCommentsScreen extends StatefulWidget {
  const MyCommentsScreen({super.key});

  @override
  State<MyCommentsScreen> createState() => _MyCommentsScreenState();
}

class _MyCommentsScreenState extends State<MyCommentsScreen> {
  List<Map<String, dynamic>> _comments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    final prefs = await SharedPreferences.getInstance();
    final rawComments = prefs.getStringList('user_comments') ?? [];
    final parsed = rawComments.map((e) {
      try {
        return jsonDecode(e) as Map<String, dynamic>;
      } catch (_) {
        return <String, dynamic>{};
      }
    }).where((m) => m.isNotEmpty).toList();

    setState(() {
      _comments = parsed;
      _isLoading = false;
    });
  }

  Future<void> _deleteComment(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final rawComments = prefs.getStringList('user_comments') ?? [];
    if (index >= 0 && index < rawComments.length) {
      rawComments.removeAt(index);
      await prefs.setStringList('user_comments', rawComments);
      _loadComments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('댓글이 삭제되었습니다.')),
        );
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
        title: const Text('내가 쓴 댓글'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFA88BFA)))
          : _comments.isEmpty
              ? const Center(
                  child: Text(
                    '작성한 댓글이 없습니다.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _comments.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = _comments[index];
                    final movieTitle = item['movieTitle'] as String? ?? '영화 제목';
                    final posterPath = item['posterPath'] as String?;
                    final content = item['content'] as String? ?? '';
                    final date = item['date'] as String? ?? '';
                    final movieId = int.tryParse(item['movieId'].toString()) ?? 0;

                    return Dismissible(
                      key: Key('comment_${index}_$movieId'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20.0),
                        color: Colors.redAccent,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => _deleteComment(index),
                      child: GestureDetector(
                        onTap: () {
                          if (movieId > 0) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MovieDetailScreen(
                                  movie: Movie(
                                    id: movieId,
                                    title: movieTitle,
                                    overview: '',
                                    posterPath: posterPath,
                                    voteAverage: 8.0,
                                    releaseDate: '',
                                  ),
                                ),
                              ),
                            ).then((_) => _loadComments());
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E22),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: (posterPath != null && posterPath.isNotEmpty)
                                    ? Image.network(
                                        'https://image.tmdb.org/t/p/w200',
                                        width: 50,
                                        height: 70,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => Container(
                                          width: 50,
                                          height: 70,
                                          color: Colors.grey[800],
                                          child: const Icon(Icons.movie, color: Colors.white54),
                                        ),
                                      )
                                    : Container(
                                        width: 50,
                                        height: 70,
                                        color: Colors.grey[800],
                                        child: const Icon(Icons.movie, color: Colors.white54),
                                      ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            movieTitle,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (date.isNotEmpty)
                                          Text(
                                            date,
                                            style: TextStyle(color: Colors.grey[500], fontSize: 11),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      content,
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.85),
                                        fontSize: 13,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
