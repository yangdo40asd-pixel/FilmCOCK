import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:filmcock_app/firebase_options.dart';
import 'package:filmcock_app/presentation/screens/splash/splash_screen.dart';
import 'package:filmcock_app/core/theme/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 파이어베이스 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 테마 상태 초기화
  await ThemeController.init();

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
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'FilmCOCK!',
          themeMode: mode,
          theme: ThemeController.lightTheme,
          darkTheme: ThemeController.darkTheme,
          home: SplashScreen(savedMbti: savedMbti),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
