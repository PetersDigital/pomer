import 'package:flutter_test/flutter_test.dart';
import 'package:pomer/core/services/battery_optimization_service.dart';
import 'package:pomer/core/utils/platform_utils.dart';

void main() {
  group('BatteryOptimizationService', () {
    late BatteryOptimizationService service;

    setUp(() {
      service = BatteryOptimizationService();
    });

    test('initial state has null optimization status', () {
      // Initial status should be null (unknown) until detected
      expect(service.getUserEducationMessage(), contains('unknown'));
    });

    test('isBatteryOptimized returns null on non-Android platforms', () async {
      // On web/Windows, should return null
      if (!PlatformUtils.isAndroid) {
        final result = await service.isBatteryOptimized();
        expect(result, isNull);
      }
    });

    test('isIgnoringBatteryOptimizations returns false on non-Android', () async {
      if (!PlatformUtils.isAndroid) {
        final result = await service.isIgnoringBatteryOptimizations();
        expect(result, isFalse);
      }
    });

    test('updateStatus updates cached value', () {
      service.updateStatus(true);
      expect(service.getUserEducationMessage(), contains('enabled'));

      service.updateStatus(false);
      expect(service.getUserEducationMessage(), contains('disabled'));
    });

    test('getUserEducationMessage returns appropriate messages', () {
      // Test optimized (true)
      service.updateStatus(true);
      final optimizedMsg = service.getUserEducationMessage();
      expect(optimizedMsg, contains('Battery optimization is enabled'));
      expect(optimizedMsg, contains('interruptions'));

      // Test not optimized (false)
      service.updateStatus(false);
      final notOptimizedMsg = service.getUserEducationMessage();
      expect(notOptimizedMsg, contains('Battery optimization is disabled'));
      expect(notOptimizedMsg, contains('smoothly'));

      // Test unknown (null)
      service.updateStatus(true);
      service.updateStatus(false);
      // Reset to null by creating new instance
      final newService = BatteryOptimizationService();
      final unknownMsg = newService.getUserEducationMessage();
      expect(unknownMsg, contains('unknown'));
    });

    test('logBatteryOptimizationStatus completes without error', () async {
      // Should not throw
      await expectLater(
        service.logBatteryOptimizationStatus(),
        completes,
      );
    });
  });

  group('BatteryOptimizationService Platform Detection', () {
    test('PlatformUtils can detect current platform', () {
      // At least one platform should be detected
      expect(
        PlatformUtils.isAndroid ||
            PlatformUtils.isWindows ||
            PlatformUtils.isWeb,
        isTrue,
      );
    });

    test('isMobile returns true only on Android', () {
      if (PlatformUtils.isAndroid) {
        expect(PlatformUtils.isMobile, isTrue);
      } else {
        expect(PlatformUtils.isMobile, isFalse);
      }
    });
  });
}
