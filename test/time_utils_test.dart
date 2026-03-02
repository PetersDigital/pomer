import 'package:flutter_test/flutter_test.dart';
import 'package:pomer/core/utils/time_utils.dart';

void main() {
  group('TimeFormatting', () {
    test('toMMSS formats exactly 0 seconds correctly', () {
      expect(0.toMMSS(), '00:00');
    });

    test('toMMSS formats seconds under 10 correctly', () {
      expect(5.toMMSS(), '00:05');
    });

    test('toMMSS formats seconds between 10 and 59 correctly', () {
      expect(45.toMMSS(), '00:45');
    });

    test('toMMSS formats exactly 1 minute correctly', () {
      expect(60.toMMSS(), '01:00');
    });

    test('toMMSS formats multiple minutes correctly', () {
      expect(300.toMMSS(), '05:00');
    });

    test('toMMSS formats minutes and seconds correctly', () {
      expect(325.toMMSS(), '05:25');
    });

    test('toMMSS formats double-digit minutes correctly', () {
      expect(1500.toMMSS(), '25:00');
    });

    test('toMMSS formats greater than 60 minutes correctly', () {
      expect(3600.toMMSS(), '60:00'); // 1 hour
      expect(4505.toMMSS(), '75:05');
    });
  });
}
