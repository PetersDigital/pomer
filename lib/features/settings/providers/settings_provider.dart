import 'package:flutter/material.dart';
import 'package:pomer/core/constants/app_constants.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pomer/features/settings/models/settings_state.dart';

part 'settings_provider.g.dart';

@Riverpod(keepAlive: true)
class SettingsNotifier extends _$SettingsNotifier {
  final _prefs = SharedPreferencesAsync();

  // Keys
  static const String _keyFocusDuration = 'focusDuration';
  static const String _keyShortBreakDuration = 'shortBreakDuration';
  static const String _keyLongBreakDuration = 'longBreakDuration';
  static const String _keyAutoStartBreaks = 'autoStartBreaks';
  static const String _keyAutoStartPomodoros = 'autoStartPomodoros';
  static const String _keyKeepScreenOn = 'keepScreenOn';
  static const String _keyThemeMode = 'themeMode';
  static const String _keySelectedPreset = 'selectedPreset';
  static const String _keyNotificationsEnabled = 'notificationsEnabled';
  static const String _keyUseSystemNotificationSound =
      'useSystemNotificationSound';
  static const String _keyFocusAmbientTrack = 'focusAmbientTrack';
  static const String _keyLongBreakTrack = 'longBreakTrack';

  @override
  Future<SettingsState> build() async {
    return _loadSettings();
  }

  Future<SettingsState> _loadSettings() async {
    final results = await Future.wait([
      _prefs.getInt(_keyFocusDuration),
      _prefs.getInt(_keyShortBreakDuration),
      _prefs.getInt(_keyLongBreakDuration),
      _prefs.getBool(_keyAutoStartBreaks),
      _prefs.getBool(_keyAutoStartPomodoros),
      _prefs.getBool(_keyKeepScreenOn),
      _prefs.getInt(_keyThemeMode),
      _prefs.getInt(_keySelectedPreset),
      _prefs.getBool(_keyNotificationsEnabled),
      _prefs.getBool(_keyUseSystemNotificationSound),
      _prefs.getInt(_keyFocusAmbientTrack),
      _prefs.getInt(_keyLongBreakTrack),
    ]);

    var focus = results[0] as int? ?? AppConstants.defaultFocusDuration;
    var shortBreak =
        results[1] as int? ?? AppConstants.defaultShortBreakDuration;
    var longBreak = results[2] as int? ?? AppConstants.defaultLongBreakDuration;

    // Safety net: if previous bugs corrupted the DB with zeros, heal them here
    if (focus <= 0) focus = AppConstants.defaultFocusDuration;
    if (shortBreak <= 0) shortBreak = AppConstants.defaultShortBreakDuration;
    if (longBreak <= 0) longBreak = AppConstants.defaultLongBreakDuration;
    final autoStartBreaks = results[3] as bool? ?? false;
    final autoStartPomodoros = results[4] as bool? ?? false;
    final keepScreenOn = results[5] as bool? ?? false;
    final themeIndex = results[6] as int? ?? ThemeMode.system.index;
    final presetIndex = results[7] as int? ?? TimerPreset.classic.index;
    final notificationsEnabled = results[8] as bool? ?? true;
    final useSystemNotificationSound = results[9] as bool? ?? false;
    final focusAmbientTrackIndex =
        results[10] as int? ?? FocusAmbientTrack.stream.index;
    final longBreakTrackIndex =
        results[11] as int? ?? LongBreakTrack.easyGoing.index;
    final focusAmbientTrack = focusAmbientTrackIndex >= 0 &&
            focusAmbientTrackIndex < FocusAmbientTrack.values.length
        ? FocusAmbientTrack.values[focusAmbientTrackIndex]
        : FocusAmbientTrack.stream;
    final longBreakTrack = longBreakTrackIndex >= 0 &&
            longBreakTrackIndex < LongBreakTrack.values.length
        ? LongBreakTrack.values[longBreakTrackIndex]
        : LongBreakTrack.easyGoing;

    final selectedPreset =
        presetIndex >= 0 && presetIndex < TimerPreset.values.length
            ? TimerPreset.values[presetIndex]
            : TimerPreset.classic;

    return SettingsState(
      focusDuration: focus,
      shortBreakDuration: shortBreak,
      longBreakDuration: longBreak,
      autoStartBreaks: autoStartBreaks,
      autoStartPomodoros: autoStartPomodoros,
      keepScreenOn: keepScreenOn,
      notificationsEnabled: notificationsEnabled,
      useSystemNotificationSound: useSystemNotificationSound,
      themeMode: themeIndex >= 0 && themeIndex < ThemeMode.values.length
          ? ThemeMode.values[themeIndex]
          : ThemeMode.system,
      selectedPreset: selectedPreset,
      focusAmbientTrack: focusAmbientTrack,
      longBreakTrack: longBreakTrack,
    );
  }

