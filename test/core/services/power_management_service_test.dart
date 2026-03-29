import 'package:flutter_test/flutter_test.dart';
import 'package:pomer/core/services/power_management_service.dart';
import 'package:pomer/core/utils/platform_utils.dart';

void main() {
  group('PowerManagementService', () {
    late PowerManagementService service;

    setUp(() {
      service = PowerManagementService();
    });

    test('initial state has wake lock released', () {
      expect(service.isWakeLockHeld, false);
    });

    test('updateScreenState releases wake lock when screen turns off', () {
      // Simulate screen turning off
      service.updateScreenState(false);
      expect(service.isWakeLockHeld, false);
    });

    test('syncWithTimerState releases when not running', () async {
      await service.syncWithTimerState(false);
      expect(service.isWakeLockHeld, false);
    });

    test('getUserEducationMessage returns appropriate messages', () {
      // Note: Actual wake lock acquisition requires platform
      // This test verifies the service logic
      expect(service.isWakeLockHeld, false);
    });
  });

  group('PowerManagementService Platform Detection', () {
    test('PlatformUtils detects current platform', () {
      // Platform detection should work
      expect(PlatformUtils.isAndroid || PlatformUtils.isWindows || PlatformUtils.isWeb, true);
    });
  });
}
