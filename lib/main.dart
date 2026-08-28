import 'package:filmcock_app/presentation/screens/mbti_select_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// 1. 방금 설치한 패키지를 import
import 'package:shared_preferences/shared_preferences.dart';

// 2. main 함수를 async로 변경
void main() async {
  // 3. Flutter 앱이 실행되기 전에 네이티브 코드를 초기화하도록 보장
  WidgetsFlutterBinding.ensureInitialized();

  // 4. 기기 저장소에서 SharedPreferences 인스턴스를 가져옴 (비동기)
  final prefs = await SharedPreferences.getInstance();

  // 5. 'user_mbti'라는 키로 저장된 값이 있는지 확인
  final String? savedMbti = prefs.getString('user_mbti');

  // 6. runApp을 실행할 때, 저장된 MBTI 값을 전달
  runApp(MyApp(savedMbti: savedMbti));
}

class MyApp extends StatelessWidget {
  // 7. savedMbti 값을 받을 변수
  final String? savedMbti;

  const MyApp({
    super.key,
    this.savedMbti, // 생성자를 통해 값을 받음
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FilmCOCK!',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF6A5ACD), // 메인 보라색
        scaffoldBackgroundColor: const Color(0xFF1A1A1A), // 좀 더 부드러운 검정
        fontFamily: GoogleFonts.notoSansKr().fontFamily,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A1A),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1F1F1F),
          selectedItemColor: Color(0xFF6A5ACD), // 메인 보라색
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF6A5ACD), // 텍스트 버튼 색상 통일
          ),
        ),
      ),
      // --- 수정된 부분: 프로토타입을 위해 항상 온보딩 화면으로 시작 ---
      home: const MbtiSelectScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
