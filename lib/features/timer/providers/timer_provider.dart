import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pomer/core/constants/app_constants.dart';
import 'package:pomer/features/settings/providers/settings_provider.dart';
import 'package:pomer/features/timer/models/timer_state.dart';
import 'package:pomer/core/services/audio_service.dart';
import 'package:pomer/core/services/notification_service.dart';
import 'package:pomer/core/services/foreground_service.dart';
import 'package:pomer/features/timer/providers/audio_enabled_provider.dart';
import 'package:pomer/core/utils/time_utils.dart';

part 'timer_provider.g.dart';

@Riverpod(keepAlive: true)
class TimerNotifier extends _$TimerNotifier {
  Timer? _timer;
  DateTime? _targetTime;

  @override
  TimerState build() {
    ref.onDispose(() {
      _timer?.cancel();
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
        final focusDuration = next.value!.focusDuration * 60;
        if (state.totalSeconds != focusDuration) {
          state = state.copyWith(
            totalSeconds: focusDuration,
            remainingSeconds: focusDuration,
          );
        }
      }
    });

    // Listen to audio enabled toggle dynamically
    ref.listen(audioEnabledNotifierProvider, (previous, next) {
      if (state.status == TimerStatus.running &&
          state.phase == TimerPhase.focus) {
        if (next) {
          ref.read(audioServiceProvider).playAmbient();
        } else {
          ref.read(audioServiceProvider).stopAmbient();
        }
      }
    });

    return TimerState.initial();
  }

  void start() {
    if (state.status == TimerStatus.running) return;

    // Calculate target time based on remaining seconds
    _targetTime = DateTime.now().add(Duration(seconds: state.remainingSeconds));

    state = state.copyWith(status: TimerStatus.running);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());

    // Play ambient sound if in focus mode
    final isAudioEnabled = ref.read(audioEnabledNotifierProvider);
    if (state.phase == TimerPhase.focus && isAudioEnabled) {
      ref.read(audioServiceProvider).playAmbient();
    }

    // Update foreground service to show "Pause" button
    final String phaseText = state.phase.name.toUpperCase();
    ref.read(foregroundServiceProvider).startService(
          'Pomer - $phaseText',
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
          'Pomer - $phaseText (Paused)',
          state.remainingSeconds.toMMSS(),
          isPaused: true,
        );
  }

  void reset() {
    _timer?.cancel();
    _timer = null;
    _targetTime = null;

    final settingsAsync = ref.read(settingsNotifierProvider);
    final focusDuration = settingsAsync.valueOrNull?.focusDuration ??
        AppConstants.defaultFocusDuration;

    state = TimerState.initial().copyWith(
      totalSeconds: focusDuration * 60,
      remainingSeconds: focusDuration * 60,
    );

    _stopAuxiliaryServices();
  }

  void _stopAuxiliaryServices() {
    ref.read(audioServiceProvider).stopAmbient();
    ref.read(foregroundServiceProvider).stopService();
  }

  void skip() {
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

        // Update foreground service
        final String phaseText = state.phase.name.toUpperCase();
        ref.read(foregroundServiceProvider).startService(
              'Pomer - $phaseText',
              remaining.toMMSS(),
              isPaused: state.status == TimerStatus.paused,
            );
      }
      return;
    }

    // remaining <= 0 → transition to next phase.
    _handlePhaseTransition();
  }

  void _handlePhaseTransition() {
    _timer?.cancel();
    _timer = null;
    _targetTime = null;

    ref.read(audioServiceProvider).stopAmbient();

    final isAudioEnabled = ref.read(audioEnabledNotifierProvider);
    if (isAudioEnabled) {
      ref.read(audioServiceProvider).playAlarm();
    }

    ref.read(notificationServiceProvider).showNotification(
          id: 0,
          title: 'Pomer Phase Complete',
          body: 'Your ${state.phase.name} phase has finished.',
        );

    final settingsAsync = ref.read(settingsNotifierProvider);
    final focusDuration = settingsAsync.valueOrNull?.focusDuration ??
        AppConstants.defaultFocusDuration;
    final shortBreakDuration = settingsAsync.valueOrNull?.shortBreakDuration ??
        AppConstants.defaultShortBreakDuration;
    final longBreakDuration = settingsAsync.valueOrNull?.longBreakDuration ??
        AppConstants.defaultLongBreakDuration;

    state = _nextPhaseState(
      current: state,
      focusDuration: focusDuration,
      shortBreakDuration: shortBreakDuration,
      longBreakDuration: longBreakDuration,
    );

    // Auto-start next phase logic
    if (settingsAsync.hasValue) {
      final settings = settingsAsync.value!;
      if ((state.phase == TimerPhase.shortBreak ||
              state.phase == TimerPhase.longBreak) &&
          settings.autoStartBreaks) {
        start();
      } else if (state.phase == TimerPhase.focus &&
          settings.autoStartPomodoros) {
        start();
      }
    }
  }

  TimerState _nextPhaseState({
    required TimerState current,
    required int focusDuration,
    required int shortBreakDuration,
    required int longBreakDuration,
  }) {
    switch (current.phase) {
      case TimerPhase.focus:
        final newCycles = current.completedCycles + 1;
        final newTotal = current.totalSessionsCompleted + 1;
        if (newCycles >= AppConstants.defaultCyclesBeforeLongBreak) {
          return current.copyWith(
            phase: TimerPhase.longBreak,
            status: TimerStatus.idle,
            totalSeconds: longBreakDuration * 60,
            remainingSeconds: longBreakDuration * 60,
            completedCycles: newCycles,
            totalSessionsCompleted: newTotal,
          );
        }
        return current.copyWith(
          phase: TimerPhase.shortBreak,
          status: TimerStatus.idle,
          totalSeconds: shortBreakDuration * 60,
          remainingSeconds: shortBreakDuration * 60,
          completedCycles: newCycles,
          totalSessionsCompleted: newTotal,
        );
      case TimerPhase.shortBreak:
        return current.copyWith(
          phase: TimerPhase.focus,
          status: TimerStatus.idle,
          totalSeconds: focusDuration * 60,
          remainingSeconds: focusDuration * 60,
        );
      case TimerPhase.longBreak:
        return current.copyWith(
          phase: TimerPhase.focus,
          status: TimerStatus.idle,
          totalSeconds: focusDuration * 60,
          remainingSeconds: focusDuration * 60,
          completedCycles: 0,
        );
    }
  }
}
