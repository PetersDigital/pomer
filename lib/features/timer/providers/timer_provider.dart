import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomer/core/constants/app_constants.dart';
import 'package:pomer/features/timer/models/timer_state.dart';

class TimerNotifier extends StateNotifier<TimerState> {
  TimerNotifier() : super(TimerState.initial());

  Timer? _timer;

  void start() {
    if (state.status == TimerStatus.running) return;
    state = state.copyWith(status: TimerStatus.running);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
  }

  void pause() {
    if (state.status != TimerStatus.running) return;
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(status: TimerStatus.paused);
  }

  void reset() {
    _timer?.cancel();
    _timer = null;
    state = TimerState.initial();
  }

  void skip() {
    _timer?.cancel();
    _timer = null;
    state = _nextPhaseState(state);
  }

  void _onTick() {
    if (state.remainingSeconds > 0) {
      state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      return;
    }
    // remainingSeconds == 0 → transition to next phase.
    _timer?.cancel();
    _timer = null;
    state = _nextPhaseState(state);
  }

  TimerState _nextPhaseState(TimerState current) {
    switch (current.phase) {
      case TimerPhase.focus:
        final newCycles = current.completedCycles + 1;
        final newTotal = current.totalSessionsCompleted + 1;
        if (newCycles >= AppConstants.defaultCyclesBeforeLongBreak) {
          return current.copyWith(
            phase: TimerPhase.longBreak,
            status: TimerStatus.idle,
            totalSeconds: AppConstants.defaultLongBreakDuration * 60,
            remainingSeconds: AppConstants.defaultLongBreakDuration * 60,
            completedCycles: 0,
            totalSessionsCompleted: newTotal,
          );
        }
        return current.copyWith(
          phase: TimerPhase.shortBreak,
          status: TimerStatus.idle,
          totalSeconds: AppConstants.defaultShortBreakDuration * 60,
          remainingSeconds: AppConstants.defaultShortBreakDuration * 60,
          completedCycles: newCycles,
          totalSessionsCompleted: newTotal,
        );
      case TimerPhase.shortBreak:
      case TimerPhase.longBreak:
        return current.copyWith(
          phase: TimerPhase.focus,
          status: TimerStatus.idle,
          totalSeconds: AppConstants.defaultFocusDuration * 60,
          remainingSeconds: AppConstants.defaultFocusDuration * 60,
        );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>(
  (ref) => TimerNotifier(),
);
