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
  String get typeLabel {
    if (isMovie) return '영화';
    return person?.knownForDepartment == 'Directing' ? '감독' : '배우';
  }

  String get metadataLabel {
    if (isMovie) {
      final date = movie?.releaseDate ?? '';
      final year = date.length >= 4 ? date.substring(0, 4) : '';
      return year.isEmpty ? typeLabel : '$typeLabel · $year';
    }
    final originalName = person?.originalName.trim() ?? '';
    if (originalName.isEmpty || originalName == title) return typeLabel;
    return '$typeLabel · $originalName';
  }
}

class SearchResultPage {
  final List<SearchSuggestion> items;
  final int page;
  final int totalPages;

  const SearchResultPage({
    required this.items,
    required this.page,
    required this.totalPages,
  });

  bool get hasMore => page < totalPages;
}
