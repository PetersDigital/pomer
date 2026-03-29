import 'package:flutter/foundation.dart';
import 'package:pomer/core/utils/platform_utils.dart';

/// Service for detecting and managing battery optimization status.
///
/// This service provides diagnostics for battery optimization state
/// and helps educate users about battery impact without aggressively
/// requesting exemptions.
///
/// Key points:
/// - Detection only (no automatic exemption requests)
/// - User education via dialogs/settings UI
/// - Logging for debugging battery-related issues
class BatteryOptimizationService {
  bool? _isBatteryOptimized;

  /// Returns true if the app is battery-optimized (i.e., NOT in the
  /// ignore battery optimizations whitelist).
  ///
  /// Returns null if platform is not Android or detection failed.
  Future<bool?> isBatteryOptimized() async {
    if (!PlatformUtils.isAndroid) {
      debugPrint(
        '[BatteryOptimizationService] Platform is not Android, skipping detection',
      );
      return null;
    }

    try {
      // Note: We cannot directly check battery optimization status
      // without requesting the REQUEST_IGNORE_BATTERY_EXCEPTIONS permission.
      // This service is designed for diagnostics and user education.
      //
      // For actual detection, you would need to:
      // 1. Add permission_handler package
      // 2. Check Permission.ignoreBatteryOptimization.isGranted
      //
      // For now, we return null to indicate "unknown" status.
      debugPrint(
        '[BatteryOptimizationService] Battery optimization status: unknown (requires permission check)',
      );
      return _isBatteryOptimized;
    } catch (e) {
      debugPrint(
        '[BatteryOptimizationService] Failed to check battery optimization: $e',
      );
      return null;
    }
  }

  /// Returns true if the app has permission to ignore battery optimizations.
  ///
  /// This requires the REQUEST_IGNORE_BATTERY_EXCEPTIONS permission.
  Future<bool> isIgnoringBatteryOptimizations() async {
    if (!PlatformUtils.isAndroid) {
      return false;
    }

    try {
      // Note: Actual implementation would require:
      // import 'package:permission_handler/permission_handler.dart';
      // final status = await Permission.ignoreBatteryOptimization.status;
      // return status.isGranted;
      //
      // For now, return cached value or false.
      return _isBatteryOptimized ?? false;
    } catch (e) {
      debugPrint(
        '[BatteryOptimizationService] Failed to check ignore battery optimizations: $e',
      );
      return false;
    }
  }

  /// Logs the current battery optimization status for debugging.
  Future<void> logBatteryOptimizationStatus() async {
    final status = await isBatteryOptimized();
    final isIgnoring = await isIgnoringBatteryOptimizations();

    debugPrint(
      '[BatteryOptimizationService] Diagnostics:\n'
      '  - Is battery optimized: ${status ?? "unknown"}\n'
      '  - Is ignoring optimizations: $isIgnoring\n'
      '  - Platform: Android (${PlatformUtils.isAndroid})',
    );
  }

  /// Updates the cached battery optimization status.
  ///
  /// This should be called after the user interacts with battery
  /// optimization settings or grants/denies exemption.
  void updateStatus(bool isOptimized) {
    _isBatteryOptimized = isOptimized;
    debugPrint(
      '[BatteryOptimizationService] Status updated: isBatteryOptimized=$isOptimized',
    );
  }

  /// Returns a user-friendly message about battery optimization.
  String getUserEducationMessage() {
    if (_isBatteryOptimized == true) {
      return 'Battery optimization is enabled. This may cause timer interruptions when the screen is off. '
          'For best experience, consider disabling battery optimization for Pomer.';
    } else if (_isBatteryOptimized == false) {
      return 'Battery optimization is disabled. Pomer can run smoothly in the background without interruptions.';
    } else {
      return 'Battery optimization status is unknown. If you experience timer interruptions, '
          'consider disabling battery optimization for Pomer in system settings.';
    }
  }
}
