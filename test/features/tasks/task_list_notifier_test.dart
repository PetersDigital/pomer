import 'package:flutter_test/flutter_test.dart';
import 'package:pomer/core/providers/task_list_provider.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('TaskListNotifier', () {
    test('emits correct list of tasks after insertion', () async {
      final container = createTestContainer();
      final notifier = container.read(taskListProvider.notifier);

      await notifier.addTask(title: 'New Task', tag: 'Tag 1');

      final tasks = await container.read(taskListProvider.future);
      expect(tasks.length, 1);
      expect(tasks.first.title, 'New Task');
      expect(tasks.first.tag, 'Tag 1');

      container.dispose();
    });
  });
}
