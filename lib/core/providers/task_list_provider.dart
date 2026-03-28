import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:pomer/database/database.dart';
import 'package:pomer/features/tasks/data/tasks_repository.dart';

part 'task_list_provider.g.dart';

@riverpod
class TaskList extends _$TaskList {
  @override
  Stream<List<Task>> build() {
    return ref.watch(tasksRepositoryProvider).watchAllTasks();
  }

  Future<void> addTask({
    required String title,
    String? tag,
  }) async {
    final companion = TasksCompanion.insert(
      title: title,
      tag: Value(tag),
    );
    await ref.read(tasksRepositoryProvider).insertTask(companion);
  }

  Future<void> toggleTaskCompletion(Task task, bool isCompleted) async {
    final updatedTask = task.copyWith(isCompleted: isCompleted);
    await ref.read(tasksRepositoryProvider).updateTask(updatedTask);
  }

  Future<void> deleteTask(Task task) async {
    await ref.read(tasksRepositoryProvider).deleteTask(task);
  }
}
