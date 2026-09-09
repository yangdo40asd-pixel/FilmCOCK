import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _allPushEnabled = true;
  bool _serviceUpdateEnabled = true;
  bool _nightPushEnabled = false;
  bool _upcomingAlarmEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _allPushEnabled = prefs.getBool('setting_all_push') ?? true;
      _serviceUpdateEnabled = prefs.getBool('setting_service_update') ?? true;
      _nightPushEnabled = prefs.getBool('setting_night_push') ?? false;
      _upcomingAlarmEnabled =
          prefs.getBool('setting_upcoming_movie_alarm') ?? true;
      _isLoading = false;
    });
  }

  Future<void> _updateSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
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
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('로그아웃 되었습니다.')),
              );
            },
            child: const Text(
              '로그아웃',
              style: TextStyle(
                  color: Color(0xFFA88BFA), fontWeight: FontWeight.bold),
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
          style:
              TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
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
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('회원탈퇴 처리가 완료되었습니다.')),
                );
              }
            },
            child: const Text(
              '탈퇴하기',
              style: TextStyle(
                  color: Colors.redAccent, fontWeight: FontWeight.bold),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
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
              '전체 푸시 알림',
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
            subtitle: Text(
              '앱의 모든 알림을 받습니다.',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            onChanged: (val) {
              setState(() => _allPushEnabled = val);
              _updateSetting('setting_all_push', val);
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
              _updateSetting('setting_upcoming_movie_alarm', val);
            },
          ),
          SwitchListTile(
            value: _serviceUpdateEnabled,
            activeThumbColor: const Color(0xFF8B5CF6),
            title: const Text(
              '서비스 업데이트',
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
            subtitle: Text(
              '새로운 기능 및 중요 공지를 받습니다.',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            onChanged: (val) {
              setState(() => _serviceUpdateEnabled = val);
              _updateSetting('setting_service_update', val);
            },
          ),
          SwitchListTile(
            value: _nightPushEnabled,
            activeThumbColor: const Color(0xFF8B5CF6),
            title: const Text(
              '야간 푸시 알림',
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
            subtitle: Text(
              '오후 9시 ~ 오전 8시 알림 수신 동의',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            onChanged: (val) {
              setState(() => _nightPushEnabled = val);
              _updateSetting('setting_night_push', val);
            },
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 16),

          // Section 2: 계정 관리
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
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
