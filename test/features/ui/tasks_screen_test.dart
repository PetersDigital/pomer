import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomer/features/tasks/screens/tasks_screen.dart';

import '../../helpers/test_helpers.dart';

void main() {
  testWidgets('TasksScreen allows adding and completing a task',
      (tester) async {
    final container = createTestContainer();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: TasksScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify empty state
    expect(find.text('No tasks yet. Add one!'), findsOneWidget);

    // Tap FAB to add task
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Enter task title and tag
    await tester.enterText(find.byType(TextField).first, 'Buy groceries');
    await tester.enterText(find.byType(TextField).last, 'Personal');

    // Tap Save/Add Task
    await tester.tap(find.text('Add Task'));
    await tester.pumpAndSettle();

    // Verify task is in the list
    expect(find.text('Buy groceries'), findsOneWidget);
    expect(find.text('Personal'), findsOneWidget);
    expect(find.byType(Checkbox), findsOneWidget);

    // Tap checkbox to complete task
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    // Verify checkbox is checked (implicitly via visual update, harder to assert exact value directly without custom finder, but tap works)
    final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
    expect(checkbox.value, true);

    // Wait for Drift stream queries and Future timers to settle before disposing
    await tester.pumpAndSettle(const Duration(seconds: 1));
  });
}
