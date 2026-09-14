import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:filmcock_app/data/repositories/user_settings_repository.dart';
import 'package:filmcock_app/data/models/mbti_info.dart';
import 'package:filmcock_app/data/services/home_prefetch_service.dart';
import 'package:filmcock_app/presentation/screens/onboarding/login_screen.dart';
import 'package:filmcock_app/presentation/screens/onboarding/genre_select_screen.dart';
import 'package:filmcock_app/presentation/screens/onboarding/mbti_select_screen.dart';
import 'package:filmcock_app/presentation/screens/home/main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final UserSettingsRepository _settingsRepository =
      const UserSettingsRepository();
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _warmHomeData() async {
    try {
      await HomePrefetchService.load();
    } catch (_) {
      // 홈 화면의 섹션별 오류 처리와 저장 캐시가 대신 사용된다.
    }
  }

  Future<void> _initializeApp() async {
    final minimumDelay = Future.delayed(const Duration(milliseconds: 1200));
    final homeWarmup = _warmHomeData();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      await _settingsRepository.endGuestSession();
    }
    final onboarding = currentUser == null
        ? null
        : await _settingsRepository.loadOnboarding();
    await minimumDelay;

    if (!mounted) return;

    final Widget destination;
    if (currentUser == null) {
      destination = const LoginScreen();
    } else if (onboarding!.isComplete) {
      destination = const MainScreen();
    } else if (!onboarding.isMbtiDecided) {
      destination = const MbtiSelectScreen();
    } else {
      final savedMbti = await _settingsRepository.loadMbti();
      final mbtiInfo = savedMbti == null ? null : getMbtiInfoById(savedMbti);
      destination = GenreSelectScreen(
        mbtiInfo:
            mbtiInfo ??
            const MbtiInfo(
              id: 'NONE',
              title: '건너뛰기',
              description: '',
              feature: '',
              recommendedGenres: '',
              genreIds: [],
              famousPeople: [],
              svgAsset: '',
            ),
      );
    }

    if (destination is MainScreen) {
      await homeWarmup;
    }
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => destination));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/start.jpeg', fit: BoxFit.cover),
          // Animated loading indicator placed under the neon circle / clapper
          const Align(
            alignment: Alignment(0, 0.74),
            child: SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 3.5,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
