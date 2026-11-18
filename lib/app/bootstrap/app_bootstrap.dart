import 'package:firebase_core/firebase_core.dart';
import 'package:filmcock_app/features/home/data/home_prefetch_service.dart';
import 'package:filmcock_app/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 앱 UI를 만들기 전에 필요한 외부 초기화와 로컬 캐시 복원을 담당한다.
class AppBootstrap {
  const AppBootstrap._();

  static Future<void> initialize() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    final preferences = await SharedPreferences.getInstance();
    await HomePrefetchService.restore(preferences: preferences);
  }
}
