import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomer/core/constants/app_constants.dart';
import 'package:pomer/features/settings/models/settings_state.dart';

void main() {
  group('SettingsState', () {
    test('initial() has correct defaults', () {
      final state = SettingsState.initial();

      expect(state.focusDuration, AppConstants.defaultFocusDuration);
      expect(state.shortBreakDuration, AppConstants.defaultShortBreakDuration);
      expect(state.longBreakDuration, AppConstants.defaultLongBreakDuration);
      expect(state.autoStartBreaks, isFalse);
      expect(state.autoStartPomodoros, isFalse);
      expect(state.keepScreenOn, isFalse);
      expect(state.soundEnabled, isTrue);
      expect(state.notificationsEnabled, isTrue);
      expect(state.themeMode, ThemeMode.system);
      expect(state.selectedPreset, TimerPreset.classic);
      expect(state.focusAmbientTrack, FocusAmbientTrack.stream);
      expect(state.longBreakTrack, LongBreakTrack.easyGoing);
    });

    test('copyWith overrides selected fields', () {
      final state = SettingsState.initial().copyWith(
        focusDuration: 50,
        autoStartBreaks: true,
        themeMode: ThemeMode.dark,
        selectedPreset: TimerPreset.extended,
        focusAmbientTrack: FocusAmbientTrack.wind,
        longBreakTrack: LongBreakTrack.commercialA,
      );

      expect(state.focusDuration, 50);
      expect(state.shortBreakDuration, AppConstants.defaultShortBreakDuration);
      expect(state.longBreakDuration, AppConstants.defaultLongBreakDuration);
      expect(state.autoStartBreaks, isTrue);
      expect(state.autoStartPomodoros, isFalse);
      expect(state.keepScreenOn, isFalse);
      expect(state.soundEnabled, isTrue);
      expect(state.notificationsEnabled, isTrue);
      expect(state.themeMode, ThemeMode.dark);
      expect(state.selectedPreset, TimerPreset.extended);
      expect(state.focusAmbientTrack, FocusAmbientTrack.wind);
      expect(state.longBreakTrack, LongBreakTrack.commercialA);
    });
  });

  group('TimerPresetDisplay', () {
    test('label returns correct string', () {
      expect(TimerPreset.classic.label, 'Classic (25/5/15)');
      expect(TimerPreset.extended.label, 'Extended (50/10/30)');
      expect(TimerPreset.custom.label, 'Custom');
    });
  });

  group('FocusAmbientTrackDisplay', () {
    test('label and assetPath return correct values', () {
      expect(FocusAmbientTrack.stream.label, 'Stream');
      expect(
        FocusAmbientTrack.stream.assetPath,
        'assets/audio/ambience_stream_loop.ogg',
      );
    });
  });

  group('LongBreakTrackDisplay', () {
    test('label and assetPath return correct values', () {
      expect(LongBreakTrack.easyGoing.label, 'Easy Going');
      expect(
        LongBreakTrack.easyGoing.assetPath,
        'assets/audio/break_easy_going_loop.ogg',
      );
    });
  });
}