  Future<void> updateDurations({
    required int focus,
    required int shortBreak,
    required int longBreak,
    required TimerPreset preset,
  }) async {
    await Future.wait([
      _prefs.setInt(_keyFocusDuration, focus),
      _prefs.setInt(_keyShortBreakDuration, shortBreak),
      _prefs.setInt(_keyLongBreakDuration, longBreak),
      _prefs.setInt(_keySelectedPreset, preset.index),
    ]);

    state = AsyncData(
      state.value!.copyWith(
        focusDuration: focus,
        shortBreakDuration: shortBreak,
        longBreakDuration: longBreak,
        selectedPreset: preset,
      ),
    );
  }

  Future<void> applyPreset(TimerPreset preset) async {
    switch (preset) {
      case TimerPreset.classic:
        await updateDurations(
          focus: 25,
          shortBreak: 5,
          longBreak: 15,
          preset: preset,
        );
        break;
      case TimerPreset.extended:
        await updateDurations(
          focus: 50,
          shortBreak: 10,
          longBreak: 30,
          preset: preset,
        );
        break;
      case TimerPreset.testing:
        // Do NOT overwrite user's actual saved durations with zeros.
        // TimerProvider natively respects the `testing` preset dynamically.
        // We only change the selected preset.
        await _prefs.setInt(_keySelectedPreset, preset.index);
        state = AsyncData(state.value!.copyWith(selectedPreset: preset));
        break;
      case TimerPreset.custom:
        // Do nothing for durations, just update the preset
        await _prefs.setInt(_keySelectedPreset, preset.index);
        state = AsyncData(state.value!.copyWith(selectedPreset: preset));
        break;
    }
  }

  Future<void> toggleAutoStartBreaks(bool value) async {
    await _prefs.setBool(_keyAutoStartBreaks, value);
    state = AsyncData(state.value!.copyWith(autoStartBreaks: value));
  }

  Future<void> toggleAutoStartPomodoros(bool value) async {
    await _prefs.setBool(_keyAutoStartPomodoros, value);
    state = AsyncData(state.value!.copyWith(autoStartPomodoros: value));
  }

  Future<void> toggleKeepScreenOn(bool value) async {
    await _prefs.setBool(_keyKeepScreenOn, value);
    state = AsyncData(state.value!.copyWith(keepScreenOn: value));
  }

  Future<void> toggleNotificationsEnabled(bool value) async {
    await _prefs.setBool(_keyNotificationsEnabled, value);
    state = AsyncData(state.value!.copyWith(notificationsEnabled: value));
  }

  Future<void> toggleUseSystemNotificationSound(bool value) async {
    await _prefs.setBool(_keyUseSystemNotificationSound, value);
    state = AsyncData(
      state.value!.copyWith(useSystemNotificationSound: value),
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setInt(_keyThemeMode, mode.index);
    state = AsyncData(state.value!.copyWith(themeMode: mode));
  }

  Future<void> setFocusAmbientTrack(FocusAmbientTrack track) async {
    await _prefs.setInt(_keyFocusAmbientTrack, track.index);
    state = AsyncData(state.value!.copyWith(focusAmbientTrack: track));
  }

  Future<void> setLongBreakTrack(LongBreakTrack track) async {
    await _prefs.setInt(_keyLongBreakTrack, track.index);
    state = AsyncData(state.value!.copyWith(longBreakTrack: track));
  }
}
