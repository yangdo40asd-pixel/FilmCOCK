import 'package:filmcock_app/data/models/mbti_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const supportedGenres = {
    'action',
    'adventure',
    'animation',
    'comedy',
    'crime',
    'documentary',
    'drama',
    'family',
    'fantasy',
    'history',
    'horror',
    'music',
    'mystery',
    'romance',
    'sf',
    'thriller',
    'war',
  };

  test('all 16 MBTI types have valid recommendation genres', () {
    expect(mbtiInfoList, hasLength(16));
    expect(mbtiInfoList.map((info) => info.id).toSet(), hasLength(16));

    for (final info in mbtiInfoList) {
      expect(info.genreIds, isNotEmpty, reason: info.id);
      expect(
        info.genreIds.every(supportedGenres.contains),
        isTrue,
        reason: '${info.id}: ${info.genreIds}',
      );
    }
  });

  test('MBTI recommendations are distributed across multiple lead genres', () {
    final leadGenres = mbtiInfoList.map((info) => info.genreIds.first).toSet();
    expect(leadGenres.length, greaterThanOrEqualTo(8));
  });

  test('unknown MBTI values are rejected', () {
    expect(getMbtiInfoById('NONE'), isNull);
    expect(getMbtiInfoById('skipped'), isNull);
    expect(getMbtiInfoById(''), isNull);
  });
}
