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
  int _selectedIndex = 0;

  final List<Widget?> _pages = <Widget?>[const HomeScreen(), null, null, null];

  Widget _createPage(int index) {
    return switch (index) {
      0 => const HomeScreen(),
      1 => const SearchScreen(),
      2 => const PreferenceScreen(),
      3 => const MyPageScreen(),
      _ => const SizedBox.shrink(),
    };
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _pages[index] ??= _createPage(index);
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _selectedIndex != 0) {
          _onItemTapped(0);
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: List.generate(
            _pages.length,
            (index) => _pages[index] ?? const SizedBox.shrink(),
          ),
        ),
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: isDark ? const Color(0xFF1F1F1F) : Colors.white,
          ),
          child: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
              BottomNavigationBarItem(icon: Icon(Icons.search), label: '검색'),
              BottomNavigationBarItem(icon: Icon(Icons.favorite), label: '취향'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: const Color(0xFF6A5ACD),
            unselectedItemColor: isDark ? Colors.grey[500] : Colors.grey[600],
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
          ),
        ),
      ),
    );
  }
}
