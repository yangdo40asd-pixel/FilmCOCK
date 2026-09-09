import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController {
  static final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier(ThemeMode.dark);
  static const String _key = 'is_dark_mode';

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_key) ?? true;
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  static Future<void> toggleTheme() async {
    final next =
        themeMode.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    themeMode.value = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, next == ThemeMode.dark);
  }

  static bool get isDark => themeMode.value == ThemeMode.dark;

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color(0xFF6A5ACD),
      scaffoldBackgroundColor: const Color(0xFFF7F7FA),
      fontFamily: GoogleFonts.notoSansKr().fontFamily,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF7F7FA),
        foregroundColor: Color(0xFF191919),
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF6A5ACD),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
      cardColor: Colors.white,
      dividerColor: Colors.black12,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFF191919)),
        bodyMedium: TextStyle(color: Color(0xFF222222)),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF6A5ACD),
      scaffoldBackgroundColor: const Color(0xFF1E1E2E),
      fontFamily: GoogleFonts.notoSansKr().fontFamily,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E2E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1F1F1F),
        selectedItemColor: Color(0xFF6A5ACD),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
      cardColor: const Color(0xFF262632),
      dividerColor: Colors.white12,
    );
  }
}
