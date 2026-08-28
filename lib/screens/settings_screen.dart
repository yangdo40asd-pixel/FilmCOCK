import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('환경 설정')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('알림 설정'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 알림 설정 화면으로 이동
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_circle_outlined),
            title: const Text('계정 관리'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 계정 관리 화면으로 이동
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('앱 정보'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 앱 정보 화면으로 이동
            },
          ),
        ],
      ),
    );
  }
}
