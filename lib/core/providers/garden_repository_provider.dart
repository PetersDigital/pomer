import 'package:drift/drift.dart' show OrderingTerm, Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomer/core/models/garden_models.dart';
import 'package:pomer/core/providers/database_provider.dart';
import 'package:pomer/database/database.dart';

class GardenRepository {
  final AppDatabase _db;
  int _eventCounter = 0;

  GardenRepository(this._db);

  Stream<List<UserGardenItem>> watchUserGarden() {
    return (_db.select(_db.userGarden)
          ..orderBy([
            (t) => OrderingTerm.desc(t.earnedAt),
            (t) => OrderingTerm.desc(t.id),
          ]))
        .watch();
  }

  Future<List<UserGardenItem>> getUserGarden() {
    return (_db.select(_db.userGarden)
          ..orderBy([
            (t) => OrderingTerm.desc(t.earnedAt),
            (t) => OrderingTerm.desc(t.id),
          ]))
        .get();
  }

  Future<void> insertPlant(
    int plantId,
    int durationMinutes, {
    DateTime? earnedAt,
  }) async {
    await _db.into(_db.userGarden).insert(
          UserGardenCompanion.insert(
            plantId: plantId,
            durationMinutes: durationMinutes,
            earnedAt:
                earnedAt != null ? Value(earnedAt) : const Value.absent(),
          ),
        );
  }

  Future<PlantCatalogItem?> getPlantCatalogItemByTier(String tier) async {
    return (_db.select(_db.plantCatalog)
          ..where((t) => t.tier.equals(tier))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<List<PlantCatalogItem>> getCatalog() async {
    return _db.select(_db.plantCatalog).get();
  }

  Future<GardenRewardEvent?> recordFocusOutcome({
    required bool isCompleted,
    required int durationMinutes,
    DateTime? now,
  }) async {
    await _db.ensurePlantCatalogSeeded();
    final catalog = await getCatalog();
    final gardenBefore = await getUserGarden();

    final catalogById = <int, PlantCatalogItem>{
      for (final item in catalog) item.id: item,
    };
    final catalogByTier = <String, PlantCatalogItem>{
      for (final item in catalog) item.tier: item,
    };

    if (!isCompleted) {
      final failedItem = catalogByTier['failed'];
      if (failedItem == null) return null;

      await insertPlant(failedItem.id, durationMinutes, earnedAt: now);
      return GardenRewardEvent(
        eventId: ++_eventCounter,
        plant: failedItem,
        isWithered: true,
        newlyUnlocked: const [],
      );
    }

    final statsBefore = computeGardenStats(
      garden: gardenBefore,
      catalogById: catalogById,
      now: now,
    );

    final String baseTier;
    if (durationMinutes < 20) {
      baseTier = 'quick';
    } else if (durationMinutes < 50) {
      baseTier = 'standard';
    } else {
      baseTier = 'deep';
    }

    final basePlant = catalogByTier[baseTier];
    if (basePlant == null) return null;

    final effectiveNow = now ?? DateTime.now();
    final afterGarden = [
      ...gardenBefore,
      UserGardenItem(
        id: -1,
        plantId: basePlant.id,
        earnedAt: effectiveNow,
        durationMinutes: durationMinutes,
      ),
    ];
    final statsAfter = computeGardenStats(
      garden: afterGarden,
      catalogById: catalogById,
      now: effectiveNow,
    );

    final newlyUnlocked = <PlantCatalogItem>[];
    for (final spec in kPlantCatalogSpecs) {
      if (spec.unlockType == PlantUnlockType.starter || spec.tier == 'failed') {
        continue;
      }
      final wasUnlocked = isPlantRuleUnlocked(spec, statsBefore);
      final isNowUnlocked = isPlantRuleUnlocked(spec, statsAfter);
      if (!wasUnlocked && isNowUnlocked) {
        final unlockedItem = catalogByTier[spec.tier];
        if (unlockedItem != null) {
          newlyUnlocked.add(unlockedItem);
        }
      }
    }

    final awardedPlant =
        newlyUnlocked.isNotEmpty ? newlyUnlocked.last : basePlant;

    await insertPlant(
      awardedPlant.id,
      durationMinutes,
      earnedAt: effectiveNow,
    );

    return GardenRewardEvent(
      eventId: ++_eventCounter,
      plant: awardedPlant,
      isWithered: false,
      newlyUnlocked: newlyUnlocked,
    );
  }
}

final gardenRepositoryProvider = Provider<GardenRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return GardenRepository(db);
});

final latestGardenRewardProvider =
    StateProvider<GardenRewardEvent?>((ref) => null);
