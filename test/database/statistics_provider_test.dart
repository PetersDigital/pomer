import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomer/core/providers/database_provider.dart';
import 'package:pomer/database/database.dart';
import 'package:pomer/features/statistics/providers/date_range_provider.dart';
import 'package:pomer/features/statistics/providers/statistics_filter_provider.dart';
import 'package:pomer/features/statistics/providers/statistics_provider.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('StatisticsProvider', () {
    test('sessionsByDateRange correctly filters by Date, taskId, and tag', () async {
      final container = createTestContainer();
      final db = container.read(appDatabaseProvider);

      const task1Id = 't1';
      const task2Id = 't2';

      await db.into(db.tasks).insert(TasksCompanion.insert(id: const Value(task1Id), title: 'T1', tag: const Value('Urgent')));
      await db.into(db.tasks).insert(TasksCompanion.insert(id: const Value(task2Id), title: 'T2', tag: const Value('Work')));

      final now = DateTime.now();

      // Add sessions
      await db.into(db.sessions).insert(
        SessionsCompanion.insert(
          startTime: now.subtract(const Duration(hours: 1)),
          endTime: now,
          durationSeconds: 1500,
          phaseType: 'focus',
          status: 'completed',
          taskId: const Value(task1Id),
        ),
      );

      await db.into(db.sessions).insert(
        SessionsCompanion.insert(
          startTime: now.subtract(const Duration(days: 2)),
          endTime: now.subtract(const Duration(days: 2, hours: -1)),
          durationSeconds: 1500,
          phaseType: 'focus',
          status: 'completed',
          taskId: const Value(task2Id),
        ),
      );

      // Test 1: Date Range Filter (Current Day only)
      container.read(dateRangeNotifierProvider.notifier).setCustomRange(
        now.subtract(const Duration(days: 1)),
        now.add(const Duration(days: 1)),
      );
      var sessions = await container.read(sessionsByDateRangeProvider.future);
      expect(sessions.length, 1);
      expect(sessions.first.taskId, task1Id);

      // Test 2: Task ID Filter
      container.read(dateRangeNotifierProvider.notifier).setCustomRange(
        now.subtract(const Duration(days: 5)),
        now.add(const Duration(days: 1)),
      );
      container.read(statisticsFilterNotifierProvider.notifier).setTaskFilter(task2Id);
      sessions = await container.read(sessionsByDateRangeProvider.future);
      expect(sessions.length, 1);
      expect(sessions.first.taskId, task2Id);

      // Test 3: Tag Filter
      container.read(statisticsFilterNotifierProvider.notifier).setTagFilter('Urgent');
      sessions = await container.read(sessionsByDateRangeProvider.future);
      expect(sessions.length, 1);
      expect(sessions.first.taskId, task1Id);

      container.dispose();
      await db.close();
    });
  });
}
