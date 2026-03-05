import 'package:pomer/core/providers/database_provider.dart';
import 'package:pomer/database/database.dart';
import 'package:pomer/features/statistics/providers/date_range_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';

part 'statistics_provider.g.dart';

@riverpod
Future<List<Session>> sessionsByDateRange(Ref ref) async {
  final db = ref.read(appDatabaseProvider);
  final dateRange = ref.watch(dateRangeNotifierProvider);

  return (db.select(db.sessions)
        ..where((t) =>
            t.startTime.isBiggerOrEqualValue(dateRange.start) &
            t.startTime.isSmallerOrEqualValue(dateRange.end),))
      .get();
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

@riverpod
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
    } else if (session.phaseType == 'shortBreak' || session.phaseType == 'longBreak') {
      breakTime += session.durationSeconds;
    }
  }

  return SummaryStats(
    totalFocusSeconds: focus,
    totalBreakSeconds: breakTime,
    incompleteSessions: incomplete,
  );
}
