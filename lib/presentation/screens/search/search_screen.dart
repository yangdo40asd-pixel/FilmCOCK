import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:filmcock_app/data/models/movie_model.dart';
import 'package:filmcock_app/data/models/search_suggestion.dart';
import 'package:filmcock_app/data/services/api_service.dart';
import 'package:filmcock_app/presentation/screens/detail/actor_detail_screen.dart';
import 'package:filmcock_app/presentation/screens/detail/artist_detail_screen.dart';
import 'package:filmcock_app/presentation/screens/detail/movie_detail_screen.dart';
import 'package:filmcock_app/presentation/screens/search/search_results_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  Timer? _debounce;
  List<SearchSuggestion> _suggestions = [];
  bool _isLoadingSuggestions = false;

  List<String> _recentSearches = [];
  Future<List<Movie>>? _popularMoviesFuture;

  static const List<String> _genreKeywords = [
    '액션', '스릴러', '어드벤처', '코미디',
    '판타지', '공포', '로맨스', '애니메이션',
    '범죄', '다큐멘터리', '드라마', '가족',
    '미스터리', 'SF', '좀비', '히어로',
  ];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _popularMoviesFuture = ApiService.getPopularMovies();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // --- 최근 검색어 관리 ---
  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('recent_searches') ?? ['장동건', '봉준호'];
    if (mounted) {
      setState(() {
        _recentSearches = saved;
      });
    }
  }

  Future<void> _addRecentSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final updated = List<String>.from(_recentSearches);
    updated.remove(trimmed);
    updated.insert(0, trimmed);
    if (updated.length > 10) {
      updated.removeRange(10, updated.length);
    }

    await prefs.setStringList('recent_searches', updated);
    if (mounted) {
      setState(() {
        _recentSearches = updated;
      });
    }
  }

  Future<void> _removeRecentSearch(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final updated = List<String>.from(_recentSearches)..remove(query);
    await prefs.setStringList('recent_searches', updated);
    if (mounted) {
      setState(() {
        _recentSearches = updated;
      });
    }
  }

  Future<void> _clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recent_searches');
    if (mounted) {
      setState(() {
        _recentSearches = [];
      });
    }
  }

  // --- 실시간 추천 검색어 검색 (Debounce 250ms) ---
  void _onSearchChanged() {
    final query = _searchController.text.trim();
    _debounce?.cancel();

    if (query.isEmpty) {
      if (mounted) {
        setState(() {
          _suggestions = [];
          _isLoadingSuggestions = false;
        });
      }
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 250), () async {
      if (!mounted) return;
      setState(() {
        _isLoadingSuggestions = true;
      });

      try {
        final results = await ApiService.getSearchSuggestions(query);
        if (mounted) {
          setState(() {
            _suggestions = results;
            _isLoadingSuggestions = false;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _isLoadingSuggestions = false;
          });
        }
      }
    });
  }

  // 검색 실행 및 결과 화면 이동
  void _submitSearch(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    _addRecentSearch(trimmed);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SearchResultsScreen(searchQuery: trimmed),
      ),
    );
  }

  // 추천 검색어 항목 클릭
  void _onSuggestionTap(SearchSuggestion item) {
    _addRecentSearch(item.title);

    if (item.isMovie) {
      final movie = item.movie ??
          Movie(
            id: item.id,
            title: item.title,
            overview: '',
            posterPath: item.imageUrl,
            releaseDate: '',
            voteAverage: 0.0,
          );
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MovieDetailScreen(movie: movie),
        ),
      );
    } else {
      final person = item.person ??
          Person(
            id: item.id,
            name: item.title,
            profilePath: item.imageUrl,
            knownForDepartment: 'Acting',
          );

      if (person.knownForDepartment == 'Directing') {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ArtistDetailScreen(
              artistId: person.id,
              artistName: person.name,
              profileUrl: person.fullProfileUrl,
            ),
          ),
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ActorDetailScreen(actor: person),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isQuerying = _searchController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF16161A),
      body: SafeArea(
        child: Column(
          children: [
            // 1. 상단 검색창
            _buildSearchBar(),

            // 2. 본문 (검색어 입력 여부에 따른 분기)
            Expanded(
              child: isQuerying
                  ? _buildSuggestionView()
                  : _buildDefaultSearchView(),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 상단 검색창 위젯
  // ============================================================
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Container(
        height: 50.0,
        decoration: BoxDecoration(
          color: const Color(0xFF282830),
          borderRadius: BorderRadius.circular(25.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            const Icon(Icons.search, color: Color(0xFF9E9E9E), size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: const InputDecoration(
                  hintText: '제목, 배우 검색...',
                  hintStyle: TextStyle(color: Color(0xFF8E8E93), fontSize: 15),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: _submitSearch,
              ),
            ),
            if (_searchController.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  setState(() {
                    _suggestions = [];
                  });
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.0),
                  child: Icon(Icons.close, color: Color(0xFF9E9E9E), size: 20),
                ),
              ),
            const SizedBox(width: 4),
            const Icon(Icons.mic_none_outlined, color: Color(0xFF9E9E9E), size: 24),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // [State 1] 추천 검색어 목록 뷰 (참고 이미지 1)
  // ============================================================
  Widget _buildSuggestionView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 12.0),
          child: Text(
            '추천 검색어',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ),
        if (_isLoadingSuggestions)
          const Expanded(
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
              ),
            ),
          )
        else if (_suggestions.isEmpty)
          const Expanded(
            child: Center(
              child: Text(
                '일치하는 추천 검색어가 없습니다.',
                style: TextStyle(color: Colors.white54, fontSize: 15),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              itemCount: _suggestions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6.0),
              itemBuilder: (context, index) {
                final item = _suggestions[index];
                return InkWell(
                  onTap: () => _onSuggestionTap(item),
                  borderRadius: BorderRadius.circular(10.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
                    child: Row(
                      children: [
                        // 포스터 / 인물 썸네일
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Container(
                            width: 52,
                            height: 68,
                            color: const Color(0xFF282832),
                            child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                                ? Image.network(
                                    item.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _buildFallbackIcon(item.isMovie),
                                  )
                                : _buildFallbackIcon(item.isMovie),
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        // 제목 및 분류
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                item.typeLabel,
                                style: const TextStyle(
                                  color: Color(0xFF8E8E93),
                                  fontSize: 13.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildFallbackIcon(bool isMovie) {
    return Center(
      child: Icon(
        isMovie ? Icons.movie_outlined : Icons.person_outline,
        color: Colors.white38,
        size: 28,
      ),
    );
  }

  // ============================================================
  // [State 2] 기본 검색 메인 뷰 (참고 이미지 2)
  // ============================================================
  Widget _buildDefaultSearchView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 최근 검색어 섹션
          _buildRecentSearchesSection(),
          const SizedBox(height: 28.0),

          // 2. 장르 & 키워드 섹션
          _buildGenreKeywordsSection(),
          const SizedBox(height: 32.0),

          // 3. 인기 영화 섹션
          _buildPopularMoviesSection(),
        ],
      ),
    );
  }

  // --- 최근 검색어 ---
  Widget _buildRecentSearchesSection() {
    if (_recentSearches.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18.0, 16.0, 18.0, 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '최근 검색어',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              GestureDetector(
                onTap: _clearRecentSearches,
                child: const Text(
                  '전체 삭제',
                  style: TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 14.0,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Wrap(
            spacing: 10.0,
            runSpacing: 10.0,
            children: _recentSearches.map((query) {
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF282832),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _searchController.text = query;
                        _submitSearch(query);
                      },
                      child: Text(
                        query,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    GestureDetector(
                      onTap: () => _removeRecentSearch(query),
                      child: const Icon(
                        Icons.close,
                        size: 16.0,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // --- 장르 & 키워드 ---
  Widget _buildGenreKeywordsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(18.0, 0, 18.0, 14.0),
          child: Text(
            '장르 & 키워드',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _genreKeywords.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
              childAspectRatio: 2.2,
            ),
            itemBuilder: (context, index) {
              final keyword = _genreKeywords[index];
              return InkWell(
                onTap: () {
                  _searchController.text = keyword;
                  _submitSearch(keyword);
                },
                borderRadius: BorderRadius.circular(10.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF282832),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Center(
                    child: Text(
                      keyword,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- 인기 영화 ---
  Widget _buildPopularMoviesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(18.0, 0, 18.0, 14.0),
          child: Text(
            '인기 영화',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ),
        SizedBox(
          height: 200.0,
          child: FutureBuilder<List<Movie>>(
            future: _popularMoviesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                  ),
                );
              }
              final movies = snapshot.data ?? [];
              if (movies.isEmpty) {
                return const Center(
                  child: Text('인기 영화 데이터를 불러올 수 없습니다.',
                      style: TextStyle(color: Colors.white54)),
                );
              }

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: movies.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12.0),
                itemBuilder: (context, index) {
                  final movie = movies[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MovieDetailScreen(movie: movie),
                        ),
                      );
                    },
                    child: SizedBox(
                      width: 110.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Container(
                                color: const Color(0xFF282832),
                                width: double.infinity,
                                child: movie.fullPosterUrl.isNotEmpty
                                    ? Image.network(
                                        movie.fullPosterUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Center(
                                          child: Icon(Icons.movie, color: Colors.white38),
                                        ),
                                      )
                                    : const Center(
                                        child: Icon(Icons.movie, color: Colors.white38),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            movie.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13.0,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
