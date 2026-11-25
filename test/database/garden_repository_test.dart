import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomer/core/models/garden_models.dart';
import 'package:pomer/core/providers/database_provider.dart';
import 'package:pomer/core/providers/garden_repository_provider.dart';
import 'package:pomer/database/database.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('GardenRepository', () {
    late ProviderContainer container;
    late AppDatabase db;
    late GardenRepository repository;

    setUp(() {
      container = createTestContainer();
      db = container.read(appDatabaseProvider);
      repository = container.read(gardenRepositoryProvider);
    });

    tearDown(() async {
      await db.close();
      container.dispose();
    });

    test('seeds all catalog species idempotently', () async {
      final catalog = await repository.getCatalog();
      expect(catalog.length, kPlantCatalogSpecs.length);

      await db.ensurePlantCatalogSeeded();
      final catalogAfter = await repository.getCatalog();
      expect(catalogAfter.length, kPlantCatalogSpecs.length);
    });

    test('recordFocusOutcome awards quick, standard, deep, and failed plants',
        () async {
      final day = DateTime(2026, 6, 1, 10, 0);

      final quick = await repository.recordFocusOutcome(
        isCompleted: true,
        durationMinutes: 15,
        now: day,
      );
      expect(quick, isNotNull);
      expect(quick!.plant.tier, 'quick');
      expect(quick.isWithered, false);

      final standard = await repository.recordFocusOutcome(
        isCompleted: true,
        durationMinutes: 25,
        now: day,
      );
      expect(standard, isNotNull);
      expect(standard!.plant.tier, 'standard');
      expect(standard.isWithered, false);

      final deep = await repository.recordFocusOutcome(
        isCompleted: true,
        durationMinutes: 50,
        now: day,
      );
      expect(deep, isNotNull);
      expect(deep!.plant.tier, 'deep');
      expect(deep.isWithered, false);

      final failed = await repository.recordFocusOutcome(
        isCompleted: false,
        durationMinutes: 10,
        now: day,
      );
      expect(failed, isNotNull);
      expect(failed!.plant.tier, 'failed');
      expect(failed.isWithered, true);
    });

    test('watchUserGarden returns items sorted newest-first', () async {
      await db.ensurePlantCatalogSeeded();
      final sprout = await repository.getPlantCatalogItemByTier('quick');
      final tree = await repository.getPlantCatalogItemByTier('deep');
      expect(sprout, isNotNull);
      expect(tree, isNotNull);

      await repository.insertPlant(
        sprout!.id,
        10,
        earnedAt: DateTime(2026, 5, 1, 9, 0),
      );
      await repository.insertPlant(
        tree!.id,
        50,
        earnedAt: DateTime(2026, 5, 2, 9, 0),
      );

      final garden = await repository.watchUserGarden().first;
      expect(garden.length, 2);
      expect(garden.first.plantId, tree.id);
      expect(garden.last.plantId, sprout.id);
    });

    test(
        'recordFocusOutcome unlocks 3-day streak Sunflower and 5-plant Cactus milestones',
        () async {
      // Day 1 & Day 2 healthy sessions
      await repository.recordFocusOutcome(
        isCompleted: true,
        durationMinutes: 25,
        now: DateTime(2026, 6, 1, 9, 0),
      );
      await repository.recordFocusOutcome(
        isCompleted: true,
        durationMinutes: 25,
        now: DateTime(2026, 6, 2, 9, 0),
      );

      // Interrupted session should not count toward streak or healthy plants
      final withered = await repository.recordFocusOutcome(
        isCompleted: false,
        durationMinutes: 5,
        now: DateTime(2026, 6, 2, 12, 0),
      );
      expect(withered!.isWithered, true);

      // Day 3 unlocks 3-day streak Sunflower
      final day3 = await repository.recordFocusOutcome(
        isCompleted: true,
        durationMinutes: 25,
        now: DateTime(2026, 6, 3, 9, 0),
      );
      expect(day3, isNotNull);
      expect(
        day3!.newlyUnlocked.map((p) => p.tier),
        contains('milestone_streak_3'),
      );
      expect(day3.plant.tier, 'milestone_streak_3');

      // 4th healthy plant (no new milestone yet)
      final fourth = await repository.recordFocusOutcome(
        isCompleted: true,
        durationMinutes: 25,
        now: DateTime(2026, 6, 3, 11, 0),
      );
      expect(fourth!.newlyUnlocked, isEmpty);
      expect(fourth.plant.tier, 'standard');

      // 5th healthy plant unlocks Cactus
      final fifth = await repository.recordFocusOutcome(
        isCompleted: true,
        durationMinutes: 25,
        now: DateTime(2026, 6, 3, 14, 0),
      );
      expect(fifth, isNotNull);
      expect(
        fifth!.newlyUnlocked.map((p) => p.tier),
        contains('milestone_plants_5'),
      );
      expect(fifth.plant.tier, 'milestone_plants_5');
    });
  });
}
