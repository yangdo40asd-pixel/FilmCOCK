import 'package:flutter/foundation.dart';
import 'package:filmcock_app/shared/domain/models/search_suggestion.dart';
import 'package:filmcock_app/shared/domain/repositories/catalog_repository.dart';

class SearchResultsController extends ChangeNotifier {
  final CatalogRepository catalog;
  final String query;
  final int? genreId;
  final List<SearchSuggestion> _results = [];
  int _page = 0;
  int _requestId = 0;
  bool _disposed = false;
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMore = true;
  Object? error;
  Object? paginationError;

  SearchResultsController({
    required this.catalog,
    required this.query,
    this.genreId,
  });
  List<SearchSuggestion> get results => List.unmodifiable(_results);

  Future<void> load({bool reset = false}) async {
    if (_disposed) return;
    final request = reset ? ++_requestId : _requestId;
    final nextPage = reset ? 1 : _page + 1;
    if (reset) {
      isLoading = true;
      error = null;
      hasMore = true;
    } else {
      if (isLoading || isLoadingMore || !hasMore) return;
      isLoadingMore = true;
    }
    paginationError = null;
    notifyListeners();
    try {
      late final List<SearchSuggestion> incoming;
      late final bool more;
      if (genreId == null) {
        final page = await catalog.searchMultiPage(query, page: nextPage);
        incoming = page.items;
        more = page.hasMore;
      } else {
        final movies = await catalog.getMoviesByGenre(genreId!, page: nextPage);
        incoming = [
          for (final movie in movies)
            SearchSuggestion(
              id: movie.id,
              title: movie.title,
              type: SuggestionType.movie,
              imageUrl: movie.fullPosterUrl,
              movie: movie,
            ),
        ];
        more = movies.isNotEmpty;
      }
      if (_disposed || request != _requestId) return;
      final keys = reset
          ? <String>{}
          : _results.map((item) => '${item.type.name}:${item.id}').toSet();
      final unique = incoming
          .where((item) => keys.add('${item.type.name}:${item.id}'))
          .toList();
      if (reset) _results.clear();
      _results.addAll(unique);
      _page = nextPage;
      hasMore = more;
      isLoading = false;
      isLoadingMore = false;
      error = null;
      notifyListeners();
    } catch (failure) {
      if (_disposed || request != _requestId) return;
      isLoading = false;
      isLoadingMore = false;
      if (reset || _results.isEmpty) {
        error = failure;
      } else {
        paginationError = failure;
      }
      notifyListeners();
    }
  }

  Object? takePaginationError() {
    final value = paginationError;
    paginationError = null;
    return value;
  }

  @override
  void dispose() {
    _disposed = true;
    _requestId++;
    super.dispose();
  }
}
