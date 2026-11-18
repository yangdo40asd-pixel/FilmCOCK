import 'package:flutter/material.dart';
import 'package:filmcock_app/app/bootstrap/app_bootstrap.dart';
import 'package:filmcock_app/core/theme/theme_controller.dart';
import 'package:filmcock_app/app/presentation/splash_screen.dart';

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
    _startupFuture = AppBootstrap.initialize();
  }

  void _retryStartup() {
    setState(() {
      _startupFuture = AppBootstrap.initialize();
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
