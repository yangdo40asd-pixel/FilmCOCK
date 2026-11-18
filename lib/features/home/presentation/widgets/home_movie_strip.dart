import 'package:flutter/material.dart';
import 'package:filmcock_app/core/utils/release_date_utils.dart';
import 'package:filmcock_app/shared/domain/models/movie.dart';
import 'package:filmcock_app/shared/presentation/widgets/app_network_image.dart';

class HomeMovieStrip extends StatelessWidget {
  final List<Movie> movies;
  final bool upcoming;
  final ValueChanged<Movie> onMovieTap;

  const HomeMovieStrip({
    super.key,
    required this.movies,
    required this.onMovieTap,
    this.upcoming = false,
  });

  @override
  Widget build(BuildContext context) => upcoming
      ? _buildUpcomingMoviesList(context, movies: movies)
      : _buildMovieHorizontalList(context, movies: movies);

  Widget _buildMovieHorizontalList(
    BuildContext context, {
    required List<Movie> movies,
  }) {
    return SizedBox(
      height: 180.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () => onMovieTap(movie),
              child: SizedBox(
                width: 100.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: AppNetworkImage(
                          imageUrl: movie.fullPosterUrl,
                          width: double.infinity,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      movie.title,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : const Color(0xFF191919),
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
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
    );
  }

  Widget _buildUpcomingMoviesList(
    BuildContext context, {
    required List<Movie> movies,
  }) {
    return SizedBox(
      height: 180.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          int dDay = 0;
          try {
            if (movie.releaseDate.isNotEmpty) {
              final release = DateTime.parse(movie.releaseDate);
              dDay = ReleaseDateUtils.daysUntil(release);
            }
          } catch (_) {}

          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () => onMovieTap(movie),
              child: SizedBox(
                width: 100.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: AppNetworkImage(
                              imageUrl: movie.fullPosterUrl,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          if (dDay > 0)
                            Positioned(
                              top: 6,
                              left: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'D-$dDay',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      movie.title,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : const Color(0xFF191919),
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
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
    );
  }
}
