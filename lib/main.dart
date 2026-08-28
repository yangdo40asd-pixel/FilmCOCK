import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:filmcock_app/firebase_options.dart';
import 'package:filmcock_app/presentation/screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 파이어베이스 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();
  final String? savedMbti = prefs.getString('user_mbti');

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
      // 스플래시 화면으로 첫 시작 변경
      home: SplashScreen(savedMbti: savedMbti),
      debugShowCheckedModeBanner: false,
    );
  }
}
