import 'package:flutter/material.dart';
import 'package:filmcock_app/presentation/screens/onboarding/login_screen.dart';
import 'package:filmcock_app/data/services/home_prefetch_service.dart';

class SplashScreen extends StatefulWidget {
  final String? savedMbti;

  const SplashScreen({super.key, this.savedMbti});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 1. 최소 스플래시 노출 시간 보장 (2초) - UI/UX 개선
    final minimumDelay = Future.delayed(const Duration(seconds: 2));

    // 홈에서 사용할 영화·인물 데이터를 모두 준비한 뒤 다음 화면으로 이동한다.
    await Future.wait([minimumDelay, HomePrefetchService.load()]);

    if (!mounted) return;

    // 3. 네비게이션 처리
    // 사용자 요청 흐름에 따라 처음에는 항상 로그인 화면으로 진입하도록 설정
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [Image.asset('assets/images/start.jpeg', fit: BoxFit.cover)],
      ),
    );
  }
}
