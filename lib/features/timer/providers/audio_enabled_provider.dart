import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pomer/features/settings/providers/settings_provider.dart';

part 'audio_enabled_provider.g.dart';

@riverpod
class AudioEnabledNotifier extends _$AudioEnabledNotifier {
  @override
  bool build() {
    // Watch settings to use global "soundEnabled" as a base
    final settingsAsync = ref.watch(settingsNotifierProvider);
    return settingsAsync.valueOrNull?.soundEnabled ?? true;
  }

  void toggle() {
    final settingsNotifier = ref.read(settingsNotifierProvider.notifier);
    settingsNotifier.toggleSoundEnabled(!state);
  }
}
