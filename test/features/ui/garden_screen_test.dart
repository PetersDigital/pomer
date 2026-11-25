import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pomer/core/models/garden_models.dart';
import 'package:pomer/core/providers/database_provider.dart';
import 'package:pomer/core/providers/garden_repository_provider.dart';
import 'package:pomer/core/services/audio_service.dart';
import 'package:pomer/core/services/foreground_service.dart';
import 'package:pomer/core/services/notification_service.dart';
import 'package:pomer/database/database.dart';
import 'package:pomer/features/gamification/providers/garden_provider.dart';
import 'package:pomer/features/gamification/screens/garden_screen.dart';
import 'package:pomer/features/timer/screens/timer_screen.dart';

import '../../helpers/mock_services.mocks.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('GardenScreen & Reward Feedback', () {
    testWidgets('GardenScreen shows empty state and zero stats initially',
        (tester) async {
      final container = createTestContainer();
      final db = container.read(appDatabaseProvider);
      addTearDown(() async {
        await db.close();
        container.dispose();
      });

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: GardenScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('My Garden'), findsOneWidget);
      expect(find.text('0d'), findsNWidgets(2));
      expect(find.text('0'), findsOneWidget);
      expect(
        find.text('Your garden is empty. Start a focus session!'),
        findsOneWidget,
      );

      await tester.pumpAndSettle(const Duration(seconds: 1));
    });

    testWidgets(
        'GardenScreen displays grown plants, streak summary, and Collection tab',
        (tester) async {
      final container = createTestContainer();
      final db = container.read(appDatabaseProvider);
      final repository = container.read(gardenRepositoryProvider);
      addTearDown(() async {
        await db.close();
        container.dispose();
      });

      final now = DateTime.now();
      await repository.recordFocusOutcome(
        isCompleted: true,
        durationMinutes: 25,
        now: now.subtract(const Duration(days: 1)),
      );
      await repository.recordFocusOutcome(
        isCompleted: true,
        durationMinutes: 50,
        now: now,
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: GardenScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('2d'), findsNWidgets(2));
      expect(find.text('2'), findsOneWidget);
      expect(find.text('Flower'), findsOneWidget);
      expect(find.text('Tree'), findsOneWidget);

      await tester.tap(find.text('Collection'));
      await tester.pumpAndSettle();

      expect(find.text('Sunflower'), findsOneWidget);
      expect(find.text('Cactus'), findsOneWidget);
      expect(find.text('Locked'), findsWidgets);
      expect(find.text('2 / 3'), findsOneWidget);
      expect(find.text('2 / 5'), findsOneWidget);

      await tester.pumpAndSettle(const Duration(seconds: 1));
    });

    testWidgets(
        'GardenScreen handles empty plant catalog gracefully without throwing',
        (tester) async {
      final container = createTestContainer(
        overrides: [
          userGardenProvider.overrideWith(
            (ref) => Stream.value([
              UserGardenItem(
                id: 1,
                plantId: 999,
                earnedAt: DateTime(2026, 6, 1, 10),
                durationMinutes: 25,
              ),
            ]),
          ),
          plantCatalogProvider.overrideWith(
            (ref) async => const <PlantCatalogItem>[],
          ),
        ],
      );
      final db = container.read(appDatabaseProvider);
      addTearDown(() async {
        await db.close();
        container.dispose();
      });

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: GardenScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('🌱'), findsOneWidget);
      expect(find.text('Plant'), findsOneWidget);
    });

    testWidgets(
        'TimerScreen shows SnackBar feedback on plant grown, milestone unlock, and withered events',
        (tester) async {
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

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: TimerScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      const flower = PlantCatalogItem(
        id: 2,
        emoji: '🌷',
        name: 'Flower',
        tier: 'standard',
      );
      const sunflower = PlantCatalogItem(
        id: 5,
        emoji: '🌻',
        name: 'Sunflower',
        tier: 'milestone_streak_3',
      );
      const withered = PlantCatalogItem(
        id: 4,
        emoji: '🥀',
        name: 'Withered',
        tier: 'failed',
      );

      container.read(latestGardenRewardProvider.notifier).state =
          const GardenRewardEvent(
        eventId: 1,
        plant: flower,
        isWithered: false,
        newlyUnlocked: [],
      );
      await tester.pump();
      expect(find.text('🌷 Flower added to your garden!'), findsOneWidget);

      container.read(latestGardenRewardProvider.notifier).state =
          const GardenRewardEvent(
        eventId: 2,
        plant: sunflower,
        isWithered: false,
        newlyUnlocked: [sunflower],
      );
      await tester.pump();
      expect(find.text('Unlocked & grew 🌻 Sunflower!'), findsOneWidget);

      container.read(latestGardenRewardProvider.notifier).state =
          const GardenRewardEvent(
        eventId: 3,
        plant: withered,
        isWithered: true,
        newlyUnlocked: [],
      );
      await tester.pump();
      expect(
        find.text('🥀 Your plant withered. Stay focused next time!'),
        findsOneWidget,
      );

      await tester.pumpAndSettle(const Duration(seconds: 1));
    });
  });
}
