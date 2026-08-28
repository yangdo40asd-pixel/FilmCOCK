import 'dart:async';
import 'dart:ui';
import 'package:filmcock_app/api_service.dart';
import 'package:flutter/material.dart';
import 'package:filmcock_app/main_screen.dart';
import 'package:filmcock_app/presentation/screens/movie_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MbtiSelectScreen extends StatefulWidget {
  const MbtiSelectScreen({super.key});

  @override
  State<MbtiSelectScreen> createState() => _MbtiSelectScreenState();
}

class _MbtiSelectScreenState extends State<MbtiSelectScreen> {
  // 영화 캐러셀을 위한 상태
  List<Movie> _movies = [];
  bool _isLoading = true;
  late final PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  // MBTI 선택 및 팝업 상태
  String? _selectedMbti;
  // 0: 초기 선택창, 1: 확인창
  int _popupState = 0; // -1: 숨김, 0: 초기창, 1: 확인창

  final List<String> mbtiTypes = [
    'ESFP',
    'ESFJ',
    'INFP',
    'ENTP',
    'ENTJ',
    'ISTP',
    'ISTJ',
    'ISFP',
    'ISFJ',
    'INTP',
    'INTJ',
    'ENFJ',
    'ENFP',
    'ESTP',
    'ESTJ',
    'INFJ',
  ];

