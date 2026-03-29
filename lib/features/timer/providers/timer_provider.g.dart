// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timer_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$timerNotifierHash() => r'233bd0439af4a3df27146eae7b7dbf3cbdae11f3';

/// Timer state management provider using Riverpod.
///
/// Architecture decisions for battery efficiency:
/// 1. Uses [Timer.periodic] with 1-second intervals (not polling)
/// 2. Stores [_targetTime] (absolute DateTime) instead of decrementing counter
///    - More accurate: calculates remaining time from fixed end point
///    - Prevents drift from accumulated timing errors
/// 3. Cancellation token via [ref.onDispose] for cleanup
/// 4. Immediate service stop on timer complete/cancel via [_stopAuxiliaryServices]
/// 5. Throttled foreground service updates (every 5 seconds) to reduce IPC overhead
///
/// State updates:
/// - UI updates every second (via Timer.periodic)
/// - Foreground service updates throttled to every 5 seconds
/// - Final 10 seconds update every second for better UX
///
/// Copied from [TimerNotifier].
@ProviderFor(TimerNotifier)
final timerNotifierProvider =
    NotifierProvider<TimerNotifier, TimerState>.internal(
  TimerNotifier.new,
  name: r'timerNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$timerNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TimerNotifier = Notifier<TimerState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
