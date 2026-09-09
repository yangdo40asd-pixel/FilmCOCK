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
    final minimumDelay = Future.delayed(const Duration(seconds: 2));
    await Future.wait([minimumDelay, HomePrefetchService.load()]);

    if (!mounted) return;

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
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
