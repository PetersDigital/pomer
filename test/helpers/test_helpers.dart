import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:pomer/database/database.dart';
import 'package:pomer/core/providers/database_provider.dart';

ProviderContainer createTestContainer({
  AppDatabase? db,
  List<Override> overrides = const [],
}) {
  final testDb = db ?? AppDatabase.forTesting(NativeDatabase.memory());

  final container = ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWithValue(testDb),
      ...overrides,
    ],
  );

  return container;
}
