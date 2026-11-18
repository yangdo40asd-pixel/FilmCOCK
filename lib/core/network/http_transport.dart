import 'dart:async';
import 'dart:io';
import 'package:filmcock_app/core/config/secrets.dart';
import 'package:filmcock_app/core/errors/app_exception.dart';
import 'package:http/http.dart' as http;

/// HTTP 자원 수명은 주입한 client의 소유자가 관리한다.
class HttpTransport {
  final http.Client? client;
  final Duration timeout;

  const HttpTransport({
    this.client,
    this.timeout = const Duration(seconds: 15),
  });

  Future<http.Response> get(Uri url) async {
    final isTmdb = url.host == 'api.themoviedb.org';
    if (isTmdb && !ApiSecrets.hasTmdbCredentials) {
      throw const MissingApiKeyException('TMDB');
    }
    if (url.host.endsWith('kobis.or.kr') && !ApiSecrets.hasKoficApiKey) {
      throw const MissingApiKeyException('KOFIC');
    }
    final token = isTmdb && ApiSecrets.hasTmdbReadAccessToken;
    final requestUrl = token
        ? url.replace(
            queryParameters: Map<String, String>.from(url.queryParameters)
              ..remove('api_key'),
          )
        : url;
    final headers = token
        ? {
            'Authorization': 'Bearer ${ApiSecrets.tmdbReadAccessToken}',
            'accept': 'application/json',
          }
        : null;
    try {
      return await (client?.get(requestUrl, headers: headers) ??
              http.get(requestUrl, headers: headers))
          .timeout(timeout);
    } on TimeoutException {
      throw const RequestTimeoutException();
    } on SocketException {
      throw const NetworkUnavailableException();
    } on http.ClientException {
      throw const NetworkUnavailableException();
    }
  }
}
