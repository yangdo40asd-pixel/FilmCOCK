import 'package:flutter/material.dart';
import 'package:filmcock_app/data/models/movie_model.dart';
import 'package:filmcock_app/presentation/widgets/app_loading_indicator.dart';
import 'package:filmcock_app/presentation/widgets/watch_options_sheet.dart';

class MovieInfoSection extends StatelessWidget {
  final Future<Movie> detailFuture;
  final Movie fallbackMovie;
  final bool isLiked;
  final bool isWatched;
  final VoidCallback onLike;
  final VoidCallback onWatched;
  final VoidCallback onComment;
  final VoidCallback onShare;

  const MovieInfoSection({
    super.key,
    required this.detailFuture,
    required this.fallbackMovie,
    required this.isLiked,
    required this.isWatched,
    required this.onLike,
    required this.onWatched,
    required this.onComment,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: FutureBuilder<Movie>(
        future: detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: AppLoadingIndicator(label: '영화 상세 정보를 불러오는 중입니다.'),
            );
          }
          final detail = snapshot.data ?? fallbackMovie;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (snapshot.hasError)
                Semantics(
                  liveRegion: true,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text('일부 상세 정보를 불러오지 못해 기본 정보를 표시합니다.'),
                  ),
                ),
              Text(
                detail.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(_formatReleaseDate(detail.releaseDate)),
                  const SizedBox(width: 10),
                  Text(
                    '⭐️ ${detail.voteAverage.toStringAsFixed(1)}',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: detail.genres
                    .map((genre) => Chip(label: Text(genre.name)))
                    .toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => WatchOptionsSheet.show(
                    context,
                    movieId: detail.id,
                    movieTitle: detail.title,
                  ),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('보러가기'),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _action(
                    icon: isLiked ? Icons.favorite : Icons.favorite_border,
                    label: '좋아요',
                    selected: isLiked,
                    onPressed: onLike,
                  ),
                  _action(
                    icon: isWatched
                        ? Icons.check_circle
                        : Icons.check_circle_outline,
                    label: '봤어요',
                    selected: isWatched,
                    onPressed: onWatched,
                  ),
                  _action(
                    icon: Icons.comment_outlined,
                    label: '댓글',
                    onPressed: onComment,
                  ),
                  _action(
                    icon: Icons.share_outlined,
                    label: '공유',
                    onPressed: onShare,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '줄거리',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                detail.overview.isNotEmpty ? detail.overview : '줄거리 정보가 없습니다.',
                style: const TextStyle(height: 1.5),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _action({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool selected = false,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Semantics(
          button: true,
          selected: selected,
          label: label,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: selected ? const Color(0xFF7656E8) : null,
                  size: 28,
                ),
                const SizedBox(height: 5),
                Text(label, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatReleaseDate(String value) {
    return value.length < 4 ? '개봉일 정보 없음' : value.replaceAll('-', '. ');
  }
}
