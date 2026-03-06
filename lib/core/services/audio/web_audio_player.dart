import 'dart:async';
import 'dart:developer' as developer;
import 'dart:js_interop';

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:web/web.dart' as web;

import 'audio_player_platform.dart';

class WebAudioPlayer implements AudioPlayerPlatform {
  web.AudioContext? _audioContext;

  // Cache for decoded audio buffers
  final Map<String, web.AudioBuffer> _audioBufferCache = {};

  // State for active alarm
  web.AudioBufferSourceNode? _activeAlarmSource;
  web.GainNode? _activeAlarmGain;

  // State for active ambient
  web.AudioBufferSourceNode? _activeAmbientSource;
  web.GainNode? _activeAmbientGain;
  String? _currentAmbientPath;

  bool _isDisposed = false;

  WebAudioPlayer() {
    _initAudioContext();
  }

  void _initAudioContext() {
    try {
      // AudioContext is widely supported
      _audioContext = web.AudioContext();
    } catch (e) {
      developer.log(
        'Failed to initialize Web AudioContext',
        name: 'WebAudioPlayer',
        error: e,
      );
    }
  }

  @override
  Future<void> init() async {
    if (_audioContext == null) return;

    // Resume context if suspended
    await _ensureContextRunning();

    try {
      String manifestJson;
      try {
        manifestJson = await rootBundle.loadString('AssetManifest.bin.json');
      } catch (_) {
        manifestJson = await rootBundle.loadString('AssetManifest.json');
      }
      final Map<String, dynamic> manifestMap =
          json.decode(manifestJson) as Map<String, dynamic>;

      final oggAssets = manifestMap.keys
          .where(
            (key) => key.startsWith('assets/audio/') && key.endsWith('.ogg'),
          )
          .toList();

      final loadFutures = oggAssets.map((asset) => _loadAsset(asset));
      await Future.wait(loadFutures);
    } catch (e) {
      developer.log(
        'Failed to load asset manifest for preloading',
        name: 'WebAudioPlayer',
        error: e,
      );
    }
  }

  Future<void> _ensureContextRunning() async {
    if (_audioContext == null) return;
    if (_audioContext!.state == 'suspended') {
      try {
        await _audioContext!.resume().toDart;
      } catch (e) {
        developer.log(
          'Failed to resume AudioContext',
          name: 'WebAudioPlayer',
          error: e,
        );
      }
    }
  }

  Future<void> _loadAsset(String assetPath) async {
    if (_audioBufferCache.containsKey(assetPath)) return;
    if (_audioContext == null) return;

    try {
      final resolvedPath =
          assetPath.startsWith('assets/') ? assetPath : 'assets/$assetPath';
      final response = await web.window.fetch(resolvedPath.toJS).toDart;
      if (!response.ok) {
        throw Exception('Failed to load $resolvedPath: ${response.statusText}');
      }

      final arrayBuffer = await response.arrayBuffer().toDart;
      final audioBuffer =
          await _audioContext!.decodeAudioData(arrayBuffer).toDart;

      _audioBufferCache[assetPath] = audioBuffer;
      developer.log('Loaded and decoded $assetPath', name: 'WebAudioPlayer');
    } catch (e) {
      developer.log(
        'Error loading asset $assetPath',
        name: 'WebAudioPlayer',
        error: e,
      );
    }
  }

  @override
  Future<void> playAlarm({
    String alarmAssetPath = 'assets/audio/alarm_x1.ogg',
  }) async {
    if (_isDisposed || _audioContext == null) return;
    await _ensureContextRunning();

    await _loadAsset(alarmAssetPath);
    final buffer = _audioBufferCache[alarmAssetPath];
    if (buffer == null) return;

    // Stop current alarm if any
    await stopAlarm();

    try {
      _activeAlarmSource = _audioContext!.createBufferSource();
      _activeAlarmSource!.buffer = buffer;

      _activeAlarmGain = _audioContext!.createGain();
      _activeAlarmGain!.gain.value = 1.0;

      // Connect source -> gain -> destination
      _activeAlarmSource!.connect(_activeAlarmGain!);
      _activeAlarmGain!.connect(_audioContext!.destination);

      _activeAlarmSource!.start();
    } catch (e) {
      developer.log('Failed to play alarm', name: 'WebAudioPlayer', error: e);
    }
  }

  @override
  Future<void> stopAlarm() async {
    if (_activeAlarmSource != null) {
      try {
        _activeAlarmSource!.stop();
      } catch (_) {}
      _activeAlarmSource!.disconnect();
      _activeAlarmSource = null;
    }

    if (_activeAlarmGain != null) {
      _activeAlarmGain!.disconnect();
      _activeAlarmGain = null;
    }
  }

  @override
  Future<void> playAmbient({required String ambientAssetPath}) async {
    if (_isDisposed || _audioContext == null) return;
    await _ensureContextRunning();

    await _loadAsset(ambientAssetPath);
    final buffer = _audioBufferCache[ambientAssetPath];
    if (buffer == null) return;

    // Fast stop and clean up current ambient if any
    await _stopCurrentAmbientImmediately();

    try {
      _activeAmbientSource = _audioContext!.createBufferSource();
      _activeAmbientSource!.buffer = buffer;
      _activeAmbientSource!.loop = true;

      _activeAmbientGain = _audioContext!.createGain();

      // Start volume at 0 for fade in
      final currentTime = _audioContext!.currentTime;
      _activeAmbientGain!.gain.setValueAtTime(0.0, currentTime);
      // Fade in over 2 seconds
      _activeAmbientGain!.gain.linearRampToValueAtTime(1.0, currentTime + 2.0);

      _activeAmbientSource!.connect(_activeAmbientGain!);
      _activeAmbientGain!.connect(_audioContext!.destination);

      _activeAmbientSource!.start();
      _currentAmbientPath = ambientAssetPath;
    } catch (e) {
      developer.log('Failed to play ambient', name: 'WebAudioPlayer', error: e);
    }
  }

