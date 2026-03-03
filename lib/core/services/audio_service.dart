import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'audio/audio_player_platform.dart';
import 'audio/audio_player_factory.dart';

part 'audio_service.g.dart';

@Riverpod(keepAlive: true)
AudioService audioService(Ref ref) {
  final service = AudioService();
  ref.onDispose(service.dispose);
  return service;
}

class AudioService {
  final AudioPlayerPlatform _player;

  AudioService() : _player = getAudioPlayer() {
    // Fire and forget init, which handles pre-loading assets and setting up context
    _player.init();
  }

  Future<void> playAlarm({
    String alarmAssetPath = 'assets/audio/alarm_x1.ogg',
  }) async {
    await _player.playAlarm(alarmAssetPath: alarmAssetPath);
  }

  Future<void> stopAlarm() async {
    await _player.stopAlarm();
  }

  Future<void> playAmbient({required String ambientAssetPath}) async {
    await _player.playAmbient(ambientAssetPath: ambientAssetPath);
  }

  Future<void> stopAmbient() async {
    await _player.stopAmbient();
  }

  Future<void> transitionAmbient({
    required String ambientAssetPath,
    Duration transitionDuration = const Duration(seconds: 2),
  }) async {
    await _player.transitionAmbient(
      ambientAssetPath: ambientAssetPath,
      transitionDuration: transitionDuration,
    );
  }

  void dispose() {
    _player.dispose();
  }
}
