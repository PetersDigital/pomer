import 'package:flutter/foundation.dart';

/// Diagnostics logger for timer-related events.
///
/// This service provides structured logging for:
/// - Foreground service start/stop events
/// - Timer callback frequency detection
/// - Battery usage diagnostics
/// - Debug mode toggle for development
///
/// All logs are prefixed with `[TimerDiagnostics]` for easy filtering.
class TimerDiagnostics {
  static const String _tag = '[TimerDiagnostics]';

  int _callbackCount = 0;
  DateTime? _lastCallbackTime;
  double? _lastCallbackFrequency;
  bool _debugModeEnabled = false;

  /// Returns true if debug mode is enabled.
  bool get isDebugModeEnabled => _debugModeEnabled;

  /// Enables or disables debug mode.
  ///
  /// When enabled, additional verbose logs are printed.
  void setDebugMode(bool enabled) {
    _debugModeEnabled = enabled;
    log('Debug mode ${enabled ? 'enabled' : 'disabled'}');
  }

  /// Logs a foreground service start event.
  void logForegroundServiceStart(String phase, String remainingTime) {
    log('Foreground service started: phase=$phase, remaining=$remainingTime');
  }

  /// Logs a foreground service stop event.
  void logForegroundServiceStop() {
    log('Foreground service stopped');
  }

  /// Logs a foreground service update event.
  void logForegroundServiceUpdate(String phase, String remainingTime) {
    if (_debugModeEnabled) {
      log('Foreground service updated: phase=$phase, remaining=$remainingTime');
    }
  }

  /// Tracks timer callback frequency to detect if callbacks are firing too fast.
  void trackCallback() {
    _callbackCount++;
    final now = DateTime.now();

    if (_lastCallbackTime != null) {
      final elapsed = now.difference(_lastCallbackTime!).inMilliseconds;
      if (elapsed > 0) {
        _lastCallbackFrequency = 1000 / elapsed; // callbacks per second
      }
    }

    _lastCallbackTime = now;

    // Warn if callback frequency is too high (>2 per second)
    if (_lastCallbackFrequency != null && _lastCallbackFrequency! > 2) {
      logWarning(
        'Callback frequency too high: ${_lastCallbackFrequency!.toStringAsFixed(1)} callbacks/sec. '
        'Expected: 1 callback/sec.',
      );
    }

    // Log summary every 60 callbacks (approximately every minute)
    if (_callbackCount % 60 == 0) {
      log('Callback summary: $_callbackCount callbacks in ${_callbackCount ~/ 60} minute(s)');
    }
  }

  /// Logs a CPU usage snapshot (manual, as Flutter cannot directly read CPU usage).
  void logCpuSnapshot({
    String? label,
    int? foregroundUpdateCount,
    int? timerTickCount,
  }) {
    log(
      'CPU snapshot: ${label ?? 'general'} | '
      'foregroundUpdates=$foregroundUpdateCount | '
      'timerTicks=$timerTickCount',
    );
  }

  /// Logs battery-related diagnostics.
  void logBatteryDiagnostics({
    bool? isScreenOn,
    bool? isTimerRunning,
    bool? isWakeLockHeld,
    bool? isBatteryOptimized,
  }) {
    log(
      'Battery diagnostics: '
      'screenOn=$isScreenOn | '
      'timerRunning=$isTimerRunning | '
      'wakeLockHeld=$isWakeLockHeld | '
      'batteryOptimized=$isBatteryOptimized',
    );
  }

  /// Logs a general timer event.
  void logTimerEvent(String event, {Map<String, dynamic>? data}) {
    if (_debugModeEnabled) {
      final dataStr = data?.entries.map((e) => '${e.key}=${e.value}').join(', ') ?? '';
      log('Event: $event ${dataStr.isNotEmpty ? '($dataStr)' : ''}');
    }
  }

  /// Logs a phase transition event.
  void logPhaseTransition(String fromPhase, String toPhase, bool autoStarted) {
    log('Phase transition: $fromPhase → $toPhase (autoStart=$autoStarted)');
  }

  /// Logs a session completion event.
  void logSessionComplete({
    required String phase,
    required int durationSeconds,
    required String status,
  }) {
    log(
      'Session complete: phase=$phase, duration=${durationSeconds}s, status=$status',
    );
  }

  /// Resets callback statistics.
  void resetStats() {
    _callbackCount = 0;
    _lastCallbackTime = null;
    _lastCallbackFrequency = null;
    log('Diagnostics stats reset');
  }

  /// Returns current callback statistics.
  Map<String, dynamic> getStats() {
    return {
      'callbackCount': _callbackCount,
      'lastCallbackFrequency': _lastCallbackFrequency,
      'debugModeEnabled': _debugModeEnabled,
    };
  }

  /// Logs a message with the timer diagnostics tag.
  void log(String message) {
    debugPrint('$_tag $message');
  }

  /// Logs a warning message.
  void logWarning(String message) {
    debugPrint('$_tag ⚠️ WARNING: $message');
  }

  /// Logs an error message.
  void logError(String message, [Object? error, StackTrace? stackTrace]) {
    debugPrint('$_tag ❌ ERROR: $message');
    if (error != null) {
      debugPrint('$_tag Error details: $error');
    }
    if (stackTrace != null) {
      debugPrint('$_tag Stack trace: $stackTrace');
    }
  }
}

/// Global singleton instance for easy access.
final timerDiagnostics = TimerDiagnostics();
