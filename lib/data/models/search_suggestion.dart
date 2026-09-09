import 'package:filmcock_app/data/models/movie_model.dart';

enum SuggestionType { movie, person }

class SearchSuggestion {
  final int id;
  final String title;
  final SuggestionType type;
  final String? imageUrl;
  final Movie? movie;
  final Person? person;

  SearchSuggestion({
    required this.id,
    required this.title,
    required this.type,
    this.imageUrl,
    this.movie,
    this.person,
  });

  bool get isMovie => type == SuggestionType.movie;
  String get typeLabel => isMovie ? '영화' : '인물';
}
