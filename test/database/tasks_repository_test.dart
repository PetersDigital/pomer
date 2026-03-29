import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomer/features/tasks/data/tasks_repository.dart';
import 'package:pomer/database/database.dart';
import 'package:pomer/core/providers/database_provider.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('TasksRepository', () {
    late AppDatabase db;
    late TasksRepository repository;

    setUp(() {
      final container = createTestContainer();
      db = container.read(appDatabaseProvider);
      repository = container.read(tasksRepositoryProvider);
    });

    tearDown(() async {
      await db.close();
    });

    test('addTask inserts a task correctly', () async {
      await repository.insertTask(
        const TasksCompanion(
          title: Value('Test Task'),
          tag: Value('Work'),
        ),
      );

      final tasks = await repository.watchAllTasks().first;
      expect(tasks.length, 1);
      expect(tasks.first.title, 'Test Task');
      expect(tasks.first.tag, 'Work');
      expect(tasks.first.isCompleted, false);
    });

    test('toggleTaskCompletion updates the task status', () async {
      await repository.insertTask(
        const TasksCompanion(
          title: Value('Another Task'),
        ),
      );

      var tasks = await repository.watchAllTasks().first;
      final task = tasks.first;
      expect(task.isCompleted, false);

      final updatedTask = task.copyWith(isCompleted: true);
      await repository.updateTask(updatedTask);

      tasks = await repository.watchAllTasks().first;
      expect(tasks.first.isCompleted, true);
    });

    test('deleteTask removes the task', () async {
      await repository.insertTask(
        const TasksCompanion(
          title: Value('Task to Delete'),
        ),
      );

      var tasks = await repository.watchAllTasks().first;
      expect(tasks.length, 1);

      await repository.deleteTask(tasks.first);

      tasks = await repository.watchAllTasks().first;
      expect(tasks.isEmpty, true);
    });
  });
}
