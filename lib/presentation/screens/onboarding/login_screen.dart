import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:filmcock_app/data/repositories/user_settings_repository.dart';
import 'package:filmcock_app/presentation/screens/onboarding/mbti_select_screen.dart';
import 'package:filmcock_app/presentation/screens/home/main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final UserSettingsRepository _settingsRepository =
      const UserSettingsRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _completeSignIn() async {
    await _settingsRepository.endGuestSession();
    final onboarding = await _settingsRepository.loadOnboarding();
    if (!mounted) return;
    final completed = onboarding.isComplete;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            completed ? const MainScreen() : const MbtiSelectScreen(),
      ),
    );
  }

  String _authErrorMessage(FirebaseAuthException error) {
    return switch (error.code) {
      'invalid-email' => '이메일 형식이 올바르지 않습니다.',
      'invalid-credential' || 'wrong-password' => '이메일 또는 비밀번호를 확인해주세요.',
      'user-not-found' => '등록되지 않은 계정입니다.',
      'email-already-in-use' => '이미 사용 중인 이메일입니다.',
      'weak-password' => '비밀번호는 6자 이상 입력해주세요.',
      _ => '인증을 완료하지 못했습니다. 다시 시도해주세요.',
    };
  }

  Future<void> _signInWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('이메일과 비밀번호를 입력해주세요.')));
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await _completeSignIn();
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_authErrorMessage(error))));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _registerWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('이메일과 비밀번호를 입력해주세요.')));
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _completeSignIn();
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_authErrorMessage(error))));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      // 1. 구글 계정 선택 팝업 노출 (웹/안드로이드 등에서 작동)
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return; // 사용자가 중간에 창을 닫음
      }

      // 2. 구글 인증 정보 가져오기
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 3. 파이어베이스 Auth로 로그인 처리
      await _auth.signInWithCredential(credential);
      await _completeSignIn();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('구글 로그인 실패: $e')));
    }
  }

  Future<void> _skipLogin() async {
    // 비회원으로 시작하기: 즉시 MBTI 선택 화면으로 건너뜀
    await _settingsRepository.startGuestSession();
    if (!mounted) return;
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
                controller: _emailController,
                hintText: '이메일',
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // 비밀번호 텍스트 필드
              _buildTextField(
                controller: _passwordController,
                hintText: '비밀번호',
                icon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 24),

              // 메인 로그인 버튼
              ElevatedButton(
                onPressed: _isSubmitting ? null : _signInWithEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A5ACD),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
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
                  Expanded(
                    child: Divider(color: Colors.grey.shade800, thickness: 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      '또는',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: Colors.grey.shade800, thickness: 1),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // 구글로 계속하기 버튼
              OutlinedButton(
                onPressed: _isSubmitting ? null : _signInWithGoogle,
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
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // 비회원으로 시작하기 (건너뛰기)
              TextButton(
                onPressed: _isSubmitting ? null : _skipLogin,
                child: const Text(
                  '비회원으로 시작하기',
                  style: TextStyle(fontSize: 15, color: Color(0xFF6A5ACD)),
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
                    onPressed: _isSubmitting ? null : _registerWithEmail,
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
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
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
