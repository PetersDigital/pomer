abstract class AudioPlayerPlatform {
  /// Initializes the audio player resources if necessary.
  Future<void> init();

  /// Plays the alarm audio file at the specified asset path.
  Future<void> playAlarm({String alarmAssetPath = 'assets/audio/alarm_x1.ogg'});

  /// Stops the currently playing alarm audio.
  Future<void> stopAlarm();

  /// Plays the ambient audio file at the specified asset path, applying a fade-in effect.
  Future<void> playAmbient({required String ambientAssetPath});

  /// Stops the currently playing ambient audio, applying a fade-out effect.
  Future<void> stopAmbient();

  /// Transitions smoothly between the current ambient audio and a new one.
  /// Crossfades over the given [transitionDuration].
  Future<void> transitionAmbient({
    required String ambientAssetPath,
    Duration transitionDuration = const Duration(seconds: 2),
  });

  /// Cleans up any resources held by the audio player.
  void dispose();
}
