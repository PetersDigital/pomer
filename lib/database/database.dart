import 'package:drift/drift.dart';
import 'package:pomer/core/models/garden_models.dart';
import 'package:uuid/uuid.dart';
import 'connection.dart' as connection;

part 'database.g.dart';

@DataClassName('Session')
class Sessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime()();
  IntColumn get durationSeconds => integer()();
  TextColumn get phaseType => text()(); // Focus, ShortBreak, LongBreak
  TextColumn get status => text()(); // completed, skipped, interrupted
  TextColumn get taskId => text().nullable()(); // Prep for v0.6.0
}

@DataClassName('Task')
class Tasks extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  TextColumn get title => text()();
  TextColumn get tag => text().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now())();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PlantCatalogItem')
class PlantCatalog extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get emoji => text()();
  TextColumn get name => text()();
  TextColumn get tier => text()(); // quick, standard, deep, failed
}

@DataClassName('UserGardenItem')
class UserGarden extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get plantId => integer().references(PlantCatalog, #id)();
  DateTimeColumn get earnedAt =>
      dateTime().clientDefault(() => DateTime.now())();
  IntColumn get durationMinutes => integer()();
}

@DriftDatabase(tables: [Sessions, Tasks, PlantCatalog, UserGarden])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(connection.openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await ensurePlantCatalogSeeded();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from == 1) {
          await m.createTable(tasks);
        }
        if (from <= 2) {
          await m.createTable(plantCatalog);
          await m.createTable(userGarden);
          await ensurePlantCatalogSeeded();
        }
      },
      beforeOpen: (details) async {
        await ensurePlantCatalogSeeded();
      },
    );
  }

  Future<void> ensurePlantCatalogSeeded() async {
    final existingRows = await select(plantCatalog).get();
    final existingTiers = existingRows.map((row) => row.tier).toSet();
    final missingSpecs = kPlantCatalogSpecs
        .where((spec) => !existingTiers.contains(spec.tier))
        .toList();

    if (missingSpecs.isEmpty) return;

    await batch((batch) {
      batch.insertAll(
        plantCatalog,
        missingSpecs
            .map(
              (spec) => PlantCatalogCompanion.insert(
                emoji: spec.emoji,
                name: spec.name,
                tier: spec.tier,
              ),
            )
            .toList(),
      );
    });
  }

  Future<int> clearAllSessions() => delete(sessions).go();
}
