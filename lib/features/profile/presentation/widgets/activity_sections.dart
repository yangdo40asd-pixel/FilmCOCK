import 'package:flutter/material.dart';
import 'package:filmcock_app/shared/domain/models/movie.dart';
import 'package:filmcock_app/shared/presentation/widgets/poster_image.dart';

String _getFullImageUrl(String? path, {bool isPerson = false}) {
  if (path == null || path.isEmpty) return '';
  if (path.startsWith('http://') || path.startsWith('https://')) return path;
  final cleanPath = path.startsWith('/') ? path : '/$path';
  final size = isPerson ? 'w500' : 'w300';
  return 'https://image.tmdb.org/t/p/$size$cleanPath';
}

class RecommendedMoviesSection extends StatelessWidget {
  final List<Map<String, dynamic>> movies;
  final ValueChanged<Movie> onMovieTap;
  const RecommendedMoviesSection({
    super.key,
    required this.movies,
    required this.onMovieTap,
  });

  @override
  Widget build(BuildContext context) {
    // Deduplicate by ID
    final seen = <String>{};
    final uniqueMovies = <Map<String, dynamic>>[];
    for (final m in movies) {
      final id = m['id'].toString();
      if (!seen.contains(id)) {
        seen.add(id);
        uniqueMovies.add(m);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            '🍿 내가 추천한 띵작!',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (uniqueMovies.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 8.0,
            ),
            child: Text(
              '영화 상세에서 "좋아요(하트)"를 누르면 여기에 추천 띵작으로 등록됩니다.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          )
        else
          SizedBox(
            height: 175,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: uniqueMovies.length,
              itemBuilder: (context, index) {
                final movie = uniqueMovies[index];
                final posterPath = movie['posterPath'] as String?;
                final title = movie['title'] as String? ?? '영화 제목';
                final voteAverage =
                    (movie['voteAverage'] as num?)?.toDouble() ?? 8.0;
                final fullPosterUrl = _getFullImageUrl(posterPath);

                return GestureDetector(
                  onTap: () {
                    final movieObj = Movie(
                      id: int.tryParse(movie['id'].toString()) ?? 0,
                      title: title,
                      overview: '',
                      posterPath: posterPath,
                      voteAverage: voteAverage,
                      releaseDate: '',
                    );
                    onMovieTap(movieObj);
                  },
                  child: Container(
                    width: 90,
                    margin: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PosterImage(
                          imageUrl: fullPosterUrl,
                          width: 90,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          title,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // 5. 좋아요한 인물
}

class LikedPeopleSection extends StatelessWidget {
  final List<Map<String, dynamic>> people;
  final ValueChanged<Map<String, dynamic>> onPersonTap;
  const LikedPeopleSection({
    super.key,
    required this.people,
    required this.onPersonTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            '💖 좋아요한 인물',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (people.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 8.0,
            ),
            child: Text(
              '좋아하는 배우나 감독의 상세 페이지에서 하트를 눌러보세요!',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          )
        else
          SizedBox(
            height: 105,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: people.length,
              itemBuilder: (context, index) {
                final person = people[index];
                final name = person['name'] as String? ?? '인물';
                final profileUrl = person['profileUrl'] as String? ?? '';
                final fullProfileUrl = _getFullImageUrl(
                  profileUrl,
                  isPerson: true,
                );

                return GestureDetector(
                  onTap: () => onPersonTap(person),
                  child: Container(
                    width: 78,
                    margin: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHigh,
                          backgroundImage: fullProfileUrl.isNotEmpty
                              ? NetworkImage(fullProfileUrl)
                              : null,
                          child: fullProfileUrl.isEmpty
                              ? Icon(
                                  Icons.person,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                )
                              : null,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          name,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // 6. 내가 쓴 댓글
}

class MyCommentsSection extends StatelessWidget {
  final List<Map<String, dynamic>> comments;
  final ValueChanged<Movie> onMovieTap;
  const MyCommentsSection({
    super.key,
    required this.comments,
    required this.onMovieTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '📝 내가 쓴 댓글',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${comments.length}개',
                style: const TextStyle(
                  color: Color(0xFFA88BFA),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (comments.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 8.0,
            ),
            child: Text(
              '아직 작성한 댓글이 없습니다. 영화 상세화면에서 댓글을 남겨보세요!',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: comments.length,
            itemBuilder: (context, index) {
              final item = comments[index];
              final movieTitle = item['movieTitle'] as String? ?? '영화 제목';
              final posterPath = item['posterPath'] as String?;
              final content = item['content'] as String? ?? '';
              final date = item['date'] as String? ?? '';
              final movieId = int.tryParse(item['movieId'].toString()) ?? 0;
              final fullPosterUrl = _getFullImageUrl(posterPath);

              return GestureDetector(
                onTap: () {
                  if (movieId > 0) {
                    final movieObj = Movie(
                      id: movieId,
                      title: movieTitle,
                      overview: '',
                      posterPath: posterPath,
                      voteAverage: 8.0,
                      releaseDate: '',
                    );
                    onMovieTap(movieObj);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  padding: const EdgeInsets.all(14.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: fullPosterUrl.isNotEmpty
                            ? Image.network(
                                fullPosterUrl,
                                width: 52,
                                height: 74,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, stack) => Container(
                                  width: 52,
                                  height: 74,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                                  child: Icon(
                                    Icons.movie,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                    size: 28,
                                  ),
                                ),
                              )
                            : Container(
                                width: 52,
                                height: 74,
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                child: Icon(
                                  Icons.movie,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                  size: 28,
                                ),
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
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (date.isNotEmpty)
                                  Text(
                                    date,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                      fontSize: 11,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              content,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.88),
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
              );
            },
          ),
      ],
    );
  }
}
