import 'dart:async';
import 'dart:developer' as developer;

import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:pomer/core/utils/platform_utils.dart';

import 'audio_player_platform.dart';

class NativeAudioPlayer implements AudioPlayerPlatform {
  static const Set<String> _deprecatedAudioExtensions = {'.mp3'};
  static const int _fadeInSteps = 16;
  static const Duration _fadeInStepDuration = Duration(milliseconds: 125);
  static const int _fadeOutSteps = 16;
  static const Duration _fadeOutStepDuration = Duration(milliseconds: 125);
  static const Duration _defaultTransitionDuration = Duration(seconds: 2);

  final AudioPlayer _alarmPlayer = AudioPlayer();
  final AudioPlayer _ambientPlayer = AudioPlayer();

  Future<void>? _alarmInitFuture;
  Future<void>? _ambientInitFuture;
  bool _alarmReady = false;
  bool _ambientReady = false;

  bool _audioSessionConfigured = false;
  Future<void>? _audioSessionInitFuture;

  bool _isDisposed = false;
  int _ambientOperationToken = 0;

  String? _currentAlarmAssetPath;
  String? _currentAmbientAssetPath;
  Future<void>? _ambientFadeOutFuture;

  NativeAudioPlayer() {
    _audioSessionInitFuture = _configureAudioSession();
  }

  @override
  Future<void> init() async {
    await _ensureAudioSessionConfigured();
  }

  Future<void> _configureAudioSession() async {
    if (_audioSessionConfigured) {
      return;
    }

    if (PlatformUtils.isMobile) {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
    }

    _audioSessionConfigured = true;
  }

  Future<void> _ensureAudioSessionConfigured() async {
    final initFuture = _audioSessionInitFuture ??= _configureAudioSession();
    try {
      await initFuture;
    } catch (error) {
      _audioSessionInitFuture = null;
      _audioSessionConfigured = false;
      developer.log(
        'Audio session configuration failed',
        name: 'NativeAudioPlayer',
        error: error,
      );
    }
  }

  Future<void> _ensureAudioSessionActive() async {
    if (!PlatformUtils.isMobile) {
      return;
    }

    try {
      final session = await AudioSession.instance;
      await session.setActive(true);
    } catch (_) {
      // Keep playback flow resilient if session activation is unsupported.
    }
  }

  Future<void> _ensureAlarmReady({required String alarmAssetPath}) async {
    if (_alarmReady && _currentAlarmAssetPath == alarmAssetPath) {
      return;
    }

    _alarmInitFuture = () async {
      await _alarmPlayer.stop();
      await _setPlayerSource(_alarmPlayer, alarmAssetPath);
      _alarmReady = true;
      _currentAlarmAssetPath = alarmAssetPath;
    }();

    await _alarmInitFuture;
    _alarmInitFuture = null;
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
    _ensureSupportedAudioAsset(assetPath);
    await player.setAsset(assetPath);
  }

  void _ensureSupportedAudioAsset(String assetPath) {
    final lowerCasePath = assetPath.toLowerCase();
    for (final extension in _deprecatedAudioExtensions) {
      if (lowerCasePath.endsWith(extension)) {
        developer.log(
          'Deprecated audio format requested: $assetPath',
          name: 'NativeAudioPlayer',
        );
        throw UnsupportedError(
          'MP3 assets are deprecated. Use OGG assets instead.',
        );
      }
    }
  }

  @override
  Future<void> playAlarm({
    String alarmAssetPath = 'assets/audio/alarm_x1.ogg',
  }) async {
    try {
      await _ensureAudioSessionConfigured();
      await _ensureAlarmReady(alarmAssetPath: alarmAssetPath);
      await _ensureAudioSessionActive();
      await _alarmPlayer.setVolume(1.0);
      await _alarmPlayer.seek(Duration.zero);
      await _alarmPlayer.play();
    } catch (error) {
      _alarmInitFuture = null;
      _alarmReady = false;
      developer.log(
        'Alarm playback failed',
        name: 'NativeAudioPlayer',
        error: error,
      );
    }
  }

  @override
  Future<void> stopAlarm() async {
    if (!_alarmReady) {
      return;
    }

    await _alarmPlayer.stop();
  }

