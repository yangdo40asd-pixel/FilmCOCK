import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:filmcock_app/data/models/mbti_info.dart';
import 'package:filmcock_app/data/services/api_service.dart';
import 'package:filmcock_app/data/models/movie_model.dart';
import 'package:filmcock_app/presentation/screens/onboarding/genre_select_screen.dart';

class MbtiDetailScreen extends StatefulWidget {
  final MbtiInfo mbtiInfo;
  const MbtiDetailScreen({super.key, required this.mbtiInfo});
  @override
  State<MbtiDetailScreen> createState() => _MbtiDetailScreenState();
}

class _MbtiDetailScreenState extends State<MbtiDetailScreen> {
  List<Movie> _recommendedMovies = [];
  bool _isLoading = true;
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;

  static const Map<String, int> _genreIdMap = {
    'action': 28, 'adventure': 12, 'animation': 16, 'comedy': 35,
    'crime': 80, 'documentary': 99, 'drama': 18, 'family': 10751,
    'fantasy': 14, 'history': 36, 'horror': 27, 'music': 10402,
    'mystery': 9648, 'romance': 10749, 'sf': 878, 'sports': 10402,
    'thriller': 53, 'war': 10752,
  };

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadMovies() async {
    try {
      final firstGenreId = widget.mbtiInfo.genreIds.isNotEmpty
          ? _genreIdMap[widget.mbtiInfo.genreIds.first] ?? 28
          : 28;
      final movies = await ApiService.getMoviesByGenre(firstGenreId);
      if (mounted) {
        setState(() {
          _recommendedMovies = movies.take(8).toList();
          _isLoading = false;
        });
        _startAutoScroll();
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startAutoScroll() {
    _timer?.cancel();
    if (_recommendedMovies.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 4), (_) {
        if (_pageController.hasClients && mounted) {
          _currentPage = (_currentPage + 1) % _recommendedMovies.length;
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  // [수정 5] MBTI 확인 팝업
  void _showMbtiConfirmDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (dialogContext) => Dialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'MBTI 확인',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    height: 1.6,
                  ),
                  children: [
                    const TextSpan(text: '선택한 MBTI '),
                    TextSpan(
                      text: widget.mbtiInfo.id,
                      style: const TextStyle(
                        color: Color(0xFF8B5CF6),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const TextSpan(text: '가 맞습니까?'),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) =>
                            GenreSelectScreen(mbtiInfo: widget.mbtiInfo),
                      ));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Text(
                      '예',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text(
                      '아니오',
                      style: TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mbti = widget.mbtiInfo;
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // [수정 3,4] 영화 배너 캐러셀 (SVG와 완전 분리, 스와이프 가능)
                _buildMovieBannerCarousel(),
                // [수정 3] SVG 아이콘 독립 섹션
                _buildSvgIconSection(mbti),
                _buildIdentitySection(mbti),
                _buildInfoBox(title: '특징', content: mbti.feature),
                _buildInfoBox(title: '추천 장르', content: mbti.recommendedGenres),
                // [수정 2] 올바른 추천 영화 타이틀
                _buildMovieSection(mbti),
                _buildFamousPeopleSection(mbti),
                const SizedBox(height: 110),
              ],
            ),
          ),
          // [수정 1] 완전 불투명 하단 버튼
          _buildBottomButtons(),
        ],
      ),
    );
  }

  // [수정 3,4] 캐러셀 배너 - SVG 없음, 스와이프 가능
  Widget _buildMovieBannerCarousel() {
    if (_isLoading) {
      return Container(
        height: 220,
        color: const Color(0xFF2C2C3E),
        child: const Center(
            child: CircularProgressIndicator(color: Color(0xFF8B5CF6))),
      );
    }
    if (_recommendedMovies.isEmpty) {
      return Container(
        height: 220,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4A1E9E), Color(0xFF1A1A2E)],
          ),
        ),
      );
    }
    return SizedBox(
      height: 220,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _recommendedMovies.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              final movie = _recommendedMovies[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    movie.fullPosterUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: const Color(0xFF2C2C3E)),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                        stops: const [0.4, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 32,
                    left: 16,
                    right: 60,
                    child: Text(
                      movie.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          // 페이지 인디케이터
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _recommendedMovies.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentPage == i ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _currentPage == i
                        ? const Color(0xFF8B5CF6)
                        : Colors.white38,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // [수정 3] SVG 아이콘 완전 독립 섹션 (배너와 분리)
  Widget _buildSvgIconSection(MbtiInfo mbti) {
    return Container(
      color: const Color(0xFF1A1A2E),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Container(
          width: 110,
          height: 110,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SvgPicture.asset(mbti.svgAsset, fit: BoxFit.contain),
        ),
      ),
    );
  }

  Widget _buildIdentitySection(MbtiInfo mbti) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mbti.id,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8B5CF6),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            mbti.title,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            mbti.description,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8B5CF6),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C3E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              content,
              style: const TextStyle(
                  fontSize: 14, color: Colors.white, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }

  // [수정 2] "ISFP를 위한 추천 영화" 형태로 출력
  Widget _buildMovieSection(MbtiInfo mbti) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              '${mbti.id}를 위한 추천 영화',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                  child: CircularProgressIndicator(
                      color: Color(0xFF8B5CF6))),
            )
          else
            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _recommendedMovies.length,
                itemBuilder: (context, index) {
                  final movie = _recommendedMovies[index];
                  return Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              movie.fullPosterUrl,
                              fit: BoxFit.cover,
                              width: 100,
                              errorBuilder: (_, __, ___) => Container(
                                color: const Color(0xFF2C2C3E),
                                child: const Icon(Icons.movie,
                                    color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          movie.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 11, color: Colors.white70),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFamousPeopleSection(MbtiInfo mbti) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '대표 인물',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          const SizedBox(height: 12),
          ...mbti.famousPeople.map(
            (person) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  const Icon(Icons.person, color: Colors.grey, size: 20),
                  const SizedBox(width: 12),
                  Text(person,
                      style: const TextStyle(
                          fontSize: 15, color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // [수정 1] 완전 불투명 단색 배경 버튼 바
  Widget _buildBottomButtons() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        color: const Color(0xFF1A1A2E),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                      color: Color(0xFF8B5CF6), width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  '뒤로가기',
                  style: TextStyle(
                      color: Color(0xFF8B5CF6),
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: ElevatedButton(
                onPressed: _showMbtiConfirmDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  '확인',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
