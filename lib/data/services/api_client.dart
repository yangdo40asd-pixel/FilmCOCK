import 'dart:async';
import 'dart:io';

import 'package:filmcock_app/core/config/secrets.dart';
import 'package:filmcock_app/core/errors/app_exception.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  const ApiClient._();

  static const Duration requestTimeout = Duration(seconds: 15);

  static Future<http.Response> get(Uri url) async {
    final isTmdb = url.host.contains('themoviedb.org');
    if (isTmdb && !ApiSecrets.hasTmdbCredentials) {
      throw const MissingApiKeyException('TMDB');
    }
    if (url.host.contains('kobis.or.kr') && !ApiSecrets.hasKoficApiKey) {
      throw const MissingApiKeyException('KOFIC');
    }

    try {
      final useReadToken = isTmdb && ApiSecrets.hasTmdbReadAccessToken;
      final requestUrl = useReadToken ? _withoutApiKey(url) : url;
      final headers = useReadToken
          ? <String, String>{
              'Authorization': 'Bearer ${ApiSecrets.tmdbReadAccessToken}',
              'accept': 'application/json',
            }
          : null;
      return await http
          .get(requestUrl, headers: headers)
          .timeout(requestTimeout);
    } on TimeoutException {
      throw const RequestTimeoutException();
    } on SocketException {
      throw const NetworkUnavailableException();
    } on http.ClientException {
      throw const NetworkUnavailableException();
    }
  }

  static Uri _withoutApiKey(Uri url) {
    final query = Map<String, String>.from(url.queryParameters)
      ..remove('api_key');
    return url.replace(queryParameters: query);
  }
}
