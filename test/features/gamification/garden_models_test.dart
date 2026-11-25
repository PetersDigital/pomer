import 'package:flutter_test/flutter_test.dart';
import 'package:pomer/core/models/garden_models.dart';
import 'package:pomer/core/providers/database_provider.dart';
import 'package:pomer/core/providers/garden_repository_provider.dart';
import 'package:pomer/database/database.dart';
import 'package:pomer/features/gamification/providers/garden_provider.dart';

import '../../helpers/test_helpers.dart';

void main() {
  final catalog = <PlantCatalogItem>[
    for (var i = 0; i < kPlantCatalogSpecs.length; i++)
      PlantCatalogItem(
        id: i + 1,
        emoji: kPlantCatalogSpecs[i].emoji,
        name: kPlantCatalogSpecs[i].name,
        tier: kPlantCatalogSpecs[i].tier,
      ),
  ];

  final catalogById = <int, PlantCatalogItem>{
    for (final item in catalog) item.id: item,
  };

  int idForTier(String tier) =>
      catalog.firstWhere((item) => item.tier == tier).id;

  group('garden_models', () {
    test('empty garden produces GardenStats.empty()', () {
      final stats = computeGardenStats(
        garden: const [],
        catalogById: catalogById,
        now: DateTime(2026, 6, 10, 12),
      );

      expect(stats, const GardenStats.empty());
    });

    test('plantRuleForTier returns matching rule or null for unknown tier', () {
      final sunflower = plantRuleForTier('milestone_streak_3');
      expect(sunflower, isNotNull);
      expect(sunflower!.name, 'Sunflower');
      expect(sunflower.unlockTarget, 3);

      expect(plantRuleForTier('nonexistent_tier'), isNull);
    });

    test(
        'multiple healthy plants on the same calendar day count as 1 streak day',
        () {
      final today = DateTime(2026, 6, 10, 18);
      final garden = [
        UserGardenItem(
          id: 1,
          plantId: idForTier('quick'),
          earnedAt: DateTime(2026, 6, 10, 9, 0),
          durationMinutes: 15,
        ),
        UserGardenItem(
          id: 2,
          plantId: idForTier('standard'),
          earnedAt: DateTime(2026, 6, 10, 14, 0),
          durationMinutes: 25,
        ),
      ];

      final stats = computeGardenStats(
        garden: garden,
        catalogById: catalogById,
        now: today,
      );

      expect(stats.totalHealthyPlants, 2);
      expect(stats.totalWitheredPlants, 0);
      expect(stats.currentStreak, 1);
      expect(stats.bestStreak, 1);
    });

    test(
        'active streak continues from yesterday and resets after 2+ missed days while keeping bestStreak',
        () {
      final garden = [
        UserGardenItem(
          id: 1,
          plantId: idForTier('standard'),
          earnedAt: DateTime(2026, 6, 1, 10),
          durationMinutes: 25,
        ),
        UserGardenItem(
          id: 2,
          plantId: idForTier('standard'),
          earnedAt: DateTime(2026, 6, 2, 10),
          durationMinutes: 25,
        ),
        UserGardenItem(
          id: 3,
          plantId: idForTier('standard'),
          earnedAt: DateTime(2026, 6, 3, 10),
          durationMinutes: 25,
        ),
      ];

      final activeYesterday = computeGardenStats(
        garden: garden,
        catalogById: catalogById,
        now: DateTime(2026, 6, 4, 8),
      );
      expect(activeYesterday.currentStreak, 3);
      expect(activeYesterday.bestStreak, 3);

      final lapsedStreak = computeGardenStats(
        garden: garden,
        catalogById: catalogById,
        now: DateTime(2026, 6, 5, 8),
      );
      expect(lapsedStreak.currentStreak, 0);
      expect(lapsedStreak.bestStreak, 3);
    });

    test('withered plants increment totalWitheredPlants only', () {
      final garden = [
        UserGardenItem(
          id: 1,
          plantId: idForTier('failed'),
          earnedAt: DateTime(2026, 6, 10, 9),
          durationMinutes: 5,
        ),
        UserGardenItem(
          id: 2,
          plantId: idForTier('failed'),
          earnedAt: DateTime(2026, 6, 11, 9),
          durationMinutes: 8,
        ),
      ];

      final stats = computeGardenStats(
        garden: garden,
        catalogById: catalogById,
        now: DateTime(2026, 6, 11, 12),
      );

      expect(stats.totalHealthyPlants, 0);
      expect(stats.totalWitheredPlants, 2);
      expect(stats.currentStreak, 0);
      expect(stats.bestStreak, 0);
    });

    test(
        'buildPlantCollection excludes failed tier, clamps progress, and tracks unlocks and earned counts',
        () {
      final garden = [
        UserGardenItem(
          id: 1,
          plantId: idForTier('standard'),
          earnedAt: DateTime(2026, 6, 1, 10),
          durationMinutes: 25,
        ),
        UserGardenItem(
          id: 2,
          plantId: idForTier('standard'),
          earnedAt: DateTime(2026, 6, 2, 10),
          durationMinutes: 25,
        ),
        UserGardenItem(
          id: 3,
          plantId: idForTier('milestone_streak_3'),
          earnedAt: DateTime(2026, 6, 3, 10),
          durationMinutes: 25,
        ),
      ];

      final stats = computeGardenStats(
        garden: garden,
        catalogById: catalogById,
        now: DateTime(2026, 6, 3, 12),
      );

      final collection = buildPlantCollection(
        catalog: catalog,
        garden: garden,
        stats: stats,
      );

      expect(
        collection.any((entry) => entry.catalogItem.tier == 'failed'),
        false,
      );
      expect(collection.length, kPlantCatalogSpecs.length - 1);

      final flower = collection.firstWhere(
        (entry) => entry.catalogItem.tier == 'standard',
      );
      expect(flower.isUnlocked, true);
      expect(flower.earnedCount, 2);

      final sunflower = collection.firstWhere(
        (entry) => entry.catalogItem.tier == 'milestone_streak_3',
      );
      expect(sunflower.isUnlocked, true);
      expect(sunflower.currentProgress, 3);
      expect(sunflower.earnedCount, 1);

      final cactus = collection.firstWhere(
        (entry) => entry.catalogItem.tier == 'milestone_plants_5',
      );
      expect(cactus.isUnlocked, false);
      expect(cactus.currentProgress, 3);
      expect(cactus.earnedCount, 0);

      final pine = collection.firstWhere(
        (entry) => entry.catalogItem.tier == 'milestone_plants_30',
      );
      expect(pine.isUnlocked, false);
      expect(pine.currentProgress, 3);
    });
  });

  group('garden providers', () {
    test(
        'gardenStatsProvider and plantCollectionProvider update reactively when plants are recorded',
        () async {
      final container = createTestContainer();
      final db = container.read(appDatabaseProvider);
      final repository = container.read(gardenRepositoryProvider);
      addTearDown(() async {
        await db.close();
        container.dispose();
      });

      final gardenSub = container.listen(userGardenProvider, (_, __) {});
      final catalogSub = container.listen(plantCatalogProvider, (_, __) {});
      addTearDown(gardenSub.close);
      addTearDown(catalogSub.close);

      await container.read(plantCatalogProvider.future);
      await container.read(userGardenProvider.future);

      expect(container.read(gardenStatsProvider), const GardenStats.empty());
      expect(container.read(plantCollectionProvider), isNotEmpty);

      await repository.recordFocusOutcome(
        isCompleted: true,
        durationMinutes: 25,
        now: DateTime.now(),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final stats = container.read(gardenStatsProvider);
      expect(stats.totalHealthyPlants, 1);
      expect(stats.currentStreak, 1);
      expect(stats.bestStreak, 1);

      final collection = container.read(plantCollectionProvider);
      final flower = collection.firstWhere(
        (entry) => entry.catalogItem.tier == 'standard',
      );
      expect(flower.earnedCount, 1);
    });
  });
}
