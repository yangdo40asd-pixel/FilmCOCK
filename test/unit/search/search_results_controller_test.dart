import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:filmcock_app/features/search/application/search_results_controller.dart';
import 'package:filmcock_app/shared/domain/models/search_suggestion.dart';
import '../../helpers/fake_catalog_repository.dart';

class DelayedCatalog extends FakeCatalogRepository {
  final List<Completer<SearchResultPage>> requests = [];
  @override
  Future<SearchResultPage> searchMultiPage(String query, {int page = 1}) {
    final request = Completer<SearchResultPage>();
    requests.add(request);
    return request.future;
  }
}

SearchResultPage page(int id) => SearchResultPage(
  items: [SearchSuggestion(id: id, title: '$id', type: SuggestionType.movie)],
  page: 1,
  totalPages: 1,
);

void main() {
  test('늦게 끝난 이전 재검색이 새 결과를 덮어쓰지 않는다', () async {
    final catalog = DelayedCatalog();
    final controller = SearchResultsController(catalog: catalog, query: '영화');
    final first = controller.load(reset: true);
    final second = controller.load(reset: true);
    catalog.requests[1].complete(page(2));
    await second;
    catalog.requests[0].complete(page(1));
    await first;
    expect(controller.results.single.id, 2);
    controller.dispose();
  });
}
