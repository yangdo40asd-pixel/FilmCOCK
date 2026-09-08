import 'package:flutter/material.dart';
// 1. shared_preferences 패키지를 import
import 'package:shared_preferences/shared_preferences.dart';
import 'package:filmcock_app/data/models/mbti_info.dart';
import 'package:filmcock_app/presentation/screens/onboarding/genre_select_screen.dart';

class MbtiScreen extends StatefulWidget {
  const MbtiScreen({super.key});

  @override
  State<MbtiScreen> createState() => _MbtiScreenState();
}

class _MbtiScreenState extends State<MbtiScreen> {
  String? _selectedMbti;

  // 2. 화면 이동 함수를 async로 변경하고, 저장할 값을 받도록 수정
  void _navigateToGenre(BuildContext context, {String? mbtiToSave}) async {
    final prefs = await SharedPreferences.getInstance();
    if (mbtiToSave != null) {
      await prefs.setString('user_mbti', mbtiToSave);
    }

    if (mounted) {
      MbtiInfo mbtiInfo = const MbtiInfo(
        id: 'NONE',
        title: '',
        description: '',
        feature: '',
        recommendedGenres: '',
        genreIds: [],
        famousPeople: [],
        svgAsset: '',
      );
      if (mbtiToSave != null &&
          mbtiToSave != 'skipped' &&
          mbtiToSave != 'NONE') {
        final found = getMbtiInfoById(mbtiToSave);
        if (found != null) mbtiInfo = found;
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => GenreSelectScreen(mbtiInfo: mbtiInfo),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... (build 메서드의 상단 부분은 이전과 동일) ...
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
      'ENFP',
      'ENFJ',
      'ESTP',
      'ESTJ',
      'INFJ',
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              const Text(
                '당신의 MBTI는 무엇인가요?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 12.0,
                    runSpacing: 12.0,
                    alignment: WrapAlignment.center,
                    children: mbtiTypes.map((type) {
                      final bool isSelected = _selectedMbti == type;

                      return OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _selectedMbti = type;
                          });
                          ScaffoldMessenger.of(context).removeCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$type가 선택되었습니다.'),
                              duration: const Duration(seconds: 1),
                              backgroundColor: Colors.purpleAccent,
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: isSelected
                              ? Colors.purpleAccent
                              : Colors.transparent,
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: isSelected
                                ? Colors.purpleAccent
                                : Colors.grey,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        child: Text(type),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // --- '고르기' 버튼 수정 ---
              ElevatedButton(
                onPressed: () {
                  // 7. 선택한 MBTI 값을 저장하도록 전달
                  _navigateToGenre(context, mbtiToSave: _selectedMbti);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  '고르기',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 12),

              // --- '건너뛰기' 버튼 수정 ---
              TextButton(
                onPressed: () {
                  // 건너뛰기는 MBTI를 저장하지 않고 인기 영화 추천으로 진입한다.
                  _navigateToGenre(context);
                },
                child: const Text(
                  '건너뛰기',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
