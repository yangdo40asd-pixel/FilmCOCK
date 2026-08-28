import 'package:flutter/material.dart';
import 'package:filmcock_app/presentation/screens/onboarding/login_screen.dart';
import 'package:filmcock_app/data/services/api_service.dart';

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

    // 2. 초기화해야 할 비동기 작업들 (인기 영화 및 KOFIC 데이터 등 사전 로딩)
    final apiLoad1 = ApiService.getNowPlayingMovies();
    final apiLoad2 = ApiService.getPopularMovies();

    // 두 작업이 모두 끝날 때까지 대기
    await Future.wait([minimumDelay, apiLoad1, apiLoad2]);

    if (!mounted) return;

    // 3. 네비게이션 처리
    // 사용자 요청 흐름에 따라 처음에는 항상 로그인 화면으로 진입하도록 설정
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. 전체 화면을 꽉 채우는 배경 이미지
          Image.asset(
            'assets/images/start.jpeg',
            fit: BoxFit.cover,
          ),
          
          // 2. 텍스트와 로딩이 잘 보이도록 살짝 어두운 오버레이 추가
          Container(
            color: Colors.black.withOpacity(0.3),
          ),
          
          // 3. UI 요소들 (상단 텍스트, 하단 로딩)
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 상단 'FilmCOCK!' 타이틀
                Padding(
                  padding: const EdgeInsets.only(top: 60.0),
                  child: Text(
                    'FilmCOCK!',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6A5ACD), // 메인 보라색
                      letterSpacing: 2.0,
                      shadows: [
                        Shadow(
                          offset: const Offset(2.0, 2.0),
                          blurRadius: 6.0,
                          color: Colors.black.withOpacity(0.8),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // 하단 로딩 스피너
                const Padding(
                  padding: EdgeInsets.only(bottom: 80.0),
                  child: CircularProgressIndicator(
                    color: Color(0xFF6A5ACD), // 메인 보라색
                    strokeWidth: 3.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
