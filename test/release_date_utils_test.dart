import 'package:filmcock_app/core/utils/release_date_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReleaseDateUtils.daysUntil', () {
    test('uses calendar dates instead of elapsed 24 hour periods', () {
      final from = DateTime(2026, 9, 10, 23, 50);
      final release = DateTime(2026, 9, 11);

      expect(ReleaseDateUtils.daysUntil(release, from: from), 1);
    });

    test('returns zero on release day', () {
      final from = DateTime(2026, 9, 10, 18);
      final release = DateTime(2026, 9, 10);

      expect(ReleaseDateUtils.daysUntil(release, from: from), 0);
    });

    test('returns a negative value after release', () {
      final from = DateTime(2026, 9, 11, 9);
      final release = DateTime(2026, 9, 10);

      expect(ReleaseDateUtils.daysUntil(release, from: from), -1);
    });
  });
}