  // MBTI 타입별 색상 맵
  final Map<String, Color> mbtiColorMap = {
    'ESFP': const Color(0xFFD3D3D3), // 밝은 회색
    'ESFJ': const Color(0xFFFC6666), // 밝은 빨간색
    'INFP': const Color(0xFF00CED1), // 청록색
    'ENTP': Colors.blue[200]!,
    'ENTJ': Colors.green[200]!,
    'ISTP': Colors.teal[200]!,
    'ISTJ': Colors.cyan[200]!,
    'ISFP': Colors.amber[200]!,
    'ISFJ': Colors.orange[200]!,
    'INTP': Colors.deepPurple[200]!,
    'INTJ': Colors.indigo[200]!,
    'ENFJ': Colors.pink[200]!,
    'ENFP': Colors.lime[200]!,
    'ESTP': Colors.lightGreen[300]!,
    'ESTJ': Colors.brown[200]!,
    'INFJ': Colors.purple[200]!,
  };

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadPopularMovies();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadPopularMovies() async {
    try {
      final movies = await ApiService.getPopularMovies();
      if (mounted) {
        setState(() {
          _movies = movies;
          _isLoading = false;
        });
        _startAutoScroll();
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      print('Failed to load popular movies: $e');
    }
  }

  void _startAutoScroll() {
    _timer?.cancel();
    if (_movies.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
        if (_pageController.hasClients) {
          _currentPage = (_currentPage + 1) % _movies.length;
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  void _showConfirmationPopup() {
    if (_selectedMbti == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('MBTI를 먼저 선택해주세요!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    setState(() {
      _popupState = 1; // 확인창으로 상태 변경
    });
  }

  void _saveAndNavigate(String mbtiToSave) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_mbti', mbtiToSave);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFAFAFAF),
      body: Stack(
        children: [
          // 레이어 1: 배경 (헤더 + 그리드)
          _buildBackgroundLayer(),

          // 레이어 2: 모달 (안내 창)
          // 모달이 열릴 때 배경을 어둡게 하고 블러 처리
          if (_popupState == 0 || _popupState == 1)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
              child: Container(color: Colors.black.withOpacity(0.4)),
            ),

          // 상태에 따라 다른 모달을 중앙에 배치
          if (_popupState == 0)
            Center(child: _buildInitialPopup())
          else if (_popupState == 1)
            Center(child: _buildConfirmationPopup()),
        ],
      ),
    );
  }

  Widget _buildBackgroundLayer() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20.0),
            Container(
              width: double.infinity,
              height: 50.0,
              decoration: BoxDecoration(
                color: const Color(0xFFF9A87D), // 밝은 오렌지색
                border: Border.all(color: const Color(0xFF9370DB), width: 2.5),
              ),
              child: const Center(
                child: Text(
                  'MBTI',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // MBTI 버튼 그리드
            _buildMovieCarousel(),
            _buildMbtiGridSection(),
            // 팝업이 숨겨졌을 때만 하단 버튼 표시
            if (_popupState == -1) _buildBottomActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialPopup() {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.9 > 360
            ? 360
            : double.infinity,
      ),
      child: Material(
        color: const Color(0xFFFFF6EF), // 연한 아이보리
        borderRadius: BorderRadius.circular(12.0),
        elevation: 6.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15.0),
              decoration: const BoxDecoration(
                color: Color(0xFFA2C3A2), // 연한 녹색/회색
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(13.0),
                  topRight: Radius.circular(13.0),
                ),
              ),
              child: const Text(
                '당신의 MBTI는 무엇인가요?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.0,
                  color: Color(0xFF333333),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: 24.0,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 주 버튼
                      ElevatedButton(
                        onPressed: () {
                          // 안내창을 숨김 상태로 변경
                          setState(() => _popupState = -1);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFBFA7FF),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(120, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 3,
                        ),
                        child: const Text(
                          '고르기',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 보조 버튼
                      ElevatedButton(
                        onPressed: () => _saveAndNavigate('skipped'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEEEEEE),
                          foregroundColor: Colors.grey[800],
                          minimumSize: const Size(120, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          '건너뛰기',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  const Text(
                    "잘 모르겠어요",
                    style: TextStyle(fontSize: 12.0, color: Color(0xFF9A9A9A)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 영화 추천 캐러셀
  Widget _buildMovieCarousel() {
    if (_isLoading) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_movies.isEmpty) {
      return const SizedBox(
        height: 300,
        child: Center(child: Text('영화를 불러올 수 없습니다.')),
      );
    }

    return SizedBox(
      height: 300, // 캐러셀 높이 지정
      child: Listener(
        onPointerDown: (_) => _timer?.cancel(),
        onPointerUp: (_) => _startAutoScroll(),
        child: PageView.builder(
          controller: _pageController,
          itemCount: _movies.length,
          onPageChanged: (index) {
            _currentPage = index;
          },
          itemBuilder: (context, index) {
            final movie = _movies[index];
            return Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  movie.fullPosterUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[800],
                    child: const Center(child: Icon(Icons.movie)),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // MBTI 카드 그리드 섹션
  Widget _buildMbtiGridSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
          childAspectRatio: 1.0,
        ),
        itemCount: mbtiTypes.length,
        itemBuilder: (context, index) {
          final type = mbtiTypes[index];
          final isSelected = _selectedMbti == type;
          final color = mbtiColorMap[type] ?? Colors.grey;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedMbti = type;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12.0),
                border: isSelected
                    ? Border.all(color: const Color(0xFF9370DB), width: 3.0)
                    : null,
              ),
              child: Center(
                child: Text(
                  type,
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: color.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 화면 하단에 표시될 '확인' 및 '건너뛰기' 버튼
  Widget _buildBottomActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _showConfirmationPopup, // 최종 확인창 띄우기
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A5ACD),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('확인'),
            ),
          ),
          const SizedBox(height: 12),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _saveAndNavigate('skipped'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[700],
                foregroundColor: Colors.white70,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('건너뛰기'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationPopup() {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.9 > 360
            ? 360
            : double.infinity,
      ),
      child: Material(
        color: const Color(0xFFFFF6EF), // 연한 아이보리
        borderRadius: BorderRadius.circular(12.0),
        elevation: 6.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15.0),
              decoration: const BoxDecoration(
                color: Color(0xFFA2C3A2),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(13.0),
                  topRight: Radius.circular(13.0),
                ),
              ),
              child: Text(
                '${_selectedMbti ?? ''}입니까?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18.0,
                  color: Color(0xFF333333),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: 24.0,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => _saveAndNavigate(_selectedMbti!),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFBFA7FF),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(120, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 3,
                        ),
                        child: const Text(
                          '네, 맞아요',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () => setState(() => _popupState = -1),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEEEEEE),
                          foregroundColor: Colors.grey[800],
                          minimumSize: const Size(120, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          '아니요',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
