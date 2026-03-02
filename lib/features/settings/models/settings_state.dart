import 'package:flutter/material.dart';
import 'package:pomer/core/constants/app_constants.dart';

enum TimerPreset {
  classic,
  extended,
  custom,
}

enum FocusAmbientTrack {
  calmRiver,
  stream,
  meadow,
  thunderstorm,
  wind,
}

enum LongBreakTrack {
  easyGoing,
  commercialA,
  commercialB,
}

extension TimerPresetDisplay on TimerPreset {
  String get label => switch (this) {
        TimerPreset.classic => 'Classic (25/5/15)',
        TimerPreset.extended => 'Extended (50/10/30)',
        TimerPreset.custom => 'Custom',
      };
}

extension FocusAmbientTrackDisplay on FocusAmbientTrack {
  String get label => switch (this) {
        FocusAmbientTrack.calmRiver => 'Calm River',
        FocusAmbientTrack.stream => 'Stream',
        FocusAmbientTrack.meadow => 'Meadow',
        FocusAmbientTrack.thunderstorm => 'Thunderstorm',
        FocusAmbientTrack.wind => 'Wind',
      };

  String get assetPath => switch (this) {
        FocusAmbientTrack.calmRiver =>
          'assets/audio/ambience_calm_river_loop.ogg',
        FocusAmbientTrack.stream => 'assets/audio/ambience_stream_loop.ogg',
        FocusAmbientTrack.meadow => 'assets/audio/ambience_meadow_loop.ogg',
        FocusAmbientTrack.thunderstorm =>
          'assets/audio/ambience_thunderstorm_loop.ogg',
        FocusAmbientTrack.wind => 'assets/audio/ambience_wind_loop.ogg',
      };
}

extension LongBreakTrackDisplay on LongBreakTrack {
  String get label => switch (this) {
        LongBreakTrack.easyGoing => 'Easy Going',
        LongBreakTrack.commercialA => 'Commercial A',
        LongBreakTrack.commercialB => 'Commercial B',
      };

  String get assetPath => switch (this) {
        LongBreakTrack.easyGoing => 'assets/audio/break_easy_going_loop.ogg',
        LongBreakTrack.commercialA =>
          'assets/audio/break_happy_commercial_loop_A.ogg',
        LongBreakTrack.commercialB =>
          'assets/audio/break_happy_commercial_loop_B.ogg',
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
    required this.useSystemNotificationSound,
    required this.themeMode,
    required this.selectedPreset,
    required this.focusAmbientTrack,
    required this.longBreakTrack,
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
        useSystemNotificationSound: false,
        themeMode: ThemeMode.system,
        selectedPreset: TimerPreset.classic,
        focusAmbientTrack: FocusAmbientTrack.stream,
        longBreakTrack: LongBreakTrack.easyGoing,
      );

  final int focusDuration;
  final int shortBreakDuration;
  final int longBreakDuration;
  final bool autoStartBreaks;
  final bool autoStartPomodoros;
  final bool keepScreenOn;
  final bool soundEnabled;
  final bool notificationsEnabled;
  final bool useSystemNotificationSound;
  final ThemeMode themeMode;
  final TimerPreset selectedPreset;
  final FocusAmbientTrack focusAmbientTrack;
  final LongBreakTrack longBreakTrack;

  SettingsState copyWith({
    int? focusDuration,
    int? shortBreakDuration,
    int? longBreakDuration,
    bool? autoStartBreaks,
    bool? autoStartPomodoros,
    bool? keepScreenOn,
    bool? soundEnabled,
    bool? notificationsEnabled,
    bool? useSystemNotificationSound,
    ThemeMode? themeMode,
    TimerPreset? selectedPreset,
    FocusAmbientTrack? focusAmbientTrack,
    LongBreakTrack? longBreakTrack,
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
      useSystemNotificationSound:
          useSystemNotificationSound ?? this.useSystemNotificationSound,
      themeMode: themeMode ?? this.themeMode,
      selectedPreset: selectedPreset ?? this.selectedPreset,
      focusAmbientTrack: focusAmbientTrack ?? this.focusAmbientTrack,
      longBreakTrack: longBreakTrack ?? this.longBreakTrack,
    );
  }
}
