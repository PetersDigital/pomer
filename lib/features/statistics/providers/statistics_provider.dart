import 'package:pomer/core/providers/database_provider.dart';
import 'package:pomer/database/database.dart';
import 'package:pomer/features/statistics/providers/date_range_provider.dart';
import 'package:pomer/features/statistics/providers/statistics_filter_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';

part 'statistics_provider.g.dart';

@Riverpod(keepAlive: true)
Stream<List<Task>> statisticsTasksStream(Ref ref) {
  final db = ref.read(appDatabaseProvider);
  return db.select(db.tasks).watch();
}

@Riverpod(keepAlive: true)
Future<List<TypedResult>> rawSessionsQuery(
  Ref ref, {
  bool requireTaskJoin = false,
}) async {
  final db = ref.read(appDatabaseProvider);
  final dateRange = ref.watch(dateRangeNotifierProvider);
  final filter = ref.watch(statisticsFilterNotifierProvider);

  final shouldJoinTasks = requireTaskJoin || filter.tag != null;

  final joins = shouldJoinTasks
      ? [leftOuterJoin(db.tasks, db.tasks.id.equalsExp(db.sessions.taskId))]
      : <Join<HasResultSet, dynamic>>[];

  final query = db.select(db.sessions).join(joins)
    ..where(
      db.sessions.startTime.isBiggerOrEqualValue(dateRange.start) &
          db.sessions.startTime.isSmallerOrEqualValue(dateRange.end),
    );

  if (filter.taskId != null) {
    query.where(db.sessions.taskId.equals(filter.taskId!));
  } else if (filter.tag != null) {
    query.where(db.tasks.tag.equals(filter.tag!));
  }

  return query.get();
}

@Riverpod(keepAlive: true)
Future<List<Session>> sessionsByDateRange(Ref ref) async {
  final db = ref.read(appDatabaseProvider);
  final rows = await ref.watch(
    rawSessionsQueryProvider(requireTaskJoin: false).future,
  );

  return rows.map((row) => row.readTable(db.sessions)).toList();
}

class SummaryStats {
  final int totalFocusSeconds;
  final int totalBreakSeconds;
  final int incompleteSessions;

  const SummaryStats({
    required this.totalFocusSeconds,
    required this.totalBreakSeconds,
    required this.incompleteSessions,
  });
}

@Riverpod(keepAlive: true)
Future<SummaryStats> summaryStats(Ref ref) async {
  final sessions = await ref.watch(sessionsByDateRangeProvider.future);

  int focus = 0;
  int breakTime = 0;
  int incomplete = 0;

  for (final session in sessions) {
    if (session.status != 'completed') {
      incomplete++;
    }

    if (session.phaseType == 'focus') {
      focus += session.durationSeconds;
    } else if (session.phaseType == 'shortBreak' ||
        session.phaseType == 'longBreak') {
      breakTime += session.durationSeconds;
    }
  }

  return SummaryStats(
    totalFocusSeconds: focus,
    totalBreakSeconds: breakTime,
    incompleteSessions: incomplete,
  );
}
