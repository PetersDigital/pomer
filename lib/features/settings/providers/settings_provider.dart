import 'package:flutter/material.dart';
import 'package:pomer/core/constants/app_constants.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pomer/features/settings/models/settings_state.dart';

part 'settings_provider.g.dart';

@Riverpod(keepAlive: true)
class SettingsNotifier extends _$SettingsNotifier {
  final _prefs = SharedPreferencesAsync();

  @override
  Future<SettingsState> build() async {
    return _loadSettings();
  }

  Future<SettingsState> _loadSettings() async {
    final focus = await _prefs.getInt('focusDuration') ?? AppConstants.defaultFocusDuration;
    final shortBreak = await _prefs.getInt('shortBreakDuration') ?? AppConstants.defaultShortBreakDuration;
    final longBreak = await _prefs.getInt('longBreakDuration') ?? AppConstants.defaultLongBreakDuration;
    final autoStartBreaks = await _prefs.getBool('autoStartBreaks') ?? false;
    final autoStartPomodoros = await _prefs.getBool('autoStartPomodoros') ?? false;
    final keepScreenOn = await _prefs.getBool('keepScreenOn') ?? false;
    final themeIndex = await _prefs.getInt('themeMode') ?? ThemeMode.system.index;
    final presetIndex = await _prefs.getInt('selectedPreset') ?? TimerPreset.classic.index;

    return SettingsState(
      focusDuration: focus,
      shortBreakDuration: shortBreak,
      longBreakDuration: longBreak,
      autoStartBreaks: autoStartBreaks,
      autoStartPomodoros: autoStartPomodoros,
      keepScreenOn: keepScreenOn,
      themeMode: ThemeMode.values[themeIndex],
      selectedPreset: TimerPreset.values[presetIndex],
    );
  }

  Future<void> updateDurations({
    required int focus,
    required int shortBreak,
    required int longBreak,
    required TimerPreset preset,
  }) async {
    await _prefs.setInt('focusDuration', focus);
    await _prefs.setInt('shortBreakDuration', shortBreak);
    await _prefs.setInt('longBreakDuration', longBreak);
    await _prefs.setInt('selectedPreset', preset.index);

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
        await updateDurations(focus: 25, shortBreak: 5, longBreak: 15, preset: preset);
        break;
      case TimerPreset.extended:
        await updateDurations(focus: 50, shortBreak: 10, longBreak: 30, preset: preset);
        break;
      case TimerPreset.custom:
        // Do nothing for durations, just update the preset
        await _prefs.setInt('selectedPreset', preset.index);
        state = AsyncData(state.value!.copyWith(selectedPreset: preset));
        break;
    }
  }

  Future<void> toggleAutoStartBreaks(bool value) async {
    await _prefs.setBool('autoStartBreaks', value);
    state = AsyncData(state.value!.copyWith(autoStartBreaks: value));
  }

  Future<void> toggleAutoStartPomodoros(bool value) async {
    await _prefs.setBool('autoStartPomodoros', value);
    state = AsyncData(state.value!.copyWith(autoStartPomodoros: value));
  }

  Future<void> toggleKeepScreenOn(bool value) async {
    await _prefs.setBool('keepScreenOn', value);
    state = AsyncData(state.value!.copyWith(keepScreenOn: value));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setInt('themeMode', mode.index);
    state = AsyncData(state.value!.copyWith(themeMode: mode));
  }
}
