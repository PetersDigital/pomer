import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'statistics_filter_provider.g.dart';

typedef StatisticsFilterState = ({String? taskId, String? tag});

@Riverpod(keepAlive: true)
class StatisticsFilterNotifier extends _$StatisticsFilterNotifier {
  @override
  StatisticsFilterState build() {
    return (taskId: null, tag: null);
  }

  void setTaskFilter(String? taskId) {
    if (taskId == null) {
      state = (taskId: null, tag: state.tag);
    } else {
      state = (taskId: taskId, tag: null);
    }
  }

  void setTagFilter(String? tag) {
    if (tag == null) {
      state = (taskId: state.taskId, tag: null);
    } else {
      state = (taskId: null, tag: tag);
    }
  }
}
