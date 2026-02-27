import 'package:flutter/material.dart';
import 'package:pomer/features/timer/models/timer_state.dart';

/// Returns the display colour for [phase] from the given [scheme].
Color phaseColor(TimerPhase phase, ColorScheme scheme) => switch (phase) {
      TimerPhase.focus => scheme.primary,
      TimerPhase.shortBreak => scheme.tertiary,
      TimerPhase.longBreak => scheme.secondary,
    };
