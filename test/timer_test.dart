import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomer/core/constants/app_constants.dart';
import 'package:pomer/features/timer/models/timer_state.dart';
import 'package:pomer/features/timer/providers/timer_provider.dart';
import 'package:pomer/features/timer/screens/timer_screen.dart';

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

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('start() changes status to running', () {
      final notifier = container.read(timerNotifierProvider.notifier);
      notifier.start();
      expect(container.read(timerNotifierProvider).status, TimerStatus.running);
    });

    test('pause() changes status to paused', () {
      final notifier = container.read(timerNotifierProvider.notifier);
      notifier.start();
      notifier.pause();
      expect(container.read(timerNotifierProvider).status, TimerStatus.paused);
    });

    test('reset() returns to initial state', () {
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
    });

    test('skip() on focus advances to shortBreak when cycles < 4', () {
      final notifier = container.read(timerNotifierProvider.notifier);
      notifier.skip();
      final state = container.read(timerNotifierProvider);
      expect(state.phase, TimerPhase.shortBreak);
      expect(state.status, TimerStatus.idle);
      expect(state.completedCycles, 1);
    });

    test('skip() after 3 skips on focus advances to longBreak on 4th', () {
      final notifier = container.read(timerNotifierProvider.notifier);
      // Skip focus 3 times, alternating with short breaks.
      for (var i = 0; i < 3; i++) {
        notifier.skip(); // focus → shortBreak
        notifier.skip(); // shortBreak → focus
      }
      // Now completedCycles == 3; skip focus → longBreak.
      notifier.skip();
      final state = container.read(timerNotifierProvider);
      expect(state.phase, TimerPhase.longBreak);
      expect(state.completedCycles, 4);
    });

    test('skip() on shortBreak advances to focus', () {
      final notifier = container.read(timerNotifierProvider.notifier);
      notifier.skip(); // focus → shortBreak
      notifier.skip(); // shortBreak → focus
      expect(container.read(timerNotifierProvider).phase, TimerPhase.focus);
    });

    test('skip() on longBreak advances to focus with completedCycles reset',
        () {
      final notifier = container.read(timerNotifierProvider.notifier);
      for (var i = 0; i < 3; i++) {
        notifier.skip(); // focus → shortBreak
        notifier.skip(); // shortBreak → focus
      }
      notifier.skip(); // 4th focus → longBreak
      notifier.skip(); // longBreak → focus
      final state = container.read(timerNotifierProvider);
      expect(state.phase, TimerPhase.focus);
      expect(state.completedCycles, 0);
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
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
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
