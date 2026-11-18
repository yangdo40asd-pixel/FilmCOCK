import 'package:filmcock_app/features/chat/domain/chat_plan.dart';
import 'package:filmcock_app/shared/domain/models/movie.dart';

class VerifiedCandidates {
  final List<Movie> movies;
  final List<String> reasons;
  const VerifiedCandidates(this.movies, this.reasons);
}

/// LLM의 후보 제목을 실제 조회 결과와 대조한다. 미확인·중복·제외 작품은 제거한다.
class MovieCandidateVerifier {
  final Future<List<Movie>> Function(String) search;
  const MovieCandidateVerifier({required this.search});

  Future<VerifiedCandidates> verify(
    ChatPlan plan, {
    required Set<int> excluded,
    required Set<int> recent,
  }) async {
    final movies = <Movie>[];
    final reasons = <String>[];
    for (var i = 0; i < plan.candidateTitles.length; i++) {
      final title = plan.candidateTitles[i];
      List<Movie> results;
      try {
        results = await search(title);
      } catch (_) {
        continue;
      }
      Movie? found;
      for (final movie in results) {
        if (_normalize(movie.title) == _normalize(title)) {
          found = movie;
          break;
        }
      }
      if (found == null ||
          excluded.contains(found.id) ||
          recent.contains(found.id) ||
          movies.any((movie) => movie.id == found!.id))
        continue;
      movies.add(found);
      reasons.add(
        i < plan.reasons.length
            ? plan.reasons[i]
            : '도슨트 추천 · 평점 ${found.voteAverage.toStringAsFixed(1)}',
      );
    }
    return VerifiedCandidates(movies, reasons);
  }

  static String _normalize(String text) =>
      text.replaceAll(RegExp(r'[\s:·\-]'), '').toLowerCase();
}
