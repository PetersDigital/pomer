import 'package:flutter/material.dart';
import 'package:pomer/core/constants/app_constants.dart';

enum TimerPreset {
  classic,
  extended,
  custom,
}

extension TimerPresetDisplay on TimerPreset {
  String get label => switch (this) {
        TimerPreset.classic => 'Classic (25/5/15)',
        TimerPreset.extended => 'Extended (50/10/30)',
        TimerPreset.custom => 'Custom',
      };
}

@immutable
class SettingsState {
  const SettingsState({
    required this.focusDuration,
    required this.shortBreakDuration,
    required this.longBreakDuration,
    required this.autoStartBreaks,
    required this.autoStartPomodoros,
    required this.keepScreenOn,
    required this.soundEnabled,
    required this.notificationsEnabled,
    required this.themeMode,
    required this.selectedPreset,
  });

  factory SettingsState.initial() => const SettingsState(
        focusDuration: AppConstants.defaultFocusDuration,
        shortBreakDuration: AppConstants.defaultShortBreakDuration,
        longBreakDuration: AppConstants.defaultLongBreakDuration,
        autoStartBreaks: false,
        autoStartPomodoros: false,
        keepScreenOn: false,
        soundEnabled: true,
        notificationsEnabled: true,
        themeMode: ThemeMode.system,
        selectedPreset: TimerPreset.classic,
      );

  final int focusDuration;
  final int shortBreakDuration;
  final int longBreakDuration;
  final bool autoStartBreaks;
  final bool autoStartPomodoros;
  final bool keepScreenOn;
  final bool soundEnabled;
  final bool notificationsEnabled;
  final ThemeMode themeMode;
  final TimerPreset selectedPreset;

  SettingsState copyWith({
    int? focusDuration,
    int? shortBreakDuration,
    int? longBreakDuration,
    bool? autoStartBreaks,
    bool? autoStartPomodoros,
    bool? keepScreenOn,
    bool? soundEnabled,
    bool? notificationsEnabled,
    ThemeMode? themeMode,
    TimerPreset? selectedPreset,
  }) {
    return SettingsState(
      focusDuration: focusDuration ?? this.focusDuration,
      shortBreakDuration: shortBreakDuration ?? this.shortBreakDuration,
      longBreakDuration: longBreakDuration ?? this.longBreakDuration,
      autoStartBreaks: autoStartBreaks ?? this.autoStartBreaks,
      autoStartPomodoros: autoStartPomodoros ?? this.autoStartPomodoros,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      themeMode: themeMode ?? this.themeMode,
      selectedPreset: selectedPreset ?? this.selectedPreset,
    );
  }
}
