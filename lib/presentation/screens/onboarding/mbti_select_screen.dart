import 'package:flutter/material.dart';
import 'package:filmcock_app/data/models/mbti_info.dart';
import 'package:filmcock_app/presentation/screens/onboarding/genre_select_screen.dart';
import 'package:filmcock_app/presentation/screens/onboarding/mbti_panel_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================
// MBTI 시작 화면 (안내 팝업 + 흔백 배경)
// ============================================================
class MbtiSelectScreen extends StatefulWidget {
  const MbtiSelectScreen({super.key});

  @override
  State<MbtiSelectScreen> createState() => _MbtiSelectScreenState();
}

class _MbtiSelectScreenState extends State<MbtiSelectScreen> {
  bool _showPopup = true;

  // [건너뛰기] 버튼: 안내 팝업 먼저
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
                '건너뛰시겠습니까?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '(선호장르 화면으로 넘어갑니다)',
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
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('user_mbti');
                      if (!mounted || !dialogContext.mounted) return;
                      Navigator.of(dialogContext).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const GenreSelectScreen(
                            mbtiInfo: MbtiInfo(
                              id: 'NONE',
                              title: '건너뛰기',
                              description: '',
                              feature: '',
                              recommendedGenres: '',
                              genreIds: [],
                              famousPeople: [],
                              svgAsset: '',
                            ),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
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
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 120),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Image.asset(
                    'assets/images/mbti.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => MbtiPanelScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF32285E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            '선택하기',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white54,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _onSkip,
                        child: const Text(
                          '건너뛰기',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_showPopup)
            Container(
              color: Colors.black.withValues(alpha: 0.55),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 32.0,
                      horizontal: 24.0,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C34),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'MBTI 기반 영화 추천',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8B5CF6),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          '16가지 성격 유형에 따라\n나에게 딱 맞는 영화를 추천해드려요!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: 120,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() => _showPopup = false);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6B4EE6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              '확인',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
