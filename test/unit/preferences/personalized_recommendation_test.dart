import 'package:flutter_test/flutter_test.dart';
import 'package:filmcock_app/features/recommendations/application/personalized_recommendation_service.dart';
import 'package:filmcock_app/shared/domain/models/movie.dart';
import '../../helpers/fake_catalog_repository.dart';

void main() {
  test('여러 장르에서 돌아온 같은 영화는 카드 한 개로 합친다', () async {
    final catalog = FakeCatalogRepository();
    final result = await PersonalizedRecommendationService.load(
      mbti: 'ISTJ',
      genres: ['crime', 'history', 'drama'],
      fallback: const [],
      catalog: catalog,
      excludeSaved: (movies) async => movies.toList(),
    );
    expect(catalog.genreQueries.length, 3);
    expect(
      result.movies.map((movie) => movie.id).toSet().length,
      result.movies.length,
    );
    expect(result.movies.length, 1);
  });

  test('장르별 조회가 모두 비면 fallback에서도 저장한 작품을 제외한다', () async {
    final catalog = FakeCatalogRepository(movies: const []);
    final result = await PersonalizedRecommendationService.load(
      mbti: 'ISTJ',
      genres: const [],
      fallback: [
        Movie(
          id: 1,
          title: '저장됨',
          overview: '',
          voteAverage: 8,
          releaseDate: '',
        ),
        Movie(
          id: 2,
          title: '새 작품',
          overview: '',
          voteAverage: 8,
          releaseDate: '',
        ),
      ],
      catalog: catalog,
      excludeSaved: (movies) async =>
          movies.where((movie) => movie.id != 1).toList(),
    );
    expect(result.movies.map((movie) => movie.id), [2]);
  });
}
