import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomer/features/statistics/screens/statistics_screen.dart';
import 'package:pomer/features/statistics/providers/statistics_filter_provider.dart';
import 'package:pomer/database/database.dart';
import 'package:pomer/core/providers/database_provider.dart';
import 'package:drift/drift.dart' as drift;

import '../../helpers/test_helpers.dart';

void main() {
  testWidgets('StatisticsScreen clears active filter when "All" chip is tapped',
      (tester) async {
    final container = createTestContainer();
    final notifier = container.read(statisticsFilterNotifierProvider.notifier);

    // Initial state setup:
    notifier.setTaskFilter('fake-task-id');
    expect(container.read(statisticsFilterNotifierProvider).taskId,
        'fake-task-id',);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: StatisticsScreen(),
        ),
      ),
    );

    // Give StreamProviders time to emit initial empty lists and settle the UI
    await tester.pumpAndSettle();

    // In test environments, if there are no tasks/tags, the whole selector might not render
    // or just render "All". We just want to ensure it pumps fully.
    await tester.pump(const Duration(milliseconds: 500));

    // Since the database starts empty, the StatisticsFilterSelector might return SizedBox.shrink()
    // Let's insert a dummy task so the filters appear.
    final db = container.read(appDatabaseProvider);
    await db.into(db.tasks).insert(
          TasksCompanion.insert(
            id: const drift.Value('fake-task-id'),
            title: 'Fake Task',
          ),
        );

    // Pump again to let the StreamProvider react to the insert
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify "All" filter chip exists
    final allChip = find.widgetWithText(FilterChip, 'All');
    expect(allChip, findsOneWidget);

    // Tap "All"
    await tester.tap(allChip);
    await tester.pumpAndSettle();

    // Verify Riverpod state was cleared
    expect(container.read(statisticsFilterNotifierProvider).taskId, isNull);
    expect(container.read(statisticsFilterNotifierProvider).tag, isNull);
  });
}
