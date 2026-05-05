import 'package:pomer/database/database.dart';

class GardenRepository {
  final AppDatabase _db;

  GardenRepository(this._db);

  Stream<List<UserGardenItem>> watchUserGarden() {
    return _db.select(_db.userGarden).watch();
  }

  Future<void> insertPlant(int plantId, int durationMinutes) async {
    await _db.into(_db.userGarden).insert(
      UserGardenCompanion.insert(
        plantId: plantId,
        durationMinutes: durationMinutes,
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
}
