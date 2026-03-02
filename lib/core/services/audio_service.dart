import 'package:just_audio/just_audio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:audio_session/audio_session.dart';
import 'package:pomer/core/utils/platform_utils.dart';

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
  Future<void>? _alarmInitFuture;
  Future<void>? _ambientInitFuture;
  bool _alarmReady = false;
  bool _ambientReady = false;
  bool _audioSessionConfigured = false;

  AudioService() {
    _configureAudioSession();
  }

  Future<void> _configureAudioSession() async {
    if (_audioSessionConfigured) {
      return;
    }

    _audioSessionConfigured = true;

    if (PlatformUtils.isMobile) {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
    }
  }

  Future<void> _ensureAlarmReady() async {
    if (_alarmReady) {
      return;
    }

    _alarmInitFuture ??= () async {
      await _setPlayerSource(_alarmPlayer, 'assets/audio/alarm_x1.mp3');
      _alarmReady = true;
    }();

    await _alarmInitFuture;
  }

  Future<void> _ensureAmbientReady() async {
    if (_ambientReady) {
      return;
    }

    _ambientInitFuture ??= () async {
      await _setPlayerSource(
        _ambientPlayer,
        'assets/audio/ambience_calm_river_loop.mp3',
      );
      await _ambientPlayer.setLoopMode(LoopMode.one);
      _ambientReady = true;
    }();

    await _ambientInitFuture;
  }

  Future<void> _setPlayerSource(AudioPlayer player, String assetPath) async {
    if (!PlatformUtils.isWeb) {
      await player.setAsset(assetPath);
      return;
    }

    final trimmedAssetPath = assetPath.startsWith('assets/')
        ? assetPath.substring('assets/'.length)
        : assetPath;

    final candidates = <String>{
      'assets/$assetPath',
      assetPath,
      trimmedAssetPath,
    };

    Object? lastError;
    for (final candidate in candidates) {
      final sourceUrl = Uri.base.resolve(candidate).toString();
      try {
        await player.setUrl(sourceUrl);
        return;
      } catch (error) {
        lastError = error;
      }
    }

    if (lastError != null) {
      throw lastError;
    }
  }

  Future<void> playAlarm() async {
    try {
      await _ensureAlarmReady();
      await _alarmPlayer.setVolume(1.0);
      await _alarmPlayer.seek(Duration.zero);
      await _alarmPlayer.play();
    } catch (_) {
      _alarmInitFuture = null;
      _alarmReady = false;
    }
  }

  Future<void> stopAlarm() async {
    if (!_alarmReady) {
      return;
    }

    await _alarmPlayer.stop();
  }

  Future<void> playAmbient() async {
    try {
      await _ensureAmbientReady();
    } catch (_) {
      _ambientInitFuture = null;
      _ambientReady = false;
      return;
    }

    if (_ambientPlayer.playing) {
      return;
    }

    // Fade in
    await _ambientPlayer.setVolume(0.0);
    await _ambientPlayer.play();
    for (int i = 1; i <= 10; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await _ambientPlayer.setVolume(i / 10.0);
    }
  }

  Future<void> stopAmbient() async {
    if (!_ambientReady) {
      return;
    }

    if (!_ambientPlayer.playing) {
      return;
    }

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
