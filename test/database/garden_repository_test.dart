import 'package:drift/native.dart';
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

    test('upgrades schema v2 database to v3 and seeds plant catalog', () async {
      final nativeDb = NativeDatabase.memory(
        setup: (rawDb) {
          rawDb.execute('''
            CREATE TABLE sessions (
              id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
              start_time INTEGER NOT NULL,
              end_time INTEGER NOT NULL,
              duration_seconds INTEGER NOT NULL,
              phase_type TEXT NOT NULL,
              status TEXT NOT NULL,
              task_id TEXT NULL
            );
          ''');
          rawDb.execute('''
            CREATE TABLE tasks (
              id TEXT NOT NULL PRIMARY KEY,
              title TEXT NOT NULL,
              tag TEXT NULL,
              is_completed INTEGER NOT NULL DEFAULT 0,
              created_at INTEGER NOT NULL
            );
          ''');
          rawDb.execute('PRAGMA user_version = 2;');
        },
      );

      final migratedDb = AppDatabase.forTesting(nativeDb);
      addTearDown(migratedDb.close);
      final migratedRepo = GardenRepository(migratedDb);

      final catalog = await migratedRepo.getCatalog();
      expect(catalog.length, kPlantCatalogSpecs.length);

      final reward = await migratedRepo.recordFocusOutcome(
        isCompleted: true,
        durationMinutes: 25,
        now: DateTime(2026, 6, 10, 9),
      );
      expect(reward, isNotNull);
      expect(reward!.plant.tier, 'standard');
    });

    test(
        'backfills milestone species for existing v3 database with only 4 starter rows',
        () async {
      final nativeDb = NativeDatabase.memory(
        setup: (rawDb) {
          rawDb.execute('''
            CREATE TABLE sessions (
              id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
              start_time INTEGER NOT NULL,
              end_time INTEGER NOT NULL,
              duration_seconds INTEGER NOT NULL,
              phase_type TEXT NOT NULL,
              status TEXT NOT NULL,
              task_id TEXT NULL
            );
          ''');
          rawDb.execute('''
            CREATE TABLE tasks (
              id TEXT NOT NULL PRIMARY KEY,
              title TEXT NOT NULL,
              tag TEXT NULL,
              is_completed INTEGER NOT NULL DEFAULT 0,
              created_at INTEGER NOT NULL
            );
          ''');
          rawDb.execute('''
            CREATE TABLE plant_catalog (
              id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
              emoji TEXT NOT NULL,
              name TEXT NOT NULL,
              tier TEXT NOT NULL
            );
          ''');
          rawDb.execute('''
            CREATE TABLE user_garden (
              id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
              plant_id INTEGER NOT NULL REFERENCES plant_catalog(id),
              earned_at INTEGER NOT NULL,
              duration_minutes INTEGER NOT NULL
            );
          ''');
          rawDb.execute(
            "INSERT INTO plant_catalog (emoji, name, tier) VALUES ('🌱', 'Sprout', 'quick'), ('🌷', 'Flower', 'standard'), ('🌳', 'Tree', 'deep'), ('🥀', 'Withered', 'failed');",
          );
          rawDb.execute('PRAGMA user_version = 3;');
        },
      );

      final existingDb = AppDatabase.forTesting(nativeDb);
      addTearDown(existingDb.close);
      final existingRepo = GardenRepository(existingDb);

      final catalog = await existingRepo.getCatalog();
      expect(catalog.length, kPlantCatalogSpecs.length);
      expect(
        catalog.map((c) => c.tier).toSet().length,
        kPlantCatalogSpecs.length,
      );
    });
  });
}
