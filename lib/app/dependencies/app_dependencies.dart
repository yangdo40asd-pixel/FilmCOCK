import 'package:filmcock_app/features/chat/data/firebase_llm_client.dart';
import 'package:filmcock_app/features/chat/application/chatbot_service.dart';
import 'package:filmcock_app/features/search/application/search_screen_controller.dart';
import 'package:filmcock_app/shared/data/catalog/remote_catalog_repository.dart';
import 'package:filmcock_app/shared/domain/repositories/catalog_repository.dart';

/// 프로덕션 구현을 조합하는 앱 진입점. 서비스 테스트는 계약을 직접 주입한다.
class AppDependencies {
  const AppDependencies._();

  static const CatalogRepository catalog = RemoteCatalogRepository();

  static ChatbotService createChatbot() =>
      ChatbotService(catalog: catalog, llmClient: FirebaseLlmClient());

  static SearchScreenController createSearchController() =>
      SearchScreenController(catalog: catalog);
}
