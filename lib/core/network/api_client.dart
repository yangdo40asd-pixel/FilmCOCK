import 'package:filmcock_app/core/network/http_transport.dart';
import 'package:http/http.dart' as http;

/// 기존 정적 API 구현의 호환 전송 진입점.
class ApiClient {
  const ApiClient._();

  static const Duration requestTimeout = Duration(seconds: 15);
  static const HttpTransport _transport = HttpTransport();

  static Future<http.Response> get(Uri url) => _transport.get(url);
}
