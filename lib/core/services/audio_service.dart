import 'package:just_audio/just_audio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:audio_session/audio_session.dart';

part 'audio_service.g.dart';

@Riverpod(keepAlive: true)
AudioService audioService(Ref ref) {
  final service = AudioService();
  ref.onDispose(service.dispose);
  return service;
}

class AudioService {
  final AudioPlayer _alarmPlayer = AudioPlayer();
  final AudioPlayer _ambientPlayer = AudioPlayer();
  late final Future<void> _initFuture;

  AudioService() {
    _initFuture = _init();
  }

  Future<void> _init() async {
    // Configure audio session for background playback on Android/iOS
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    await _alarmPlayer.setAsset('assets/audio/alarm_x1.mp3');
    await _ambientPlayer.setAsset('assets/audio/ambience_calm_river_loop.mp3');
    await _ambientPlayer.setLoopMode(LoopMode.one); // LoopMode.one for single file smooth looping
  }

  Future<void> playAlarm() async {
    await _initFuture;
    await _alarmPlayer.setVolume(1.0);
    await _alarmPlayer.seek(Duration.zero);
    await _alarmPlayer.play();
  }

  Future<void> stopAlarm() async {
    await _initFuture;
    await _alarmPlayer.stop();
  }

  Future<void> playAmbient() async {
    await _initFuture;
    // Fade in
    await _ambientPlayer.setVolume(0.0);
    _ambientPlayer.play();
    for (int i = 1; i <= 10; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await _ambientPlayer.setVolume(i / 10.0);
    }
  }

  Future<void> stopAmbient() async {
    await _initFuture;
    // Fade out
    final startVolume = _ambientPlayer.volume;
    for (int i = 10; i >= 0; i--) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await _ambientPlayer.setVolume((i / 10.0) * startVolume);
    }
    await _ambientPlayer.stop();
  }

  void dispose() {
    _alarmPlayer.dispose();
    _ambientPlayer.dispose();
  }
}
