import 'package:filmcock_app/shared/domain/models/catalog_models.dart';
import 'package:filmcock_app/shared/domain/repositories/catalog_repository.dart';

/// 상세 화면의 독립 조회를 묶는다. 실패 UI와 예고편 플레이어는 화면이 담당한다.
class MovieDetailsController {
  final Future<Movie> movie;
  final Future<List<Person>> credits;
  final Future<List<Movie>> recommendations;
  final Future<List<Video>> videos;

  MovieDetailsController({
    required int movieId,
    required CatalogRepository catalog,
  }) : movie = catalog.getMovieDetail(movieId),
       credits = catalog.getMovieCredits(movieId),
       recommendations = catalog.getRecommendedMovies(movieId),
       videos = catalog.getMovieVideos(movieId);
}
