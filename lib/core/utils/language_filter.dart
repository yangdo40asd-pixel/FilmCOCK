import 'package:filmcock_app/data/models/movie_model.dart';

class LanguageFilter {
  // 외국어 문자 감지 정규식 (히라가나, 가타카나, 한자, 키릴, 태국어, 아랍어 등)
  static final RegExp _invalidTextPattern = RegExp(
    r'[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FFF\u0400-\u04FF\u0E00-\u0E7F\u0600-\u06FF]',
    unicode: true,
  );

  static bool isValidMovie(Movie movie, {bool isUpcoming = false}) {
    // 1. 내용(overview) 길이 필터링: 비어있거나 너무 짧은 정보는 노출 제외
    if (movie.posterPath == null || movie.posterPath!.isEmpty) {
      return false;
    }

    if (!isUpcoming && movie.overview.trim().length < 10) {
      return false;
    }

    // 2. 제목 필터링: 제목에 허용되지 않은 외국어가 포함된 경우 제외
    if (_invalidTextPattern.hasMatch(movie.title)) {
      return false;
    }

    // 3. 내용 필터링: 줄거리에 번역되지 않은 외국어(원문)가 포함된 경우 제외
    if (_invalidTextPattern.hasMatch(movie.overview)) {
      return false;
    }

    return true;
  }

  // 영화 리스트를 받아 필터링된 깨끗한 한/영 리스트만 반환
  static List<Movie> filterMovies(List<Movie> movies, {bool isUpcoming = false}) {
    return movies.where((movie) => isValidMovie(movie, isUpcoming: isUpcoming)).toList();
  }
}
