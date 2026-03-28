import 'package:drift/drift.dart';
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
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now())();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Sessions, Tasks])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(connection.openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from == 1) {
          await m.createTable(tasks);
        }
      },
    );
  }

  Future<int> clearAllSessions() => delete(sessions).go();
}
