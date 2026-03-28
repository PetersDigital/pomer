import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers/database_provider.dart';
import '../../../database/database.dart';

part 'tasks_repository.g.dart';

class TasksRepository {
  final AppDatabase _db;

  const TasksRepository(this._db);

  Stream<List<Task>> watchAllTasks() {
    return _db.select(_db.tasks).watch();
  }

  Future<int> insertTask(TasksCompanion task) {
    return _db.into(_db.tasks).insert(task);
  }

  Future<bool> updateTask(Task task) {
    return _db.update(_db.tasks).replace(task);
  }

  Future<int> deleteTask(Task task) {
    return _db.delete(_db.tasks).delete(task);
  }
}

@riverpod
TasksRepository tasksRepository(Ref ref) {
  return TasksRepository(ref.watch(appDatabaseProvider));
}
