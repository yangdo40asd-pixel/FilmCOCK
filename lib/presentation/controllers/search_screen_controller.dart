import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:filmcock_app/core/errors/app_exception.dart';
import 'package:filmcock_app/data/models/search_suggestion.dart';
import 'package:filmcock_app/data/repositories/search_history_repository.dart';
import 'package:filmcock_app/data/services/api_service.dart';

class SearchScreenController extends ChangeNotifier {
  final SearchHistoryRepository _historyRepository;
  Timer? _debounce;
  int _requestId = 0;
  bool _disposed = false;

  SearchScreenController({
    SearchHistoryRepository historyRepository = const SearchHistoryRepository(),
  }) : _historyRepository = historyRepository;

  List<SearchSuggestion> suggestions = const [];
  List<String> recentSearches = const [];
  bool isLoadingSuggestions = false;
  String? suggestionError;

  Future<void> loadRecentSearches() async {
    final loaded = await _historyRepository.load();
    if (_disposed) return;
    recentSearches = loaded;
    _notify();
  }

  Future<void> addRecentSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    final updated = await _historyRepository.add(trimmed, recentSearches);
    if (_disposed) return;
    recentSearches = updated;
    _notify();
  }

  Future<void> removeRecentSearch(String query) async {
    final updated = await _historyRepository.remove(query, recentSearches);
    if (_disposed) return;
    recentSearches = updated;
    _notify();
  }

  Future<void> clearRecentSearches() async {
    await _historyRepository.clear();
    if (_disposed) return;
    recentSearches = const [];
    _notify();
  }

  void updateQuery(String rawQuery) {
    final query = rawQuery.trim();
    _debounce?.cancel();
    final requestId = ++_requestId;
    if (query.isEmpty) {
      suggestions = const [];
      isLoadingSuggestions = false;
      suggestionError = null;
      _notify();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 250), () async {
      isLoadingSuggestions = true;
      suggestionError = null;
      _notify();
      try {
        final results = await ApiService.getSearchSuggestions(query);
        if (requestId != _requestId) return;
        suggestions = results;
        isLoadingSuggestions = false;
        _notify();
      } catch (error) {
        if (requestId != _requestId) return;
        isLoadingSuggestions = false;
        suggestionError = userMessageForError(
          error,
          fallback: '추천 검색어를 불러오지 못했습니다.',
        );
        _notify();
      }
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _requestId++;
    _debounce?.cancel();
    super.dispose();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }
}
