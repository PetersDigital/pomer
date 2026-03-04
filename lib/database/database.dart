import 'package:drift/drift.dart';
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

@DriftDatabase(tables: [Sessions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(connection.openConnection());

  @override
  int get schemaVersion => 1;
}
