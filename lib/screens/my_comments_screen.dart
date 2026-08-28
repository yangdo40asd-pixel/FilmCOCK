import 'package:flutter/material.dart';

class MyCommentsScreen extends StatelessWidget {
  const MyCommentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 임시 댓글 데이터
    final comments = []; // 데이터가 없는 상황을 시뮬레이션

    return Scaffold(
      appBar: AppBar(title: const Text('내가 작성한 댓글')),
      body: comments.isEmpty
          ? const Center(
              child: Text(
                '아직 작성한 댓글이 없습니다.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: comments.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final commentData = comments[index];
                return _buildCommentItem(
                  context: context,
                  movieTitle: commentData['movieTitle'] as String,
                  comment: commentData['comment'] as String,
                );
              },
            ),
    );
  }

  Widget _buildCommentItem({
    required BuildContext context,
    required String movieTitle,
    required String comment,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 임시로 포스터 영역을 아이콘으로 대체
          Container(
            width: 80,
            height: 110,
            child: Icon(
              Icons.movie_creation_outlined,
              color: Colors.grey,
              size: 40,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movieTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  comment,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[300],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
