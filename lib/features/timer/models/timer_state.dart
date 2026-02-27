import 'package:flutter/foundation.dart';
import 'package:pomer/core/constants/app_constants.dart';

enum TimerPhase { focus, shortBreak, longBreak }

extension TimerPhaseDisplay on TimerPhase {
  String get label => switch (this) {
        TimerPhase.focus => 'Focus',
        TimerPhase.shortBreak => 'Short Break',
        TimerPhase.longBreak => 'Long Break',
      };
}

enum TimerStatus { idle, running, paused }

@immutable
class TimerState {
  const TimerState({
    required this.phase,
    required this.status,
    required this.totalSeconds,
    required this.remainingSeconds,
    required this.completedCycles,
    required this.totalSessionsCompleted,
  });

  factory TimerState.initial() => const TimerState(
        phase: TimerPhase.focus,
        status: TimerStatus.idle,
        totalSeconds: AppConstants.defaultFocusDuration * 60,
        remainingSeconds: AppConstants.defaultFocusDuration * 60,
        completedCycles: 0,
        totalSessionsCompleted: 0,
      );

  final TimerPhase phase;
  final TimerStatus status;
  final int totalSeconds;
  final int remainingSeconds;
  final int completedCycles;
  final int totalSessionsCompleted;

  TimerState copyWith({
    TimerPhase? phase,
    TimerStatus? status,
    int? totalSeconds,
    int? remainingSeconds,
    int? completedCycles,
    int? totalSessionsCompleted,
  }) =>
      TimerState(
        phase: phase ?? this.phase,
        status: status ?? this.status,
        totalSeconds: totalSeconds ?? this.totalSeconds,
        remainingSeconds: remainingSeconds ?? this.remainingSeconds,
        completedCycles: completedCycles ?? this.completedCycles,
        totalSessionsCompleted:
            totalSessionsCompleted ?? this.totalSessionsCompleted,
      );
}
