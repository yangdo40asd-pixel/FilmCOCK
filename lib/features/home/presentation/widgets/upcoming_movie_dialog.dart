import 'package:flutter/material.dart';
import 'package:filmcock_app/shared/domain/models/movie.dart';
import 'package:filmcock_app/shared/presentation/widgets/app_network_image.dart';
import 'package:filmcock_app/features/movie_detail/presentation/screens/movie_detail_screen.dart';

void showUpcomingMovieDialog(
  BuildContext context,
  Movie movie,
  String dDayText,
) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      final colors = Theme.of(ctx).colorScheme;
      return Dialog(
        backgroundColor: colors.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 40.0,
          vertical: 24.0,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Circular Bell Icon Badge
              Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  color: Color(0xFF735BF2),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.notifications,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(height: 18),

              // Dialog Title
              Text(
                '곧 개봉해요!',
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Movie Poster
              ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: SizedBox(
                  width: 170,
                  height: 240,
                  child: AppNetworkImage(
                    imageUrl: movie.fullPosterUrl,
                    placeholderIconSize: 40,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Movie Title
              Text(
                movie.title,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Red D-day Pill Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 6.0,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF3B30),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Text(
                  dDayText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 26),

              // Action Buttons (닫기 & 상세보기)
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(
                        '닫기',
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B4EE6),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MovieDetailScreen(movie: movie),
                          ),
                        );
                      },
                      child: const Text(
                        '상세보기',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
