import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pomer/core/constants/app_constants.dart';
import 'package:pomer/features/timer/models/timer_state.dart';

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
    return TimerState.initial();
  }

  void start() {
    if (state.status == TimerStatus.running) return;

    // Calculate target time based on remaining seconds
    _targetTime = DateTime.now().add(Duration(seconds: state.remainingSeconds));

    state = state.copyWith(status: TimerStatus.running);
    _timer = Timer.periodic(const Duration(milliseconds: 200), (_) => _onTick());
  }

  void pause() {
    if (state.status != TimerStatus.running) return;
    _timer?.cancel();
    _timer = null;
    _targetTime = null;
    state = state.copyWith(status: TimerStatus.paused);
  }

  void reset() {
    _timer?.cancel();
    _timer = null;
    _targetTime = null;
    state = TimerState.initial();
  }

  void skip() {
    _timer?.cancel();
    _timer = null;
    _targetTime = null;
    state = _nextPhaseState(state);
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
      }
      return;
    }

    // remaining <= 0 → transition to next phase.
    _timer?.cancel();
    _timer = null;
    _targetTime = null;
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
}
