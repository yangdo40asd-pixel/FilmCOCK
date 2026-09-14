import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:filmcock_app/data/services/local_user_data_service.dart';
import 'package:filmcock_app/data/services/notification_settings_service.dart';
import 'package:filmcock_app/data/repositories/user_settings_repository.dart';
import 'package:filmcock_app/data/storage/app_storage_keys.dart';
import 'package:filmcock_app/presentation/screens/onboarding/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final UserSettingsRepository _settingsRepository =
      const UserSettingsRepository();
  bool _allPushEnabled = true;
  bool _upcomingAlarmEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _settingsRepository.loadNotifications();
    if (!mounted) return;
    setState(() {
      _allPushEnabled = settings.allEnabled;
      _upcomingAlarmEnabled = settings.upcomingMoviesEnabled;
      _isLoading = false;
    });
  }

  Future<void> _updateSetting(String key, bool value) async {
    await _settingsRepository.setNotification(key, value);
    NotificationSettingsService.notifyChanged();
  }

  Future<String?> _requestPassword() async {
    final controller = TextEditingController();
    final password = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('본인 확인'),
        content: TextField(
          controller: controller,
          autofocus: true,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: '현재 비밀번호',
            hintText: '회원탈퇴를 위해 다시 입력해주세요.',
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) Navigator.pop(dialogContext, value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(dialogContext, controller.text);
              }
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
    controller.dispose();
    return password;
  }

  Future<bool> _reauthenticate(User user) async {
    final providerIds = user.providerData.map((data) => data.providerId);

    if (providerIds.contains(GoogleAuthProvider.PROVIDER_ID)) {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return false;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await user.reauthenticateWithCredential(credential);
      return true;
    }

    if (providerIds.contains(EmailAuthProvider.PROVIDER_ID) &&
        user.email != null) {
      final password = await _requestPassword();
      if (password == null) return false;
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      return true;
    }

    throw FirebaseAuthException(
      code: 'unsupported-provider',
      message: '지원하지 않는 로그인 방식입니다.',
    );
  }

  Future<void> _deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('삭제할 로그인 계정이 없습니다.')));
      return;
    }

    try {
      final reauthenticated = await _reauthenticate(user);
      if (!reauthenticated) return;

      await user.delete();
      await GoogleSignIn().signOut();
      final prefs = await SharedPreferences.getInstance();
      await LocalUserDataService.clear(preferences: prefs);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      final message = switch (error.code) {
        'wrong-password' || 'invalid-credential' => '비밀번호가 올바르지 않습니다.',
        'user-mismatch' => '현재 계정과 같은 Google 계정을 선택해주세요.',
        'unsupported-provider' => '이 로그인 방식은 앱에서 재인증할 수 없습니다.',
        _ => '본인 확인 또는 회원탈퇴를 완료하지 못했습니다. 다시 시도해주세요.',
      };
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원탈퇴를 완료하지 못했습니다. 다시 시도해주세요.')),
      );
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF222222),
        title: const Text(
          '로그아웃',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          '로그아웃 하시겠습니까?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await FirebaseAuth.instance.signOut();
                await GoogleSignIn().signOut();
                final prefs = await SharedPreferences.getInstance();
                await LocalUserDataService.clear(preferences: prefs);
                if (!mounted) return;
                Navigator.of(this.context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              } catch (_) {
                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(content: Text('로그아웃하지 못했습니다. 다시 시도해주세요.')),
                );
              }
            },
            child: const Text(
              '로그아웃',
              style: TextStyle(
                color: Color(0xFFA88BFA),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF222222),
        title: const Text(
          '회원탈퇴',
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          '회원 탈퇴 시 모든 활동 데이터와 등급이 영구히 삭제됩니다.\n계속 진행하시겠습니까?',
          style: TextStyle(color: Colors.white70, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteAccount();
            },
            child: const Text(
              '탈퇴하기',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF141414),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFA88BFA)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          tooltip: '뒤로 가기',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '환경 설정',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        children: [
          // Section 1: 활동 알림
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 8.0,
            ),
            child: Text(
              '활동 알림',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SwitchListTile(
            value: _allPushEnabled,
            activeThumbColor: const Color(0xFF8B5CF6),
            title: const Text(
              '앱 내 알림 안내',
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
            subtitle: Text(
              '홈 화면에서 제공하는 알림 안내를 표시합니다.',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            onChanged: (val) {
              setState(() => _allPushEnabled = val);
              _updateSetting(AppStorageKeys.allPush, val);
            },
          ),
          SwitchListTile(
            value: _upcomingAlarmEnabled,
            activeThumbColor: const Color(0xFF8B5CF6),
            title: const Text(
              '곧 개봉할 영화 알림',
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
            subtitle: Text(
              '홈 화면 진입 시 개봉 예정작 팝업 안내를 받습니다.',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            onChanged: (val) {
              setState(() => _upcomingAlarmEnabled = val);
              _updateSetting(AppStorageKeys.upcomingMovieAlarm, val);
            },
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 16),

          // Section 2: 계정 관리
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 8.0,
            ),
            child: Text(
              '계정 관리',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
            title: const Text(
              '로그아웃',
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
            onTap: _showLogoutDialog,
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
            title: const Text(
              '회원탈퇴',
              style: TextStyle(color: Colors.redAccent, fontSize: 15),
            ),
            onTap: _showDeleteAccountDialog,
          ),
        ],
      ),
    );
  }
}
