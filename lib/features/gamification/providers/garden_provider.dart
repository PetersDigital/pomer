import 'package:flutter_riverpod/flutter_riverpod.dart';
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
