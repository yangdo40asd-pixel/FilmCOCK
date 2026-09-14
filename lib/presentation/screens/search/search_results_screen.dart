import 'package:flutter/material.dart';
import 'package:filmcock_app/data/models/movie_model.dart';
import 'package:filmcock_app/data/models/search_suggestion.dart';
import 'package:filmcock_app/data/services/api_service.dart';
import 'package:filmcock_app/presentation/screens/detail/actor_detail_screen.dart';
import 'package:filmcock_app/presentation/screens/detail/artist_detail_screen.dart';
import 'package:filmcock_app/presentation/screens/detail/movie_detail_screen.dart';
import 'package:filmcock_app/core/errors/app_exception.dart';
import 'package:filmcock_app/presentation/widgets/app_network_image.dart';
import 'package:filmcock_app/presentation/widgets/app_loading_indicator.dart';

class SearchResultsScreen extends StatefulWidget {
  final String searchQuery;
  final int? genreId;

  const SearchResultsScreen({
    super.key,
    required this.searchQuery,
    this.genreId,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<SearchSuggestion> _results = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  Object? _error;
  int _page = 0;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadPage(reset: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isLoadingMore || !_hasMore) return;
    if (_scrollController.position.extentAfter < 320) _loadPage();
  }

  Future<void> _loadPage({bool reset = false}) async {
    final requestId = reset ? ++_requestId : _requestId;
    final nextPage = reset ? 1 : _page + 1;
    if (reset) {
      setState(() {
        _isLoading = true;
        _error = null;
        _hasMore = true;
      });
    } else {
      if (_isLoading || _isLoadingMore || !_hasMore) return;
      setState(() => _isLoadingMore = true);
    }

    try {
      late final List<SearchSuggestion> incoming;
      late final bool hasMore;
      if (widget.genreId == null) {
        final result = await ApiService.searchMultiPage(
          widget.searchQuery,
          page: nextPage,
        );
        incoming = result.items;
        hasMore = result.hasMore;
      } else {
        final movies = await ApiService.getMoviesByGenre(
          widget.genreId!,
          page: nextPage,
        );
        incoming = movies
            .map(
              (movie) => SearchSuggestion(
                id: movie.id,
                title: movie.title,
                type: SuggestionType.movie,
                imageUrl: movie.fullPosterUrl,
                movie: movie,
              ),
            )
            .toList();
        hasMore = movies.isNotEmpty;
      }
      if (!mounted || requestId != _requestId) return;

      final existingKeys = reset
          ? <String>{}
          : _results.map((item) => '${item.type.name}:${item.id}').toSet();
      final unique = incoming.where(
        (item) => existingKeys.add('${item.type.name}:${item.id}'),
      );
      setState(() {
        if (reset) _results.clear();
        _results.addAll(unique);
        _page = nextPage;
        _hasMore = hasMore;
        _isLoading = false;
        _isLoadingMore = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
        if (reset || _results.isEmpty) _error = error;
      });
      if (!reset && _results.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              userMessageForError(error, fallback: '다음 결과를 불러오지 못했습니다.'),
            ),
            action: SnackBarAction(label: '재시도', onPressed: () => _loadPage()),
          ),
        );
      }
    }
  }

  void _openResult(SearchSuggestion result) {
    if (result.isMovie) {
      final movie =
          result.movie ??
          Movie(
            id: result.id,
            title: result.title,
            overview: '',
            posterPath: null,
            voteAverage: 0,
            releaseDate: '',
          );
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie)),
      );
      return;
    }

    final person =
        result.person ??
        Person(id: result.id, name: result.title, knownForDepartment: 'Acting');
    if (person.knownForDepartment == 'Directing') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ArtistDetailScreen(
            artistId: person.id,
            artistName: person.displayName,
            profileUrl: person.fullProfileUrl,
          ),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ActorDetailScreen(actor: person)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('검색 결과')),
      body: _buildBody(colors),
    );
  }

  Widget _buildBody(ColorScheme colors) {
    if (_isLoading) {
      return const Center(
        child: AppLoadingIndicator(label: '검색 결과를 불러오는 중입니다.'),
      );
    }
    if (_error != null) {
      return _SearchStatus(
        icon: Icons.cloud_off_outlined,
        message: userMessageForError(_error, fallback: '검색 결과를 불러오지 못했습니다.'),
        actionLabel: '다시 시도',
        onAction: () => _loadPage(reset: true),
      );
    }
    if (_results.isEmpty) {
      return const _SearchStatus(
        icon: Icons.search_off_outlined,
        message: '일치하는 검색 결과가 없습니다.',
      );
    }

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _results.length + 2,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              "'${widget.searchQuery}' 검색 결과 ${_results.length}건",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          );
        }
        if (index == _results.length + 1) {
          return _isLoadingMore
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: AppLoadingIndicator(label: '다음 검색 결과를 불러오는 중입니다.'),
                  ),
                )
              : const SizedBox(height: 16);
        }

        final result = _results[index - 1];
        return Card(
          child: ListTile(
            onTap: () => _openResult(result),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 48,
                height: 64,
                child: AppNetworkImage(
                  imageUrl: result.imageUrl ?? '',
                  placeholderIcon: result.isMovie
                      ? Icons.movie_outlined
                      : Icons.person_outline,
                ),
              ),
            ),
            title: Text(result.title),
            subtitle: Text(result.metadataLabel),
            trailing: Icon(Icons.chevron_right, color: colors.outline),
          ),
        );
      },
    );
  }
}

class _SearchStatus extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SearchStatus({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: message,
      liveRegion: true,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 48,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 12),
                FilledButton(onPressed: onAction, child: Text(actionLabel!)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
