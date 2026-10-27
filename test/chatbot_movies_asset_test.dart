import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('챗봇 큐레이션 데이터의 id/posterPath 형식이 올바르다', () {
    final entries =
        (jsonDecode(File('assets/data/chatbot_movies.json').readAsStringSync())
                as List)
            .cast<Map<String, dynamic>>();
    expect(entries, isNotEmpty);

    final ids = <int>{};
    final posterPattern = RegExp(r'^/[A-Za-z0-9]{20,40}\.(jpg|png)$');
    for (final entry in entries) {
      final title = entry['title'];
      expect(entry['id'], isA<int>(), reason: '$title');
      expect(ids.add(entry['id'] as int), isTrue, reason: '중복 id: $title');
      expect(
        posterPattern.hasMatch('${entry['posterPath']}'),
        isTrue,
        reason: '포스터 경로 형식 오류: $title',
      );
      expect((entry['categories'] as List?)?.isNotEmpty, isTrue, reason: '$title');
    }
  });
}
