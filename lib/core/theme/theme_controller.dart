import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:filmcock_app/data/storage/app_storage_keys.dart';

class ThemeController {
  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier(
    ThemeMode.dark,
  );
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(AppStorageKeys.isDarkMode) ?? true;
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  static Future<void> toggleTheme() async {
    final next = themeMode.value == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    themeMode.value = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppStorageKeys.isDarkMode, next == ThemeMode.dark);
  }

  static bool get isDark => themeMode.value == ThemeMode.dark;

  static ThemeData get lightTheme {
    final colors = ColorScheme.fromSeed(
      seedColor: const Color(0xFF6A5ACD),
      brightness: Brightness.light,
      surface: const Color(0xFFF7F7FA),
    );
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: colors,
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
      progressIndicatorTheme: ProgressIndicatorThemeData(color: colors.primary),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.inverseSurface,
        contentTextStyle: TextStyle(color: colors.onInverseSurface),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFF191919)),
        bodyMedium: TextStyle(color: Color(0xFF222222)),
      ),
    );
  }

  static ThemeData get darkTheme {
    final colors = ColorScheme.fromSeed(
      seedColor: const Color(0xFF8B5CF6),
      brightness: Brightness.dark,
      surface: const Color(0xFF1E1E2E),
    );
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: colors,
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
      progressIndicatorTheme: ProgressIndicatorThemeData(color: colors.primary),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.inverseSurface,
        contentTextStyle: TextStyle(color: colors.onInverseSurface),
      ),
    );
  }
}
