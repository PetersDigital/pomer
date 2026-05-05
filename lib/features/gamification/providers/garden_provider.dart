import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pomer/core/providers/database_provider.dart';
import 'package:pomer/database/database.dart';
import 'package:pomer/features/gamification/providers/garden_repository.dart';

part 'garden_provider.g.dart';

@riverpod
GardenRepository gardenRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return GardenRepository(db);
}

@riverpod
Stream<List<UserGardenItem>> userGarden(Ref ref) {
  final repository = ref.watch(gardenRepositoryProvider);
  return repository.watchUserGarden();
}

@riverpod
Future<List<PlantCatalogItem>> plantCatalog(Ref ref) {
  final repository = ref.watch(gardenRepositoryProvider);
  return repository.getCatalog();
}
