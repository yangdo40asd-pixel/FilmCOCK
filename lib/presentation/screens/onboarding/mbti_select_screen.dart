import 'package:flutter/material.dart';
import 'package:filmcock_app/presentation/screens/home/main_screen.dart';

import 'package:filmcock_app/presentation/screens/onboarding/mbti_panel_screen.dart';

class MbtiSelectScreen extends StatefulWidget {
  const MbtiSelectScreen({super.key});

  @override
  State<MbtiSelectScreen> createState() => _MbtiSelectScreenState();
}

class _MbtiSelectScreenState extends State<MbtiSelectScreen> {
  bool _showPopup = true; // 처음에는 상태창(팝업)이 보이도록 설정

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 상태창이 지워졌을 때의 기본 흰 바탕
      body: Stack(
        children: [
          // 1. 기본 배경 화면 (흰 바탕, 로고, 하단 버튼들)
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 120), // 상단 여백
                // MBTI 로고 이미지
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Image.asset(
                    'assets/images/mbti.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const Spacer(),
                // 하단 버튼 영역
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      // 선택하기 버튼
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            // 다크테마 MBTI 패널 화면으로 이동
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => MbtiPanelScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF32285E), // 진한 보라(남색) 배경
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
                      // 건너뛰기 버튼
                      TextButton(
                        onPressed: () {
                          // 건너뛰기 클릭 시 홈 화면(MainScreen)으로 이동
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const MainScreen(),
                            ),
                          );
                        },
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

          // 2. 상태창 (팝업) 오버레이
          if (_showPopup)
            Container(
              color: Colors.black.withOpacity(0.55), // 배경을 어둡게 처리
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C34), // 팝업창 짙은 배경
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
                            color: Color(0xFF8B5CF6), // 연보라색 텍스트
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
                        // 확인 버튼
                        SizedBox(
                          width: 120,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _showPopup = false; // 확인 클릭 시 상태창 지우기
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6B4EE6), // 밝은 보라색
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
