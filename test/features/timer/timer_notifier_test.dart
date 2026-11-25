import 'package:flutter_test/flutter_test.dart';
import 'package:pomer/core/providers/database_provider.dart';
import 'package:pomer/core/providers/garden_repository_provider.dart';
import 'package:pomer/core/services/audio_service.dart';
import 'package:pomer/core/services/foreground_service.dart';
import 'package:pomer/core/services/notification_service.dart';
import 'package:pomer/features/timer/models/timer_state.dart';
import 'package:pomer/features/timer/providers/timer_provider.dart';

import '../../helpers/mock_services.mocks.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('TimerNotifier State Transitions', () {
    test('Phase transitions exactly as expected: F -> SB -> F -> SB -> F -> LB',
        () async {
      final mockAudioService = MockAudioService();
      final mockNotificationService = MockNotificationService();
      final mockForegroundService = MockForegroundService();

      final container = createTestContainer(
        overrides: [
          audioServiceProvider.overrideWithValue(mockAudioService),
          notificationServiceProvider
              .overrideWithValue(mockNotificationService),
          foregroundServiceProvider.overrideWithValue(mockForegroundService),
        ],
      );

      final notifier = container.read(timerNotifierProvider.notifier);

      // Verify Initial State
      expect(container.read(timerNotifierProvider).phase, TimerPhase.focus);

      // Focus -> Short Break (Skip to fast-forward)
      notifier.skip();
      expect(
        container.read(timerNotifierProvider).phase,
        TimerPhase.shortBreak,
      );
      expect(container.read(timerNotifierProvider).completedCycles, 1);

      // Short Break -> Focus
      notifier.skip();
      expect(container.read(timerNotifierProvider).phase, TimerPhase.focus);

      // Focus -> Short Break
      notifier.skip();
      expect(
        container.read(timerNotifierProvider).phase,
        TimerPhase.shortBreak,
      );
      expect(container.read(timerNotifierProvider).completedCycles, 2);

      // Short Break -> Focus
      notifier.skip();
      expect(container.read(timerNotifierProvider).phase, TimerPhase.focus);

      // Focus -> Short Break
      notifier.skip();
      expect(
        container.read(timerNotifierProvider).phase,
        TimerPhase.shortBreak,
      );
      expect(container.read(timerNotifierProvider).completedCycles, 3);

      // Short Break -> Focus
      notifier.skip();
      expect(container.read(timerNotifierProvider).phase, TimerPhase.focus);

      // Focus -> Long Break (After 4th Focus)
      notifier.skip();
      expect(container.read(timerNotifierProvider).phase, TimerPhase.longBreak);
      expect(container.read(timerNotifierProvider).completedCycles, 4);

      container.dispose();
    });

    test('reset() correctly resets the phase without wiping completedCycles',
        () {
      final mockAudioService = MockAudioService();
      final mockNotificationService = MockNotificationService();
      final mockForegroundService = MockForegroundService();

      final container = createTestContainer(
        overrides: [
          audioServiceProvider.overrideWithValue(mockAudioService),
          notificationServiceProvider
              .overrideWithValue(mockNotificationService),
          foregroundServiceProvider.overrideWithValue(mockForegroundService),
        ],
      );

      final notifier = container.read(timerNotifierProvider.notifier);

      // Skip 3 times to get to Short Break with 1 cycle
      notifier.skip();
      expect(
        container.read(timerNotifierProvider).phase,
        TimerPhase.shortBreak,
      );
      expect(container.read(timerNotifierProvider).completedCycles, 1);

      // Reset
      notifier.reset();

      final finalState = container.read(timerNotifierProvider);
      expect(finalState.phase, TimerPhase.focus); // Reset back to focus
      expect(
        finalState.completedCycles,
        1,
      ); // Wiping completed cycles is incorrect, should retain

      container.dispose();
    });

    test(
        'resetFullSession() resets both completedCycles and totalSessionsCompleted to 0',
        () async {
      final mockAudioService = MockAudioService();
      final mockNotificationService = MockNotificationService();
      final mockForegroundService = MockForegroundService();

      final container = createTestContainer(
        overrides: [
          audioServiceProvider.overrideWithValue(mockAudioService),
          notificationServiceProvider
              .overrideWithValue(mockNotificationService),
          foregroundServiceProvider.overrideWithValue(mockForegroundService),
        ],
      );
      final db = container.read(appDatabaseProvider);
      addTearDown(() async {
        await db.close();
        container.dispose();
      });

      final notifier = container.read(timerNotifierProvider.notifier);
      notifier.skip(); // focus -> shortBreak
      expect(container.read(timerNotifierProvider).completedCycles, 1);
      expect(container.read(timerNotifierProvider).totalSessionsCompleted, 1);

      notifier.resetFullSession();

      final state = container.read(timerNotifierProvider);
      expect(state.phase, TimerPhase.focus);
      expect(state.status, TimerStatus.idle);
      expect(state.completedCycles, 0);
      expect(state.totalSessionsCompleted, 0);
    });
  });

  group('TimerNotifier Gamification Integration', () {
    test(
        'focus session interruption after 1s logs withered plant and emits latestGardenRewardProvider',
        () async {
      final mockAudioService = MockAudioService();
      final mockNotificationService = MockNotificationService();
      final mockForegroundService = MockForegroundService();

      final container = createTestContainer(
        overrides: [
          audioServiceProvider.overrideWithValue(mockAudioService),
          notificationServiceProvider
              .overrideWithValue(mockNotificationService),
          foregroundServiceProvider.overrideWithValue(mockForegroundService),
        ],
      );
      final db = container.read(appDatabaseProvider);
      final repository = container.read(gardenRepositoryProvider);
      addTearDown(() async {
        await db.close();
        container.dispose();
      });

      final notifier = container.read(timerNotifierProvider.notifier);
      notifier.start();
      await Future<void>.delayed(const Duration(milliseconds: 1150));

      notifier.reset();
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final garden = await repository.getUserGarden();
      expect(garden.length, 1);

      final reward = container.read(latestGardenRewardProvider);
      expect(reward, isNotNull);
      expect(reward!.isWithered, true);
      expect(reward.plant.tier, 'failed');
    });

    test('break session interruption does not record a garden plant', () async {
      final mockAudioService = MockAudioService();
      final mockNotificationService = MockNotificationService();
      final mockForegroundService = MockForegroundService();

      final container = createTestContainer(
        overrides: [
          audioServiceProvider.overrideWithValue(mockAudioService),
          notificationServiceProvider
              .overrideWithValue(mockNotificationService),
          foregroundServiceProvider.overrideWithValue(mockForegroundService),
        ],
      );
      final db = container.read(appDatabaseProvider);
      final repository = container.read(gardenRepositoryProvider);
      addTearDown(() async {
        await db.close();
        container.dispose();
      });

      final notifier = container.read(timerNotifierProvider.notifier);
      notifier.skip(); // Move to shortBreak
      expect(
        container.read(timerNotifierProvider).phase,
        TimerPhase.shortBreak,
      );

      notifier.start();
      await Future<void>.delayed(const Duration(milliseconds: 1150));

      notifier.reset();
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final garden = await repository.getUserGarden();
      expect(garden, isEmpty);
      expect(container.read(latestGardenRewardProvider), isNull);
    });
  });
}
