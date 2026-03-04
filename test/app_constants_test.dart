import 'package:flutter_test/flutter_test.dart';
import 'package:pomer/core/constants/app_constants.dart';

void main() {
  group('AppConstants', () {
    test('appName is Pomer', () {
      expect(AppConstants.appName, 'Pomer');
    });

  test('AppConstants appVersion is 0.5.0', () {
    expect(AppConstants.appVersion, '0.5.0');
    });

    test('developer is Dencel K Babu', () {
      expect(AppConstants.developer, 'Dencel K Babu');
    });

    test('company is PetersDigital', () {
      expect(AppConstants.company, 'PetersDigital');
    });

    test('packageName is com.petersdigital.pomer', () {
      expect(AppConstants.packageName, 'com.petersdigital.pomer');
    });

    test('defaultFocusDuration is 25', () {
      expect(AppConstants.defaultFocusDuration, 25);
    });

    test('defaultShortBreakDuration is 5', () {
      expect(AppConstants.defaultShortBreakDuration, 5);
    });

    test('defaultLongBreakDuration is 15', () {
      expect(AppConstants.defaultLongBreakDuration, 15);
    });

    test('defaultCyclesBeforeLongBreak is 4', () {
      expect(AppConstants.defaultCyclesBeforeLongBreak, 4);
    });
  });
}
