import 'dart:async';
import 'dart:developer' as developer;

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
  static const int _fadeInSteps = 16;
  static const Duration _fadeInStepDuration = Duration(milliseconds: 125);
  static const int _fadeOutSteps = 16;
  static const Duration _fadeOutStepDuration = Duration(milliseconds: 125);

  final AudioPlayer _alarmPlayer = AudioPlayer();
  final AudioPlayer _ambientPlayer = AudioPlayer();
  Future<void>? _alarmInitFuture;
  Future<void>? _ambientInitFuture;
  bool _alarmReady = false;
  bool _ambientReady = false;
  bool _audioSessionConfigured = false;
  bool _isDisposed = false;
  int _ambientOperationToken = 0;
  String? _currentAmbientAssetPath;

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
      await _setPlayerSource(_alarmPlayer, 'assets/audio/alarm_x1.ogg');
      _alarmReady = true;
    }();

    await _alarmInitFuture;
  }

  Future<void> _ensureAmbientReady({required String ambientAssetPath}) async {
    if (_ambientReady && _currentAmbientAssetPath == ambientAssetPath) {
      return;
    }

    _ambientInitFuture = () async {
      await _ambientPlayer.stop();
      await _setPlayerSource(_ambientPlayer, ambientAssetPath);
      await _ambientPlayer.setLoopMode(LoopMode.one);
      _ambientReady = true;
      _currentAmbientAssetPath = ambientAssetPath;
    }();

    await _ambientInitFuture;
    _ambientInitFuture = null;
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

  Future<void> playAmbient({required String ambientAssetPath}) async {
    try {
      await _ensureAmbientReady(ambientAssetPath: ambientAssetPath);
    } catch (error) {
      _ambientInitFuture = null;
      _ambientReady = false;
      developer.log(
        'Ambient init failed',
        name: 'AudioService',
        error: error,
      );
      return;
    }

    final token = ++_ambientOperationToken;
    await _ambientPlayer.stop();
    if (_isDisposed || token != _ambientOperationToken) {
      return;
    }

    await _ambientPlayer.seek(Duration.zero);
    await _ambientPlayer.setVolume(0.0);
    unawaited(_ambientPlayer.play());

    for (var i = 1; i <= _fadeInSteps; i++) {
      await Future<void>.delayed(_fadeInStepDuration);
      if (_isDisposed || token != _ambientOperationToken) {
        return;
      }
      await _ambientPlayer.setVolume(i / _fadeInSteps);
    }
  }

  Future<void> stopAmbient() async {
    if (!_ambientReady) {
      return;
    }

    if (!_ambientPlayer.playing) {
      return;
    }

    final token = ++_ambientOperationToken;
    final startVolume = _ambientPlayer.volume;

    for (var i = _fadeOutSteps; i >= 0; i--) {
      await Future<void>.delayed(_fadeOutStepDuration);
      if (_isDisposed || token != _ambientOperationToken) {
        return;
      }
      await _ambientPlayer.setVolume((i / _fadeOutSteps) * startVolume);
    }

    if (_isDisposed || token != _ambientOperationToken) {
      return;
    }

    await _ambientPlayer.stop();
    await _ambientPlayer.setVolume(1.0);
  }

  void dispose() {
    _isDisposed = true;
    _ambientOperationToken++;
    _alarmPlayer.dispose();
    _ambientPlayer.dispose();
  }
}
