import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomer/core/constants/app_constants.dart';
import 'package:pomer/features/timer/models/timer_state.dart';
import 'package:pomer/features/timer/providers/timer_provider.dart';
import 'package:pomer/features/timer/screens/timer_screen.dart';
import 'package:pomer/core/services/audio_service.dart';
import 'package:pomer/core/services/notification_service.dart';
import 'package:pomer/core/services/foreground_service.dart';
import 'package:mockito/mockito.dart';

import 'package:mockito/annotations.dart';
import 'timer_test.mocks.dart';

@GenerateMocks([AudioService, NotificationService, ForegroundService])
void main() {
  group('TimerState', () {
    test('initial() has correct defaults', () {
      final s = TimerState.initial();
      expect(s.phase, TimerPhase.focus);
      expect(s.status, TimerStatus.idle);
      expect(s.totalSeconds, AppConstants.defaultFocusDuration * 60);
      expect(s.remainingSeconds, AppConstants.defaultFocusDuration * 60);
      expect(s.completedCycles, 0);
      expect(s.totalSessionsCompleted, 0);
    });

    test('copyWith overrides selected fields', () {
      final s = TimerState.initial().copyWith(
        status: TimerStatus.running,
        remainingSeconds: 100,
      );
      expect(s.status, TimerStatus.running);
      expect(s.remainingSeconds, 100);
      expect(s.phase, TimerPhase.focus);
    });
  });

  group('TimerNotifier', () {
    late ProviderContainer container;
    late MockAudioService mockAudioService;
    late MockNotificationService mockNotificationService;
    late MockForegroundService mockForegroundService;

    setUp(() {
      mockAudioService = MockAudioService();
      mockNotificationService = MockNotificationService();
      mockForegroundService = MockForegroundService();

      container = ProviderContainer(
        overrides: [
          audioServiceProvider.overrideWithValue(mockAudioService),
          notificationServiceProvider
              .overrideWithValue(mockNotificationService),
          foregroundServiceProvider.overrideWithValue(mockForegroundService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test(
        'start() changes status to running and plays ambient sound if in focus and audio enabled',
        () {
      final notifier = container.read(timerNotifierProvider.notifier);
      notifier.start();
      expect(container.read(timerNotifierProvider).status, TimerStatus.running);
      verify(mockAudioService.playAmbient(),).called(1);
    });

    test('pause() changes status to paused and stops services', () {
      final notifier = container.read(timerNotifierProvider.notifier);
      notifier.start();
      notifier.pause();
      expect(container.read(timerNotifierProvider).status, TimerStatus.paused);
      verify(mockAudioService.stopAmbient(),).called(1);
      verify(mockForegroundService.startService(any, any, isPaused: true),).called(1);
    });

    test('reset() returns to initial state and stops services', () {
      final notifier = container.read(timerNotifierProvider.notifier);
      notifier.start();
      notifier.reset();
      final state = container.read(timerNotifierProvider);
      expect(state.status, TimerStatus.idle);
      expect(state.phase, TimerPhase.focus);
      expect(
        state.remainingSeconds,
        AppConstants.defaultFocusDuration * 60,
      );
      verify(mockAudioService.stopAmbient(),).called(1);
      verify(mockForegroundService.stopService(),).called(1);
    });

    test(
        'skip() on focus advances to shortBreak when cycles < 4 and triggers notification/alarm',
        () {
      final notifier = container.read(timerNotifierProvider.notifier);
      notifier.skip();
      final state = container.read(timerNotifierProvider);
      expect(state.phase, TimerPhase.shortBreak);
      expect(state.status, TimerStatus.idle);
      expect(state.completedCycles, 1);
      verify(mockAudioService.stopAmbient(),).called(1);
      verify(mockAudioService.playAlarm(),).called(1);
      verify(mockNotificationService.showNotification(
        id: anyNamed('id'),
        title: anyNamed('title'),
        body: anyNamed('body'),
      ),).called(1);
    });

    test('skip() after 3 skips on focus advances to longBreak on 4th', () {
      final notifier = container.read(timerNotifierProvider.notifier);
      // Skip focus 3 times, alternating with short breaks.
      for (var i = 0; i < 3; i++) {
        notifier.skip(); // focus → shortBreak
        notifier.skip(); // shortBreak → focus
      }
      // Clear interactions from previous skips so we can verify the 4th skip cleanly.
      clearInteractions(mockAudioService);
      clearInteractions(mockNotificationService);

      // Now completedCycles == 3; skip focus → longBreak.
      notifier.skip();
      final state = container.read(timerNotifierProvider);
      expect(state.phase, TimerPhase.longBreak);
      expect(state.completedCycles, 4);

      verify(mockAudioService.stopAmbient(),).called(1);
      verify(mockAudioService.playAlarm(),).called(1);
      verify(mockNotificationService.showNotification(
        id: 0,
        title: 'Pomer Phase Complete',
        body: 'Your focus phase has finished.',
      ),).called(1);
    });

    test('skip() on shortBreak advances to focus', () {
      final notifier = container.read(timerNotifierProvider.notifier);
      notifier.skip(); // focus → shortBreak

      clearInteractions(mockAudioService);
      clearInteractions(mockNotificationService);

      notifier.skip(); // shortBreak → focus
      expect(container.read(timerNotifierProvider).phase, TimerPhase.focus);
      verify(mockAudioService.stopAmbient(),).called(1);
      verify(mockAudioService.playAlarm(),).called(1);
      verify(mockNotificationService.showNotification(
        id: anyNamed('id'),
        title: anyNamed('title'),
        body: anyNamed('body'),
      ),).called(1);
    });

    test('skip() on longBreak advances to focus with completedCycles reset',
        () {
      final notifier = container.read(timerNotifierProvider.notifier);
      for (var i = 0; i < 3; i++) {
        notifier.skip(); // focus → shortBreak
        notifier.skip(); // shortBreak → focus
      }
      notifier.skip(); // 4th focus → longBreak

      clearInteractions(mockAudioService);
      clearInteractions(mockNotificationService);

      notifier.skip(); // longBreak → focus
      final state = container.read(timerNotifierProvider);
      expect(state.phase, TimerPhase.focus);
      expect(state.completedCycles, 0);

      verify(mockAudioService.stopAmbient(),).called(1);
      verify(mockAudioService.playAlarm(),).called(1);
      verify(mockNotificationService.showNotification(
        id: anyNamed('id'),
        title: anyNamed('title'),
        body: anyNamed('body'),
      ),).called(1);
    });

    test('phase transition: after focus completes → shortBreak (cycles < 4)',
        () async {
      // Use a short state directly to test _onTick logic via skip (same code
      // path as _nextPhaseState).
      final notifier = container.read(timerNotifierProvider.notifier);
      notifier.skip();
      final state = container.read(timerNotifierProvider);
      expect(state.phase, TimerPhase.shortBreak);
      expect(state.totalSeconds, AppConstants.defaultShortBreakDuration * 60);
    });

    test('phase transition: after shortBreak completes → focus', () {
      final notifier = container.read(timerNotifierProvider.notifier);
      notifier.skip(); // → shortBreak
      notifier.skip(); // → focus
      expect(container.read(timerNotifierProvider).phase, TimerPhase.focus);
    });

    test('phase transition: after longBreak completes → focus', () {
      final notifier = container.read(timerNotifierProvider.notifier);
      for (var i = 0; i < 3; i++) {
        notifier.skip();
        notifier.skip();
      }
      notifier.skip(); // → longBreak
      notifier.skip(); // → focus
      expect(container.read(timerNotifierProvider).phase, TimerPhase.focus);
    });

    test('phase transition: after 4th focus → longBreak', () {
      final notifier = container.read(timerNotifierProvider.notifier);
      for (var i = 0; i < 3; i++) {
        notifier.skip();
        notifier.skip();
      }
      notifier.skip(); // 4th focus → longBreak
      expect(container.read(timerNotifierProvider).phase, TimerPhase.longBreak);
    });
  });

  group('TimerScreen widget', () {
    testWidgets('renders time display and Start button', (tester) async {
      final mockAudioService = MockAudioService();
      final mockNotificationService = MockNotificationService();
      final mockForegroundService = MockForegroundService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            audioServiceProvider.overrideWithValue(mockAudioService),
            notificationServiceProvider
                .overrideWithValue(mockNotificationService),
            foregroundServiceProvider.overrideWithValue(mockForegroundService),
          ],
          child: const MaterialApp(
            home: Scaffold(body: TimerScreen()),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('25:00'), findsOneWidget);
      expect(find.text('Start'), findsOneWidget);
    });
  });
}
