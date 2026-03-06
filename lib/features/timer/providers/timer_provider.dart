import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pomer/core/constants/app_constants.dart';
import 'package:pomer/features/settings/providers/settings_provider.dart';
import 'package:pomer/features/settings/models/settings_state.dart';
import 'package:pomer/features/timer/models/timer_state.dart';
import 'package:pomer/core/services/audio_service.dart';
import 'package:pomer/core/services/notification_service.dart';
import 'package:pomer/core/services/foreground_service.dart';
import 'package:pomer/features/timer/providers/audio_preferences_provider.dart';
import 'package:pomer/core/utils/time_utils.dart';
import 'package:pomer/core/providers/database_provider.dart';
import 'package:pomer/database/database.dart';

part 'timer_provider.g.dart';

@Riverpod(keepAlive: true)
class TimerNotifier extends _$TimerNotifier {
  Timer? _timer;
  DateTime? _targetTime;
  DateTime? _sessionStartTime;

  @override
  TimerState build() {
    final audioService = ref.read(audioServiceProvider);
    final foregroundService = ref.read(foregroundServiceProvider);
    final notificationService = ref.read(notificationServiceProvider);

    ref.onDispose(() {
      _timer?.cancel();
      unawaited(audioService.stopAmbient());
      unawaited(foregroundService.stopService());
      unawaited(notificationService.cancelAllNotifications());
    });

    // Listen to background actions
    ref.read(foregroundServiceProvider).registerActionCallback((action) {
      if (action == 'pause') {
        pause();
      } else if (action == 'resume') {
        start();
      } else if (action == 'skip') {
        skip();
      }
    });

    ref.listen(settingsNotifierProvider, (previous, next) {
      if (next.hasValue &&
          state.status == TimerStatus.idle &&
          state.completedCycles == 0 &&
          state.phase == TimerPhase.focus) {
        final isTesting = next.value!.selectedPreset == TimerPreset.testing;
        final focusDuration = isTesting ? 30 : next.value!.focusDuration * 60;

        if (state.totalSeconds != focusDuration) {
          state = state.copyWith(
            totalSeconds: focusDuration,
            remainingSeconds: focusDuration,
          );
        }
      }

      if (next.hasValue && state.status == TimerStatus.running) {
        final audioPrefs =
            ref.read(audioPreferencesNotifierProvider).valueOrNull;
        if (audioPrefs == null) return;

        final isFocusAudioEnabled = audioPrefs.focusAudioEnabled;
        final isBreakAudioEnabled = audioPrefs.breakAudioEnabled;

        final previousSettings = previous?.valueOrNull;
        final currentSettings = next.value!;
        final focusTrackChanged = previousSettings?.focusAmbientTrack !=
            currentSettings.focusAmbientTrack;
        final longBreakTrackChanged =
            previousSettings?.longBreakTrack != currentSettings.longBreakTrack;

        if ((state.phase == TimerPhase.focus &&
                focusTrackChanged &&
                isFocusAudioEnabled) ||
            (state.phase == TimerPhase.longBreak &&
                longBreakTrackChanged &&
                isBreakAudioEnabled)) {
          final assetPath = _selectedPhaseAudioAssetPath;
          if (assetPath != null) {
            ref.read(audioServiceProvider).playAmbient(
                  ambientAssetPath: assetPath,
                );
          }
        }
      }
    });

    // Listen to audio preferences dynamically
    ref.listen(audioPreferencesNotifierProvider, (previous, next) {
      if (state.status == TimerStatus.running && next.hasValue) {
        final prefs = next.value!;
        final previousPrefs = previous?.valueOrNull;
        final assetPath = _selectedPhaseAudioAssetPath;

        final focusPrefChanged =
            previousPrefs?.focusAudioEnabled != prefs.focusAudioEnabled;
        final breakPrefChanged =
            previousPrefs?.breakAudioEnabled != prefs.breakAudioEnabled;

        final shouldReactToChange =
            (state.phase == TimerPhase.focus && focusPrefChanged) ||
                ((state.phase == TimerPhase.longBreak ||
                        state.phase == TimerPhase.shortBreak) &&
                    breakPrefChanged);

        if (!shouldReactToChange) {
          return;
        }

        bool shouldPlay = false;
        if (state.phase == TimerPhase.focus) {
          shouldPlay = prefs.focusAudioEnabled;
        } else if (state.phase == TimerPhase.longBreak ||
            state.phase == TimerPhase.shortBreak) {
          shouldPlay = prefs.breakAudioEnabled;
        }

        if (shouldPlay && assetPath != null) {
          ref.read(audioServiceProvider).playAmbient(
                ambientAssetPath: assetPath,
              );
        } else {
          ref.read(audioServiceProvider).stopAmbient();
        }
      }
    });

    return TimerState.initial();
  }

