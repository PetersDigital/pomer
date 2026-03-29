import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pomer/core/services/battery_optimization_service.dart';

part 'battery_optimization_provider.g.dart';

@Riverpod(keepAlive: true)
BatteryOptimizationService batteryOptimizationService(Ref ref) {
  return BatteryOptimizationService();
}

/// Provider that tracks battery optimization status.
///
/// Returns:
/// - `true` if battery optimization is enabled (app may be interrupted)
/// - `false` if battery optimization is disabled (app can run freely)
/// - `null` if status is unknown or platform is not Android
@Riverpod(keepAlive: true)
class BatteryOptimizationStatus extends _$BatteryOptimizationStatus {
  @override
  Future<bool?> build() async {
    final service = ref.read(batteryOptimizationServiceProvider);
    return service.isBatteryOptimized();
  }

  /// Refreshes the battery optimization status.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(batteryOptimizationServiceProvider);
      return service.isBatteryOptimized();
    });
  }

  /// Updates the cached status manually.
  void updateStatus(bool isOptimized) {
    state = AsyncValue.data(isOptimized);
    final service = ref.read(batteryOptimizationServiceProvider);
    service.updateStatus(isOptimized);
  }
}