  @override
  Future<void> playAmbient({required String ambientAssetPath}) async {
    final pendingFadeOut = _ambientFadeOutFuture;
    if (pendingFadeOut != null) {
      await pendingFadeOut;
    }

    try {
      await _ensureAudioSessionConfigured();
      await _ensureAmbientReady(ambientAssetPath: ambientAssetPath);
    } catch (error) {
      _ambientInitFuture = null;
      _ambientReady = false;
      developer.log(
        'Ambient init failed',
        name: 'NativeAudioPlayer',
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
    await _ensureAudioSessionActive();
    unawaited(_ambientPlayer.play());

    for (var i = 1; i <= _fadeInSteps; i++) {
      await Future<void>.delayed(_fadeInStepDuration);
      if (_isDisposed || token != _ambientOperationToken) {
        return;
      }
      final progress = i / _fadeInSteps;
      final easedProgress = _easeInOut(progress);
      await _ambientPlayer.setVolume(easedProgress);
    }
  }

  @override
  Future<void> stopAmbient() async {
    if (!_ambientReady) {
      return;
    }

    final pendingFadeOut = _ambientFadeOutFuture;
    if (pendingFadeOut != null) {
      await pendingFadeOut;
      return;
    }

    final fadeOutCompleter = Completer<void>();
    _ambientFadeOutFuture = fadeOutCompleter.future;

    try {
      final token = ++_ambientOperationToken;
      final startVolume = _ambientPlayer.volume;

      if (startVolume <= 0.0) {
        await _ambientPlayer.stop();
        await _ambientPlayer.setVolume(1.0);
        return;
      }

      for (var i = 1; i <= _fadeOutSteps; i++) {
        await Future<void>.delayed(_fadeOutStepDuration);
        if (_isDisposed || token != _ambientOperationToken) {
          return;
        }
        final progress = i / _fadeOutSteps;
        final easedProgress = _easeInOut(progress);
        final fadeFactor = 1.0 - easedProgress;
        await _ambientPlayer.setVolume(fadeFactor * startVolume);
      }

      if (_isDisposed || token != _ambientOperationToken) {
        return;
      }

      await _ambientPlayer.stop();
      await _ambientPlayer.setVolume(1.0);
    } finally {
      _ambientFadeOutFuture = null;
      if (!fadeOutCompleter.isCompleted) {
        fadeOutCompleter.complete();
      }
    }
  }

  @override
  Future<void> transitionAmbient({
    required String ambientAssetPath,
    Duration transitionDuration = _defaultTransitionDuration,
  }) async {
    await _ensureAudioSessionConfigured();

    if (_currentAmbientAssetPath == ambientAssetPath && _ambientReady) {
      return;
    }

    final pendingFadeOut = _ambientFadeOutFuture;
    if (pendingFadeOut != null) {
      await pendingFadeOut;
    }

    if (!_ambientReady) {
      await playAmbient(ambientAssetPath: ambientAssetPath);
      return;
    }

    final token = ++_ambientOperationToken;
    final startVolume =
        _ambientPlayer.volume <= 0.0 ? 1.0 : _ambientPlayer.volume;
    final halfOutDuration = Duration(
      milliseconds: transitionDuration.inMilliseconds ~/ 2,
    );
    final halfInDuration = Duration(
      milliseconds:
          transitionDuration.inMilliseconds - halfOutDuration.inMilliseconds,
    );
    final halfOutSteps = _stepsForDuration(
      duration: halfOutDuration,
      stepDuration: _fadeOutStepDuration,
    );
    final halfInSteps = _stepsForDuration(
      duration: halfInDuration,
      stepDuration: _fadeInStepDuration,
    );

    for (var i = 1; i <= halfOutSteps; i++) {
      await Future<void>.delayed(_fadeOutStepDuration);
      if (_isDisposed || token != _ambientOperationToken) {
        return;
      }
      final progress = i / halfOutSteps;
      final easedProgress = _easeInOut(progress);
      await _ambientPlayer.setVolume((1.0 - easedProgress) * startVolume);
    }

    if (_isDisposed || token != _ambientOperationToken) {
      return;
    }

    try {
      await _ambientPlayer.stop();
      await _setPlayerSource(_ambientPlayer, ambientAssetPath);
      await _ambientPlayer.setLoopMode(LoopMode.one);
      _ambientReady = true;
      _currentAmbientAssetPath = ambientAssetPath;
      await _ambientPlayer.seek(Duration.zero);
      await _ambientPlayer.setVolume(0.0);
      await _ensureAudioSessionActive();
      unawaited(_ambientPlayer.play());
    } catch (error) {
      _ambientReady = false;
      _ambientInitFuture = null;
      developer.log(
        'Ambient transition failed',
        name: 'NativeAudioPlayer',
        error: error,
      );
      return;
    }

    for (var i = 1; i <= halfInSteps; i++) {
      await Future<void>.delayed(_fadeInStepDuration);
      if (_isDisposed || token != _ambientOperationToken) {
        return;
      }
      final progress = i / halfInSteps;
      final easedProgress = _easeInOut(progress);
      await _ambientPlayer.setVolume(easedProgress);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _ambientOperationToken++;
    _alarmPlayer.dispose();
    _ambientPlayer.dispose();
  }

  double _easeInOut(double t) {
    return t * t * (3 - 2 * t);
  }

  int _stepsForDuration({
    required Duration duration,
    required Duration stepDuration,
  }) {
    final durationMs = duration.inMilliseconds;
    final stepMs = stepDuration.inMilliseconds;
    if (durationMs <= 0 || stepMs <= 0) {
      return 1;
    }
    final steps = durationMs ~/ stepMs;
    return steps <= 0 ? 1 : steps;
  }
}
