import 'package:flutter_test/flutter_test.dart';
import 'package:pomer/core/services/audio_service.dart';
import 'package:pomer/core/services/foreground_service.dart';
import 'package:pomer/core/services/notification_service.dart';
import 'package:pomer/features/timer/models/timer_state.dart';
import 'package:pomer/features/timer/providers/timer_provider.dart';

import '../../helpers/test_helpers.dart';
import '../../helpers/mock_services.mocks.dart';

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
          container.read(timerNotifierProvider).phase, TimerPhase.shortBreak,);
      expect(container.read(timerNotifierProvider).completedCycles, 1);

      // Short Break -> Focus
      notifier.skip();
      expect(container.read(timerNotifierProvider).phase, TimerPhase.focus);

      // Focus -> Short Break
      notifier.skip();
      expect(
          container.read(timerNotifierProvider).phase, TimerPhase.shortBreak,);
      expect(container.read(timerNotifierProvider).completedCycles, 2);

      // Short Break -> Focus
      notifier.skip();
      expect(container.read(timerNotifierProvider).phase, TimerPhase.focus);

      // Focus -> Short Break
      notifier.skip();
      expect(
          container.read(timerNotifierProvider).phase, TimerPhase.shortBreak,);
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
          container.read(timerNotifierProvider).phase, TimerPhase.shortBreak,);
      expect(container.read(timerNotifierProvider).completedCycles, 1);

      // Reset
      notifier.reset();

      final finalState = container.read(timerNotifierProvider);
      expect(finalState.phase, TimerPhase.focus); // Reset back to focus
      expect(finalState.completedCycles,
          1,); // Wiping completed cycles is incorrect, should retain

      container.dispose();
    });
  });
}
