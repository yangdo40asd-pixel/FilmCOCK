import 'package:flutter/material.dart';
import 'package:filmcock_app/data/models/mbti_info.dart';
import 'package:filmcock_app/presentation/screens/home/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GenreItem {
  final String id;
  final String label;
  final Color color;
  bool isSelected;

  GenreItem({
    required this.id,
    required this.label,
    required this.color,
    this.isSelected = false,
  });
}

// ============================================================
// 선호 장르 선택 화면
// 진입: MbtiDetailScreen [확인] 버튼
// 진출: [확인] 팝업 네 -> MainScreen / [건너뛰기] 팝업 네 -> MainScreen
// ============================================================
class GenreSelectScreen extends StatefulWidget {
  final MbtiInfo mbtiInfo;
  const GenreSelectScreen({super.key, required this.mbtiInfo});

  @override
  State<GenreSelectScreen> createState() => _GenreSelectScreenState();
}

class _GenreSelectScreenState extends State<GenreSelectScreen> {
  late List<GenreItem> _genres;

  @override
  void initState() {
    super.initState();
    _genres = _buildGenreList();
    for (final genre in _genres) {
      if (widget.mbtiInfo.genreIds.contains(genre.id)) {
        genre.isSelected = true;
      }
    }
  }

  List<GenreItem> _buildGenreList() {
    return [
      GenreItem(id: 'action',      label: '액션',      color: const Color(0xFFEF4444)),
      GenreItem(id: 'adventure',   label: '모험',      color: const Color(0xFF3B82F6)),
      GenreItem(id: 'animation',   label: '애니메이션', color: const Color(0xFF06B6D4)),
      GenreItem(id: 'comedy',      label: '코미디',    color: const Color(0xFFF59E0B)),
      GenreItem(id: 'crime',       label: '범죄',      color: const Color(0xFF8B5CF6)),
      GenreItem(id: 'documentary', label: '다큐멘터리', color: const Color(0xFF6B7280)),
      GenreItem(id: 'drama',       label: '드라마',    color: const Color(0xFF10B981)),
      GenreItem(id: 'family',      label: '가족',      color: const Color(0xFFF97316)),
      GenreItem(id: 'fantasy',     label: '판타지',    color: const Color(0xFF7C3AED)),
      GenreItem(id: 'history',     label: '역사',      color: const Color(0xFF78716C)),
      GenreItem(id: 'horror',      label: '공포',      color: const Color(0xFF1F2937)),
      GenreItem(id: 'music',       label: '음악',      color: const Color(0xFFEC4899)),
      GenreItem(id: 'mystery',     label: '미스터리',  color: const Color(0xFF374151)),
      GenreItem(id: 'romance',     label: '로맨스',    color: const Color(0xFFF43F5E)),
      GenreItem(id: 'sf',          label: 'SF',        color: const Color(0xFF0EA5E9)),
      GenreItem(id: 'sports',      label: '스포츠',    color: const Color(0xFF22C55E)),
      GenreItem(id: 'thriller',    label: '스릴러',    color: const Color(0xFF111827)),
      GenreItem(id: 'war',         label: '전쟁',      color: const Color(0xFF4B5563)),
    ];
  }

  List<GenreItem> get _selectedGenres =>
      _genres.where((g) => g.isSelected).toList();

  // [확인] 버튼: 장르 확인 팝업 (네 먼저, 아니오 두번째)
  void _onConfirm() {
    if (_selectedGenres.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('장르를 하나 이상 선택해주세요!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    final selectedLabels = _selectedGenres.map((g) => g.label).join(', ');
    _showConfirmDialog(selectedLabels);
  }

  void _showConfirmDialog(String selectedLabels) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (dialogContext) => Dialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '선택 확인',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '선택하신 장르($selectedLabels)가 맞습니까?',
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // [1] 네 먼저
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.of(dialogContext).pop();
                      await _saveAndNavigate();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Text(
                      '네',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // [2] 아니오 두번째
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

  // [건너뛰기] 버튼: 안내 팝업 먼저 표시
  
  Future<void> _saveAndNavigate() async {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  void _onSkip() {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (dialogContext) => Dialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '장르 선택 건너뛰기',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '선호 장르 설정을 건너뛰시겠습니까?\n(MBTI 추천만 제공됩니다.)',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white70,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const MainScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text(
                      '네',
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
                      '아니요',
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
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 4),
              child: Text(
                '선호 장르 선택',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '좀아하는 장르를 선택해주세요 (다중 선택 가능)',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Text(
                '▶ ${widget.mbtiInfo.id} 추천 장르가 기본으로 선택되었습니다.',
                style: const TextStyle(fontSize: 13, color: Color(0xFFFBBF24)),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.2,
                ),
                itemCount: _genres.length,
                itemBuilder: (context, index) {
                  final genre = _genres[index];
                  return GestureDetector(
                    onTap: () =>
                        setState(() => genre.isSelected = !genre.isSelected),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: genre.isSelected
                            ? genre.color
                            : const Color(0xFF2C2C3E),
                        borderRadius: BorderRadius.circular(12),
                        border: genre.isSelected
                            ? Border.all(
                                color: genre.color.withValues(alpha: 0.8),
                                width: 2)
                            : null,
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Text(
                              genre.label,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: genre.isSelected
                                    ? Colors.white
                                    : Colors.white54,
                              ),
                            ),
                          ),
                          if (genre.isSelected)
                            const Positioned(
                              top: 8,
                              right: 8,
                              child: Icon(Icons.check_circle,
                                  color: Colors.white, size: 18),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: OutlinedButton(
                      // [건너뛰기] -> 안내 팝업 먼저
                      onPressed: _onSkip,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white30),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text(
                        '건너뛰기',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: ElevatedButton(
                      onPressed: _onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22C55E),
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
          ],
        ),
      ),
    );
  }
}
