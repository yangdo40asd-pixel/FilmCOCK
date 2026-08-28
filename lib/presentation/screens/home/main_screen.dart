import 'package:flutter/material.dart';
import 'package:filmcock_app/presentation/screens/home/home_screen.dart';
import 'package:filmcock_app/presentation/screens/search/search_screen.dart';
import 'package:filmcock_app/presentation/screens/profile/preference_screen.dart';
import 'package:filmcock_app/presentation/screens/profile/my_page_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // 현재 선택된 탭의 인덱스

  // 각 탭에 해당하는 화면 목록
  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    const SearchScreen(),
    const PreferenceScreen(),
    const MyPageScreen(),
  ];

  // 탭을 눌렀을 때 호출될 함수
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // 선택된 탭의 인덱스를 변경
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex), // 선택된 탭에 맞는 화면을 보여줌
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(canvasColor: const Color(0xFF303030)),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: '검색'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite), label: '취향'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF55C75A),
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}
