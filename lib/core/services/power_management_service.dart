import 'package:flutter/foundation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:pomer/core/utils/platform_utils.dart';

/// Service for managing wake locks during timer sessions.
///
/// Wake locks are only acquired when:
/// - The screen is on
/// - The timer is actively running
/// - The platform supports it (Android/Windows)
///
/// This prevents battery drain by allowing the device to enter
/// deep sleep when the screen is off or timer is paused.
class PowerManagementService {
  bool _isWakeLockHeld = false;
  bool _isScreenOn = true;

  /// Acquires a wake lock to keep the CPU running during timer sessions.
  /// Only acquires if screen is on and platform supports it.
  Future<void> acquireForTimer() async {
    if (!PlatformUtils.isMobile && !PlatformUtils.isWindows) {
      return;
    }

    if (_isWakeLockHeld || !_isScreenOn) {
      if (!_isScreenOn) {
        debugPrint(
          '[PowerManagementService] Skipping wake lock acquisition - screen is off',
        );
      }
      return;
    }

    try {
      await WakelockPlus.enable();
      _isWakeLockHeld = true;
      debugPrint('[PowerManagementService] Wake lock acquired');
    } catch (e) {
      debugPrint('[PowerManagementService] Failed to acquire wake lock: $e');
    }
  }

  /// Releases the wake lock when timer is paused, completed, or screen is off.
  Future<void> releaseWhenIdle() async {
    if (!_isWakeLockHeld) {
      return;
    }

    try {
      await WakelockPlus.disable();
      _isWakeLockHeld = false;
      debugPrint('[PowerManagementService] Wake lock released');
    } catch (e) {
      debugPrint('[PowerManagementService] Failed to release wake lock: $e');
    }
  }

  /// Returns true if wake lock is currently held.
  bool get isWakeLockHeld => _isWakeLockHeld;

  /// Updates the screen state.
  /// When screen turns off, wake lock is automatically released.
  void updateScreenState(bool isScreenOn) {
    _isScreenOn = isScreenOn;
    if (!isScreenOn && _isWakeLockHeld) {
      debugPrint(
        '[PowerManagementService] Screen turned off, releasing wake lock',
      );
      releaseWhenIdle();
    }
  }

  /// Synchronizes wake lock state with timer state.
  /// Acquires when running and screen is on, releases when idle/paused.
  Future<void> syncWithTimerState(bool isRunning) async {
    if (isRunning && _isScreenOn) {
      await acquireForTimer();
    } else {
      await releaseWhenIdle();
    }
  }
}
