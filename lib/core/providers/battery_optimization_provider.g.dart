// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'battery_optimization_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$batteryOptimizationServiceHash() =>
    r'eb3b39876d3d0a14c0a67aa8bcdbb736d3f9bdeb';

/// See also [batteryOptimizationService].
@ProviderFor(batteryOptimizationService)
final batteryOptimizationServiceProvider =
    Provider<BatteryOptimizationService>.internal(
  batteryOptimizationService,
  name: r'batteryOptimizationServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$batteryOptimizationServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BatteryOptimizationServiceRef = ProviderRef<BatteryOptimizationService>;
String _$batteryOptimizationStatusHash() =>
    r'c5d41208b230fbff750c1d787123b70e4f08c0c4';

/// Provider that tracks battery optimization status.
///
/// Returns:
/// - `true` if battery optimization is enabled (app may be interrupted)
/// - `false` if battery optimization is disabled (app can run freely)
/// - `null` if status is unknown or platform is not Android
///
/// Copied from [BatteryOptimizationStatus].
@ProviderFor(BatteryOptimizationStatus)
final batteryOptimizationStatusProvider =
    AsyncNotifierProvider<BatteryOptimizationStatus, bool?>.internal(
  BatteryOptimizationStatus.new,
  name: r'batteryOptimizationStatusProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$batteryOptimizationStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BatteryOptimizationStatus = AsyncNotifier<bool?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
