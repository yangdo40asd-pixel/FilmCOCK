import 'package:flutter/material.dart';
import 'package:filmcock_app/features/chat/domain/chat_message.dart';
import 'package:filmcock_app/shared/domain/models/movie.dart';
import 'package:filmcock_app/shared/presentation/widgets/poster_image.dart';

const double _chatPosterWidth = 120;

class ChatMessageTile extends StatelessWidget {
  final ChatMessage message;
  final ValueChanged<String> onFollowUp;
  final ValueChanged<Movie> onMovieTap;

  const ChatMessageTile({
    super.key,
    required this.message,
    required this.onFollowUp,
    required this.onMovieTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (message.isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFF6B4EE6),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(4),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                ),
                child: Text(
                  message.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 챗봇 응답
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 도슨트 아바타
              Container(
                width: 36,
                height: 36,
                margin: const EdgeInsets.only(right: 10.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B4EE6).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF8B5CF6)),
                ),
                child: const Icon(
                  Icons.smart_toy_outlined,
                  color: Color(0xFFA88BFA),
                  size: 20,
                ),
              ),

              // 텍스트 말풍선
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF22222C) : Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                    ),
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.black12,
                    ),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF191919),
                      fontSize: 15,
                      height: 1.45,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // 1. 꼬리질문 동적 선택지 칩들 (있는 경우)
          if (message.followUpOptions != null &&
              message.followUpOptions!.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(left: 46.0, top: 10.0),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: message.followUpOptions!.map((option) {
                  return ActionChip(
                    backgroundColor: isDark
                        ? const Color(0xFF2E2E3C)
                        : const Color(0xFFEDE9FE),
                    side: const BorderSide(
                      color: Color(0xFF8B5CF6),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    label: Text(
                      option,
                      style: const TextStyle(
                        color: Color(0xFF6B4EE6),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () => onFollowUp(option),
                  );
                }).toList(),
              ),
            ),
          ],

          // 2. 추천 영화 카드들 (있는 경우)
          if (message.recommendedMovies != null &&
              message.recommendedMovies!.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(left: 46.0, top: 14.0),
              child: SizedBox(
                height: 262,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: message.recommendedMovies!.length,
                  itemBuilder: (context, idx) {
                    final movie = message.recommendedMovies![idx];
                    final reason =
                        (message.movieReasons != null &&
                            idx < message.movieReasons!.length)
                        ? message.movieReasons![idx]
                        : '';

                    return GestureDetector(
                      onTap: () => onMovieTap(movie),
                      child: Container(
                        width: _chatPosterWidth,
                        margin: const EdgeInsets.only(right: 12.0),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF282834)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? Colors.white12 : Colors.black12,
                          ),
                          boxShadow: isDark
                              ? null
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 영화 포스터
                            PosterImage(
                              imageUrl: movie.fullPosterUrl,
                              width: _chatPosterWidth,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    movie.title,
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF191919),
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Color(0xFFFFB800),
                                        size: 13,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        '평점 ${movie.voteAverage.toStringAsFixed(1)}',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (reason.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      reason,
                                      style: const TextStyle(
                                        color: Color(0xFFA88BFA),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 처리 중 인디케이터
}