  void start({bool shouldPlayPhaseAudio = true}) {
    if (state.status == TimerStatus.running) return;

    // Trigger permission requests right when user starts a session.
    // This is especially crucial for Web where browsers require a
    // direct user interaction (like a button click) to show the prompt.
    ref.read(notificationServiceProvider).requestPermissions();

    // Calculate target time based on remaining seconds
    final now = DateTime.now();
    _targetTime = now.add(Duration(seconds: state.remainingSeconds));

    // Set start time only if starting a fresh session
    if (state.status == TimerStatus.idle) {
      _sessionStartTime = now;
    }

    state = state.copyWith(status: TimerStatus.running);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());

    // Play configured phase sound for focus and long break only
    final audioPrefs = ref.read(audioPreferencesNotifierProvider).valueOrNull;
    final isFocusAudioEnabled = audioPrefs?.focusAudioEnabled ?? true;
    final isBreakAudioEnabled = audioPrefs?.breakAudioEnabled ?? true;

    bool isAudioEnabledForPhase = false;
    if (state.phase == TimerPhase.focus) {
      isAudioEnabledForPhase = isFocusAudioEnabled;
    } else if (state.phase == TimerPhase.longBreak ||
        state.phase == TimerPhase.shortBreak) {
      isAudioEnabledForPhase = isBreakAudioEnabled;
    }

    final assetPath = _selectedPhaseAudioAssetPath;
    if (shouldPlayPhaseAudio && isAudioEnabledForPhase && assetPath != null) {
      ref.read(audioServiceProvider).playAmbient(
            ambientAssetPath: assetPath,
          );
    }

