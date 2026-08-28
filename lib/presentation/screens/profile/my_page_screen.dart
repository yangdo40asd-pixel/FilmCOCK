import 'package:filmcock_app/presentation/screens/profile/my_comments_screen.dart';
import 'package:filmcock_app/presentation/screens/profile/profile_edit_screen.dart';
import 'package:filmcock_app/presentation/screens/profile/settings_screen.dart';
import 'package:flutter/material.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('마이페이지'),
        elevation: 0, // AppBar 그림자 제거
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(context),
            const Divider(),
            _buildDukLevelSection(),
            const Divider(),
            _buildActivityAndSettingsList(context),
          ],
        ),
      ),
    );
  }

  /// 상단 프로필 영역 (Profile Header)
  Widget _buildProfileHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          // 프로필 이미지
          GestureDetector(
            onTap: () {
              // TODO: 이미지 변경 기능 구현
              print('프로필 이미지 변경');
            },
            child: const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 닉네임, ID
                const Text(
                  '신이난_강동원_991211',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'ID 457938',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          // 프로필 수정 버튼
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ProfileEditScreen(),
                ),
              );
            },
            child: const Text('프로필 수정'),
          ),
        ],
      ),
    );
  }

  /// '덕 쌓기' 레벨 섹션
  Widget _buildDukLevelSection() {
    String currentLevel = '고수';
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const Text(
            '영상을 많이 볼수록 등급이 오릅니다!',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLevelIcon('초심자', Icons.movie_filter, currentLevel == '초심자'),
              _buildLevelIcon(
                '고수',
                Icons.local_fire_department,
                currentLevel == '고수',
              ),
              _buildLevelIcon('초고수', Icons.whatshot, currentLevel == '초고수'),
            ],
          ),
        ],
      ),
    );
  }

  /// 레벨 아이콘 위젯
  Widget _buildLevelIcon(String level, IconData icon, bool isCurrent) {
    final Color color = isCurrent ? const Color(0xFF6A5ACD) : Colors.grey;
    return Column(
      children: [
        Icon(icon, size: 50, color: color),
        const SizedBox(height: 8),
        Text(
          level,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }

  /// 메뉴 및 활동 목록 (Activity & Settings List)
  Widget _buildActivityAndSettingsList(BuildContext context) {
    // 재사용을 위해 ListTile을 생성하는 함수
    Widget buildListTile({
      required IconData icon,
      required String title,
      VoidCallback? onTap, // required를 제거하고 nullable(?)로 변경
    }) {
      return ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      );
    }

    return Column(
      children: [
        buildListTile(
          icon: Icons.info_outline,
          title: '나의 정보',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ProfileEditScreen(),
              ),
            );
          },
        ),
        buildListTile(
          icon: Icons.list_alt,
          title: '내 목록 및 내가 적은 댓글',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const MyCommentsScreen()),
            );
          },
        ),
        buildListTile(
          icon: Icons.settings,
          title: '환경 설정',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
        ),
        buildListTile(
          icon: Icons.thumb_up_alt_outlined,
          title: '내가 추천한 띵작!',
          onTap: () {
            // TODO: MyRecommendationScreen 구현 및 연결
          },
        ),
        const Divider(),
        buildListTile(
          icon: Icons.logout,
          title: '로그아웃',
          onTap: () {
            _showLogoutDialog(context);
          },
        ),
      ],
    );
  }

  /// 로그아웃 확인 다이얼로그를 표시하는 함수
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C2C),
          title: const Text('로그아웃'),
          content: const Text('정말 로그아웃 하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // 다이얼로그 닫기
              },
            ),
            TextButton(
              child: const Text(
                '로그아웃',
                style: TextStyle(color: Colors.redAccent),
              ),
              onPressed: () {
                // TODO: 실제 로그아웃 로직 구현 (예: SharedPreferences 클리어, 로그인 화면으로 이동)
                print('로그아웃 실행');
                Navigator.of(dialogContext).pop(); // 다이얼로그 닫기
              },
            ),
          ],
        );
      },
    );
  }
}
