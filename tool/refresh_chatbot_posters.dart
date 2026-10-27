// 챗봇 큐레이션 데이터(assets/data/chatbot_movies.json)의 posterPath를
// TMDB 영화 상세 응답으로 다시 확인/갱신하는 개발용 스크립트.
//
// 실행: dart run tool/refresh_chatbot_posters.dart [--write]
// 키는 환경변수 TMDB_READ_ACCESS_TOKEN / TMDB_API_KEY 또는
// config/api_keys.json에서 읽으며, 키 값은 절대 출력하지 않는다.
// 제목(한국어 또는 원제)이 일치할 때만 posterPath를 바꾸고,
// 일치하지 않는 항목은 수동 확인 대상으로만 보고한다.
import 'dart:convert';
import 'dart:io';

const _assetPath = 'assets/data/chatbot_movies.json';

Future<void> main(List<String> args) async {
  final write = args.contains('--write');
  final keys = _loadKeys();
  final token = keys['TMDB_READ_ACCESS_TOKEN'] ?? '';
  final apiKey = keys['TMDB_API_KEY'] ?? '';
  if (token.isEmpty && apiKey.isEmpty) {
    stderr.writeln('TMDB 키가 없습니다. config/api_keys.json 또는 환경변수를 확인하세요.');
    exitCode = 2;
    return;
  }

  final file = File(_assetPath);
  final entries = (jsonDecode(await file.readAsString()) as List)
      .cast<Map<String, dynamic>>();
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
  final unresolved = <String>[];
  var changed = 0;

  for (final entry in entries) {
    final id = entry['id'];
    final title = '${entry['title']}';
    var detail = await _get(client, '/3/movie/$id?language=ko-KR', token, apiKey);
    if (detail != null && !_titleMatches(title, detail)) {
      // id가 다른 영화를 가리키는 경우: 제목+개봉연도로 검색해 유일하게 일치할 때만 교정.
      final fixed = await _searchExact(client, entry, token, apiKey);
      if (fixed != null) {
        stdout.writeln('id 교정: $id -> ${fixed['id']} $title');
        entry['id'] = fixed['id'];
        detail = fixed;
        changed++;
      }
    }
    if (detail == null) {
      unresolved.add('$id $title: TMDB 조회 실패');
      continue;
    }
    if (!_titleMatches(title, detail)) {
      unresolved.add('$id $title: 제목 불일치(TMDB: ${detail['title']})');
      continue;
    }
    final poster = detail['poster_path'];
    if (poster is! String || !poster.startsWith('/')) {
      unresolved.add('$id $title: TMDB에 포스터 없음');
      continue;
    }
    if (poster != entry['posterPath']) {
      stdout.writeln('갱신: $id $title ${entry['posterPath']} -> $poster');
      entry['posterPath'] = poster;
      changed++;
    } else {
      stdout.writeln('정상: $id $title');
    }
  }
  client.close();

  if (write && changed > 0) {
    final body = entries.map((e) => '  ${jsonEncode(e)}').join(',\n');
    await file.writeAsString('[\n$body\n]\n');
  }
  stdout.writeln('변경 $changed건${write ? ' 저장됨' : ' (미저장, --write로 저장)'}');
  for (final line in unresolved) {
    stdout.writeln('미해결: $line');
  }
}

bool _titleMatches(String title, Map<String, dynamic> detail) {
  final t = _norm(title);
  return t == _norm('${detail['title'] ?? ''}') ||
      t == _norm('${detail['original_title'] ?? ''}');
}

Future<Map<String, dynamic>?> _searchExact(
  HttpClient client,
  Map<String, dynamic> entry,
  String token,
  String apiKey,
) async {
  final title = '${entry['title']}';
  final year = '${entry['releaseDate'] ?? ''}'.split('-').first;
  final query = Uri.encodeQueryComponent(title);
  final result = await _get(
    client,
    '/3/search/movie?language=ko-KR&query=$query&year=$year',
    token,
    apiKey,
  );
  final matches = ((result?['results'] as List?) ?? const [])
      .cast<Map<String, dynamic>>()
      .where((m) => _titleMatches(title, m))
      .where((m) => '${m['release_date'] ?? ''}'.startsWith(year))
      .toList();
  return matches.length == 1 ? matches.single : null;
}

String _norm(String s) => s.replaceAll(RegExp(r'[\s:·\-]'), '').toLowerCase();

Map<String, String> _loadKeys() {
  final result = <String, String>{};
  final file = File('config/api_keys.json');
  if (file.existsSync()) {
    final decoded = jsonDecode(file.readAsStringSync());
    if (decoded is Map) {
      decoded.forEach((k, v) => result['$k'] = '$v'.trim());
    }
  }
  for (final name in ['TMDB_READ_ACCESS_TOKEN', 'TMDB_API_KEY']) {
    final env = Platform.environment[name];
    if (env != null && env.trim().isNotEmpty) result[name] = env.trim();
  }
  return result;
}

Future<Map<String, dynamic>?> _get(
  HttpClient client,
  String path,
  String token,
  String apiKey,
) async {
  var uri = Uri.parse('https://api.themoviedb.org$path');
  if (token.isEmpty) {
    uri = uri.replace(queryParameters: {...uri.queryParameters, 'api_key': apiKey});
  }
  try {
    final request = await client.getUrl(uri);
    if (token.isNotEmpty) {
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
    }
    final response = await request.close().timeout(const Duration(seconds: 15));
    final text = await response.transform(utf8.decoder).join();
    if (response.statusCode != 200) return null;
    return jsonDecode(text) as Map<String, dynamic>;
  } catch (_) {
    return null;
  }
}