    // Update foreground service to show "Pause" button
    final String phaseText = state.phase.name.toUpperCase();
    ref.read(foregroundServiceProvider).startService(
          phaseText,
          state.remainingSeconds.toMMSS(),
          isPaused: false,
        );
  }

  void pause() {
    if (state.status != TimerStatus.running) return;
    _timer?.cancel();
    _timer = null;
    _targetTime = null;
    state = state.copyWith(status: TimerStatus.paused);

    // Stop audio
    ref.read(audioServiceProvider).stopAmbient();

    // Update foreground service to show "Resume" button
    final String phaseText = state.phase.name.toUpperCase();
    ref.read(foregroundServiceProvider).startService(
          '$phaseText (Paused)',
          state.remainingSeconds.toMMSS(),
          isPaused: true,
        );
  }

  void reset() {
    unawaited(_handleSessionLogging(isCompleted: false, status: 'interrupted'));

    _timer?.cancel();
    _timer = null;
    _targetTime = null;
    _sessionStartTime = null;

    final settingsAsync = ref.read(settingsNotifierProvider);
    final settings = settingsAsync.valueOrNull;
    final isTesting = settings?.selectedPreset == TimerPreset.testing;

    final focusDurationSeconds = isTesting
        ? 30
        : (settings?.focusDuration ?? AppConstants.defaultFocusDuration) * 60;

    state = TimerState.initial().copyWith(
      totalSeconds: focusDurationSeconds,
      remainingSeconds: focusDurationSeconds,
    );

    _stopAuxiliaryServices();
  }

  void _stopAuxiliaryServices() {
    unawaited(ref.read(audioServiceProvider).stopAmbient());
    unawaited(ref.read(foregroundServiceProvider).stopService());
    unawaited(ref.read(notificationServiceProvider).cancelAllNotifications());
  }

  void skip() {
    unawaited(_handleSessionLogging(isCompleted: false, status: 'skipped'));
    _handlePhaseTransition();
  }

  void _onTick() {
    if (_targetTime == null) return;

    final now = DateTime.now();
    final remaining = _targetTime!.difference(now).inSeconds;

    // Update remaining time if we haven't reached zero yet, or if we are exactly at zero
    // (to allow showing "00:00" for a moment before transition).
    if (remaining >= 0) {
      if (remaining != state.remainingSeconds) {
        state = state.copyWith(remainingSeconds: remaining);

        // Update foreground service every 5 seconds or when remaining is small
        if (remaining % 5 == 0 || remaining <= 5) {
          final String phaseText = state.phase.name.toUpperCase();
          ref.read(foregroundServiceProvider).startService(
                phaseText,
                remaining.toMMSS(),
                isPaused: state.status == TimerStatus.paused,
              );
        }
      }
      return;
    }

    // remaining <= 0 → transition to next phase.
    _handlePhaseTransition(isNaturalCompletion: true);
  }

  Future<void> _handleSessionLogging({
    required bool isCompleted,
    required String status,
  }) async {
    if (_sessionStartTime == null) return;

    final now = DateTime.now();
    final totalPlannedSeconds = state.totalSeconds;
    final remainingSeconds = state.remainingSeconds;
    final actualDurationSeconds = totalPlannedSeconds - remainingSeconds;

    final isTesting =
        ref.read(settingsNotifierProvider).valueOrNull?.selectedPreset ==
            TimerPreset.testing;
    final minimumDurationSeconds = (isTesting || kDebugMode) ? 1 : 60;

    if (actualDurationSeconds < minimumDurationSeconds) {
      return;
    }

    final db = ref.read(appDatabaseProvider);
    try {
      await db.into(db.sessions).insert(
            SessionsCompanion.insert(
              startTime: _sessionStartTime!,
              endTime: now,
              durationSeconds: actualDurationSeconds,
              phaseType: state.phase.name,
              status: status,
            ),
          );
    } catch (e) {
      debugPrint('Failed to log session: $e');
    }
  }

  void _handlePhaseTransition({bool isNaturalCompletion = false}) {
    if (isNaturalCompletion) {
      unawaited(_handleSessionLogging(isCompleted: true, status: 'completed'));
    }

    final previousPhase = state.phase;

    _timer?.cancel();
    _timer = null;
    _targetTime = null;
    _sessionStartTime = null;

    ref.read(audioServiceProvider).stopAmbient();

    final settingsAsync = ref.read(settingsNotifierProvider);
    final settings = settingsAsync.valueOrNull;
    final audioPrefs = ref.read(audioPreferencesNotifierProvider).valueOrNull;
    final isAlarmAudioEnabled = audioPrefs?.alarmAudioEnabled ?? true;

    final useSystemNotificationSound =
        settings?.useSystemNotificationSound ?? false;
    final alarmAssetPath = previousPhase == TimerPhase.shortBreak
        ? 'assets/audio/alarm_x4.ogg'
        : 'assets/audio/alarm_x1.ogg';

    if (isAlarmAudioEnabled && !useSystemNotificationSound) {
      ref.read(audioServiceProvider).playAlarm(
            alarmAssetPath: alarmAssetPath,
          );
    }

    if (settings?.notificationsEnabled ?? true) {
      ref.read(notificationServiceProvider).showNotification(
            id: 0,
            title: '${state.phase.label} - Done',
            body: '',
            playSound: isAlarmAudioEnabled && useSystemNotificationSound,
          );
    } else {
      unawaited(
        ref.read(notificationServiceProvider).cancelAllNotifications(),
      );
    }

    final isTesting = settings?.selectedPreset == TimerPreset.testing;

    final focusDurationSeconds = isTesting
        ? 30
        : (settings?.focusDuration ?? AppConstants.defaultFocusDuration) * 60;
    final shortBreakDurationSeconds = isTesting
        ? 15
        : (settings?.shortBreakDuration ??
                AppConstants.defaultShortBreakDuration) *
            60;
    final longBreakDurationSeconds = isTesting
        ? 60
        : (settings?.longBreakDuration ??
                AppConstants.defaultLongBreakDuration) *
            60;

    state = _nextPhaseState(
      current: state,
      focusDurationSeconds: focusDurationSeconds,
      shortBreakDurationSeconds: shortBreakDurationSeconds,
      longBreakDurationSeconds: longBreakDurationSeconds,
    );

    // Auto-start next phase logic
    var didAutoStart = false;
    if (settingsAsync.hasValue) {
      final settings = settingsAsync.value!;
      if ((state.phase == TimerPhase.shortBreak ||
              state.phase == TimerPhase.longBreak) &&
          settings.autoStartBreaks) {
        start();
        didAutoStart = true;
      } else if (state.phase == TimerPhase.focus &&
          settings.autoStartPomodoros) {
        if (previousPhase == TimerPhase.longBreak) {
          start(shouldPlayPhaseAudio: false);
          final focusAssetPath = _selectedPhaseAudioAssetPath;
          if (audioPrefs?.focusAudioEnabled == true && focusAssetPath != null) {
            ref.read(audioServiceProvider).transitionAmbient(
                  ambientAssetPath: focusAssetPath,
                  transitionDuration: const Duration(seconds: 3),
                );
          }
        } else {
          start();
        }
        didAutoStart = true;
      }
    }

    if (!didAutoStart) {
      ref.read(foregroundServiceProvider).stopService();
    }
  }

  TimerState _nextPhaseState({
    required TimerState current,
    required int focusDurationSeconds,
    required int shortBreakDurationSeconds,
    required int longBreakDurationSeconds,
  }) {
    switch (current.phase) {
      case TimerPhase.focus:
        final newCycles = current.completedCycles + 1;
        final newTotal = current.totalSessionsCompleted + 1;
        if (newCycles >= AppConstants.defaultCyclesBeforeLongBreak) {
          return current.copyWith(
            phase: TimerPhase.longBreak,
            status: TimerStatus.idle,
            totalSeconds: longBreakDurationSeconds,
            remainingSeconds: longBreakDurationSeconds,
            completedCycles: newCycles,
            totalSessionsCompleted: newTotal,
          );
        }
        return current.copyWith(
          phase: TimerPhase.shortBreak,
          status: TimerStatus.idle,
          totalSeconds: shortBreakDurationSeconds,
          remainingSeconds: shortBreakDurationSeconds,
          completedCycles: newCycles,
          totalSessionsCompleted: newTotal,
        );
      case TimerPhase.shortBreak:
        return current.copyWith(
          phase: TimerPhase.focus,
          status: TimerStatus.idle,
          totalSeconds: focusDurationSeconds,
          remainingSeconds: focusDurationSeconds,
        );
      case TimerPhase.longBreak:
        return current.copyWith(
          phase: TimerPhase.focus,
          status: TimerStatus.idle,
          totalSeconds: focusDurationSeconds,
          remainingSeconds: focusDurationSeconds,
          completedCycles: 0,
        );
    }
  }

  String? get _selectedPhaseAudioAssetPath {
    final settings = ref.read(settingsNotifierProvider).valueOrNull;
    switch (state.phase) {
      case TimerPhase.focus:
        return settings?.focusAmbientTrack.assetPath ??
            FocusAmbientTrack.stream.assetPath;
      case TimerPhase.longBreak:
        return settings?.longBreakTrack.assetPath ??
            LongBreakTrack.easyGoing.assetPath;
      case TimerPhase.shortBreak:
        return null;
    }
  }
}
