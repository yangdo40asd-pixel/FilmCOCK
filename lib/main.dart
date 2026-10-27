import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:filmcock_app/firebase_options.dart';
import 'package:filmcock_app/presentation/screens/splash/splash_screen.dart';
import 'package:filmcock_app/core/theme/theme_controller.dart';
import 'package:filmcock_app/data/services/home_prefetch_service.dart';
import 'package:filmcock_app/core/config/secrets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiSecrets.init();
  await ThemeController.init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<void> _startupFuture;

  @override
  void initState() {
    super.initState();
    _startupFuture = _initializeApp();
  }

  Future<void> _initializeApp() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    final prefs = await SharedPreferences.getInstance();
    await HomePrefetchService.restore(preferences: prefs);
  }

  void _retryStartup() {
    setState(() {
      _startupFuture = _initializeApp();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'FilmCOCK!',
          themeMode: mode,
          theme: ThemeController.lightTheme,
          darkTheme: ThemeController.darkTheme,
          home: FutureBuilder<void>(
            future: _startupFuture,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _StartupErrorScreen(onRetry: _retryStartup);
              }
              if (snapshot.connectionState != ConnectionState.done) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              return const SplashScreen();
            },
          ),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class _StartupErrorScreen extends StatelessWidget {
  const _StartupErrorScreen({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 48),
              const SizedBox(height: 16),
              Text(
                '앱을 시작하는 데 필요한 연결을 준비하지 못했습니다.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '네트워크 상태를 확인한 뒤 다시 시도해주세요.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
