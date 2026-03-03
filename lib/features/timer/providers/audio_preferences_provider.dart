import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'audio_preferences_provider.g.dart';

class AudioPreferences {
  final bool focusAudioEnabled;
  final bool breakAudioEnabled;
  final bool alarmAudioEnabled;

  const AudioPreferences({
    this.focusAudioEnabled = true,
    this.breakAudioEnabled = true,
    this.alarmAudioEnabled = true,
  });

  AudioPreferences copyWith({
    bool? focusAudioEnabled,
    bool? breakAudioEnabled,
    bool? alarmAudioEnabled,
  }) {
    return AudioPreferences(
      focusAudioEnabled: focusAudioEnabled ?? this.focusAudioEnabled,
      breakAudioEnabled: breakAudioEnabled ?? this.breakAudioEnabled,
      alarmAudioEnabled: alarmAudioEnabled ?? this.alarmAudioEnabled,
    );
  }
}

@Riverpod(keepAlive: true)
class AudioPreferencesNotifier extends _$AudioPreferencesNotifier {
  static const String _focusAudioKey = 'pomer_focus_audio_enabled';
  static const String _breakAudioKey = 'pomer_break_audio_enabled';
  static const String _alarmAudioKey = 'pomer_alarm_audio_enabled';

  @override
  FutureOr<AudioPreferences> build() async {
    final prefs = SharedPreferencesAsync();
    final focusEnabled = await prefs.getBool(_focusAudioKey) ?? true;
    final breakEnabled = await prefs.getBool(_breakAudioKey) ?? true;
    final alarmEnabled = await prefs.getBool(_alarmAudioKey) ?? true;

    return AudioPreferences(
      focusAudioEnabled: focusEnabled,
      breakAudioEnabled: breakEnabled,
      alarmAudioEnabled: alarmEnabled,
    );
  }

  Future<void> toggleFocusAudio() async {
    final current = state.valueOrNull;
    if (current == null) return;

    final newValue = !current.focusAudioEnabled;
    final prefs = SharedPreferencesAsync();
    await prefs.setBool(_focusAudioKey, newValue);

    state = AsyncValue.data(current.copyWith(focusAudioEnabled: newValue));
  }

  Future<void> toggleBreakAudio() async {
    final current = state.valueOrNull;
    if (current == null) return;

    final newValue = !current.breakAudioEnabled;
    final prefs = SharedPreferencesAsync();
    await prefs.setBool(_breakAudioKey, newValue);

    state = AsyncValue.data(current.copyWith(breakAudioEnabled: newValue));
  }

  Future<void> toggleAlarmAudio() async {
    final current = state.valueOrNull;
    if (current == null) return;

    final newValue = !current.alarmAudioEnabled;
    final prefs = SharedPreferencesAsync();
    await prefs.setBool(_alarmAudioKey, newValue);

    state = AsyncValue.data(current.copyWith(alarmAudioEnabled: newValue));
  }
}
