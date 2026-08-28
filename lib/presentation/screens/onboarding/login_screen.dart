import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:filmcock_app/presentation/screens/onboarding/mbti_select_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _signInWithGoogle() async {
    try {
      // 1. 구글 계정 선택 팝업 노출 (웹/안드로이드 등에서 작동)
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return; // 사용자가 중간에 창을 닫음
      }

      // 2. 구글 인증 정보 가져오기
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 3. 파이어베이스 Auth로 로그인 처리
      await _auth.signInWithCredential(credential);

      if (!mounted) return;
      // 4. 로그인 성공 시 MBTI 화면으로 이동
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MbtiSelectScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('구글 로그인 실패: $e')),
      );
    }
  }

  void _skipLogin() {
    // 비회원으로 시작하기: 즉시 MBTI 선택 화면으로 건너뜀
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MbtiSelectScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A), // 앱 배경색
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 80),
              // 상단 타이틀
              const Text(
                'FilmCOCK!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6A5ACD), // 메인 보라색
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 60),

              // 이메일 텍스트 필드
              _buildTextField(
                hintText: '이메일',
                icon: Icons.mail_outline,
              ),
              const SizedBox(height: 16),

              // 비밀번호 텍스트 필드
              _buildTextField(
                hintText: '비밀번호',
                icon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 24),

              // 메인 로그인 버튼
              ElevatedButton(
                onPressed: () {}, // 기본 로그인은 백엔드 연동 전까지 빈 함수로 둠
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A5ACD),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '로그인',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // '또는' 구분선
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade800, thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      '또는',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade800, thickness: 1)),
                ],
              ),
              const SizedBox(height: 32),

              // 구글로 계속하기 버튼
              OutlinedButton(
                onPressed: _signInWithGoogle,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.grey.shade700),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'G', // 폰트에 맞는 구글 로고 에셋이 없으므로 G 텍스트로 임시 스타일링
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Google로 계속하기',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // 비회원으로 시작하기 (건너뛰기)
              TextButton(
                onPressed: _skipLogin,
                child: const Text(
                  '비회원으로 시작하기',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF6A5ACD),
                  ),
                ),
              ),
              const SizedBox(height: 60),

              // 회원가입 링크 (현재 보류)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '계정이 없으신가요?',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  ),
                  TextButton(
                    onPressed: () {
                      // 임시 보류
                    },
                    child: const Text(
                      '회원가입',
                      style: TextStyle(
                        color: Color(0xFF6A5ACD),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
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

  // 텍스트 필드 컴포넌트 분리
  Widget _buildTextField({required String hintText, required IconData icon, bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade600),
        prefixIcon: Icon(icon, color: Colors.grey.shade400),
        filled: true,
        fillColor: Colors.transparent,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF6A5ACD)),
        ),
      ),
    );
  }
}
