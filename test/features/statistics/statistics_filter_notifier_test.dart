import 'package:flutter_test/flutter_test.dart';
import 'package:pomer/features/statistics/providers/statistics_filter_provider.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('StatisticsFilterNotifier', () {
    test('setting Task ID correctly nullifies the Tag, and vice versa', () {
      final container = createTestContainer();
      final notifier = container.read(statisticsFilterNotifierProvider.notifier);

      notifier.setTaskFilter('task-123');
      var state = container.read(statisticsFilterNotifierProvider);

      expect(state.taskId, 'task-123');
      expect(state.tag, isNull);

      notifier.setTagFilter('Urgent');
      state = container.read(statisticsFilterNotifierProvider);

      expect(state.tag, 'Urgent');
      expect(state.taskId, isNull);

      notifier.clearFilters();
      state = container.read(statisticsFilterNotifierProvider);

      expect(state.taskId, isNull);
      expect(state.tag, isNull);

      container.dispose();
    });
  });
}