  Future<void> _stopCurrentAmbientImmediately() async {
    if (_activeAmbientSource != null) {
      try {
        _activeAmbientSource!.stop();
      } catch (_) {}
      _activeAmbientSource!.disconnect();
      _activeAmbientSource = null;
    }
    if (_activeAmbientGain != null) {
      _activeAmbientGain!.disconnect();
      _activeAmbientGain = null;
    }
    _currentAmbientPath = null;
  }

  @override
  Future<void> stopAmbient() async {
    if (_activeAmbientSource == null ||
        _activeAmbientGain == null ||
        _audioContext == null) {
      return;
    }

    try {
      final currentTime = _audioContext!.currentTime;
      final currentGain = _activeAmbientGain!.gain.value;

      // Cancel any scheduled changes and hold current value
      _activeAmbientGain!.gain.cancelScheduledValues(currentTime);
      _activeAmbientGain!.gain.setValueAtTime(currentGain, currentTime);

      // Fade out over 2 seconds
      _activeAmbientGain!.gain.linearRampToValueAtTime(0.0, currentTime + 2.0);

      // Stop the source exactly after the fade out is complete.
      final sourceToStop = _activeAmbientSource!;
      final gainToDisconnect = _activeAmbientGain!;
      final stopTime = currentTime + 2.0;

      try {
        sourceToStop.stop(stopTime);
      } catch (_) {}

      _activeAmbientSource = null;
      _activeAmbientGain = null;
      _currentAmbientPath = null;

      // Schedule cleanup for after the source has stopped.
      Future.delayed(const Duration(seconds: 2, milliseconds: 50), () {
        if (!_isDisposed) {
          try {
            sourceToStop.disconnect();
            gainToDisconnect.disconnect();
          } catch (_) {}
        }
      });
    } catch (e) {
      developer.log('Failed to stop ambient', name: 'WebAudioPlayer', error: e);
      await _stopCurrentAmbientImmediately();
    }
  }

  @override
  Future<void> transitionAmbient({
    required String ambientAssetPath,
    Duration transitionDuration = const Duration(seconds: 2),
  }) async {
    if (_isDisposed || _audioContext == null) return;
    await _ensureContextRunning();

    if (_currentAmbientPath == ambientAssetPath &&
        _activeAmbientSource != null) {
      return;
    }

    await _loadAsset(ambientAssetPath);
    final buffer = _audioBufferCache[ambientAssetPath];
    if (buffer == null) return;

    final oldSource = _activeAmbientSource;
    final oldGain = _activeAmbientGain;

    final currentTime = _audioContext!.currentTime;
    final halfDurationSecs = transitionDuration.inMilliseconds / 2000.0;

    // 1. Fade out old audio if it exists
    if (oldSource != null && oldGain != null) {
      final currentGainValue = oldGain.gain.value;
      oldGain.gain.cancelScheduledValues(currentTime);
      oldGain.gain.setValueAtTime(currentGainValue, currentTime);
      oldGain.gain.linearRampToValueAtTime(0.0, currentTime + halfDurationSecs);

      // Schedule old source to stop exactly when its fade-out is complete.
      final stopTime = currentTime + halfDurationSecs;
      try {
        oldSource.stop(stopTime);
      } catch (_) {}

      // Schedule cleanup for after the source has stopped.
      Future.delayed(
          Duration(milliseconds: (halfDurationSecs * 1000).toInt() + 50), () {
        if (!_isDisposed) {
          try {
            oldSource.disconnect();
            oldGain.disconnect();
          } catch (_) {}
        }
      });
    }

    // 2. Fade in new audio
    try {
      _activeAmbientSource = _audioContext!.createBufferSource();
      _activeAmbientSource!.buffer = buffer;
      _activeAmbientSource!.loop = true;

      _activeAmbientGain = _audioContext!.createGain();

      // Wait for old to fade out before fading in
      _activeAmbientGain!.gain.setValueAtTime(0.0, currentTime);
      _activeAmbientGain!.gain
          .setValueAtTime(0.0, currentTime + halfDurationSecs);
      _activeAmbientGain!.gain
          .linearRampToValueAtTime(1.0, currentTime + halfDurationSecs * 2);

      _activeAmbientSource!.connect(_activeAmbientGain!);
      _activeAmbientGain!.connect(_audioContext!.destination);

      _activeAmbientSource!.start();
      _currentAmbientPath = ambientAssetPath;
    } catch (e) {
      developer.log(
        'Failed to transition ambient',
        name: 'WebAudioPlayer',
        error: e,
      );
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _stopCurrentAmbientImmediately();
    stopAlarm();

    try {
      if (_audioContext != null && _audioContext!.state != 'closed') {
        _audioContext!.close();
      }
    } catch (_) {}

    _audioContext = null;
    _audioBufferCache.clear();
  }
}
