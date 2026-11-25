import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomer/core/models/garden_models.dart';
import 'package:pomer/core/providers/garden_repository_provider.dart';
import 'package:pomer/database/database.dart';

final userGardenProvider =
    StreamProvider.autoDispose<List<UserGardenItem>>((ref) {
  final repository = ref.watch(gardenRepositoryProvider);
  return repository.watchUserGarden();
});

final plantCatalogProvider =
    FutureProvider.autoDispose<List<PlantCatalogItem>>((ref) {
  final repository = ref.watch(gardenRepositoryProvider);
  return repository.getCatalog();
});

final gardenStatsProvider = Provider.autoDispose<GardenStats>((ref) {
  final garden = ref.watch(userGardenProvider).valueOrNull;
  final catalog = ref.watch(plantCatalogProvider).valueOrNull;

  if (garden == null || catalog == null) {
    return const GardenStats.empty();
  }

  final catalogById = <int, PlantCatalogItem>{
    for (final item in catalog) item.id: item,
  };

  return computeGardenStats(
    garden: garden,
    catalogById: catalogById,
  );
});

final plantCollectionProvider =
    Provider.autoDispose<List<PlantCollectionEntry>>((ref) {
  final garden = ref.watch(userGardenProvider).valueOrNull;
  final catalog = ref.watch(plantCatalogProvider).valueOrNull;
  final stats = ref.watch(gardenStatsProvider);

  if (garden == null || catalog == null) {
    return const [];
  }

  return buildPlantCollection(
    catalog: catalog,
    garden: garden,
    stats: stats,
  );
});
