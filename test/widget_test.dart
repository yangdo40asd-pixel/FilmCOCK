// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:filmcock_app/data/models/movie_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Person display filtering', () {
    test('accepts a Korean translated display name', () {
      final person = Person(
        id: 1,
        name: '아만다 콜린',
        originalName: 'Amanda Collin',
        knownForDepartment: 'Acting',
      );

      expect(person.displayName, '아만다 콜린');
      expect(person.hasKoreanDisplayName, isTrue);
    });

    test('rejects an untranslated English display name', () {
      final person = Person(
        id: 2,
        name: 'Genesis Rodriguez',
        originalName: 'Genesis Rodriguez',
        knownForDepartment: 'Acting',
      );

      expect(person.hasKoreanDisplayName, isFalse);
    });

    test('rejects a Japanese display name', () {
      final person = Person(
        id: 3,
        name: '佐々木麻由子',
        originalName: '佐々木麻由子',
        knownForDepartment: 'Acting',
      );

      expect(person.displayName, isEmpty);
      expect(person.hasKoreanDisplayName, isFalse);
    });
  });

  test('watch provider builds a TMDB logo URL', () {
    const provider = WatchProvider(
      providerId: 356,
      providerName: 'wavve',
      logoPath: '/provider.jpg',
      link: 'https://www.themoviedb.org/movie/1/watch?locale=KR',
      offerType: '구독',
    );

    expect(
      provider.fullLogoUrl,
      'https://image.tmdb.org/t/p/w200/provider.jpg',
    );
  });
}
