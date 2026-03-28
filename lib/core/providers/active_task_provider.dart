import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:pomer/database/database.dart';

part 'active_task_provider.g.dart';

@Riverpod(keepAlive: true)
class ActiveTask extends _$ActiveTask {
  @override
  Task? build() {
    return null;
  }

  void setActiveTask(Task task) {
    state = task;
  }

  void clearActiveTask() {
    state = null;
  }
}
