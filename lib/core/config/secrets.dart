import 'dart:convert';

import 'package:flutter/services.dart';

class ApiSecrets {
  const ApiSecrets._();

  static const String _definedTmdbApiKey = String.fromEnvironment(
    'TMDB_API_KEY',
  );
  static const String _definedTmdbReadAccessToken = String.fromEnvironment(
    'TMDB_READ_ACCESS_TOKEN',
  );
  static const String _definedKoficApiKey = String.fromEnvironment(
    'KOFIC_API_KEY',
  );

  static String tmdbApiKey = _definedTmdbApiKey;
  static String tmdbReadAccessToken = _definedTmdbReadAccessToken;
  static String koficApiKey = _definedKoficApiKey;

  static Future<void> init() async {
    if (hasTmdbCredentials && hasKoficApiKey) return;
    try {
      final source = await rootBundle.loadString('config/api_keys.json');
      final values = jsonDecode(source) as Map<String, dynamic>;
      tmdbApiKey = _preferDefined(_definedTmdbApiKey, values['TMDB_API_KEY']);
      tmdbReadAccessToken = _preferDefined(
        _definedTmdbReadAccessToken,
        values['TMDB_READ_ACCESS_TOKEN'],
      );
      koficApiKey = _preferDefined(
        _definedKoficApiKey,
        values['KOFIC_API_KEY'],
      );
    } catch (_) {
      // 파일이 없거나 손상된 경우 기존 누락 키 안내 화면에서 처리한다.
    }
  }

  static String _preferDefined(String defined, dynamic fileValue) {
    if (defined.trim().isNotEmpty) return defined;
    final value = fileValue?.toString().trim() ?? '';
    return value.startsWith('replace-with-') ? '' : value;
  }

  static bool get hasTmdbApiKey => tmdbApiKey.trim().isNotEmpty;
  static bool get hasTmdbReadAccessToken =>
      tmdbReadAccessToken.trim().isNotEmpty;
  static bool get hasTmdbCredentials => hasTmdbReadAccessToken || hasTmdbApiKey;
  static bool get hasKoficApiKey => koficApiKey.trim().isNotEmpty;
}
