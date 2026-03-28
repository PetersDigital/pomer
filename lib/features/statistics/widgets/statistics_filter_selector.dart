import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomer/features/statistics/providers/statistics_filter_provider.dart';
import 'package:pomer/features/statistics/providers/statistics_provider.dart';

class StatisticsFilterSelector extends ConsumerWidget {
  const StatisticsFilterSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(statisticsTasksStreamProvider);
    final currentFilter = ref.watch(statisticsFilterNotifierProvider);

    return tasksAsync.when(
      data: (tasks) {
        final uniqueTags = <String>{};
        for (final task in tasks) {
          if (task.tag != null) {
            uniqueTags.add(task.tag!);
          }
        }
        final tags = uniqueTags.toList()..sort();

        if (tasks.isEmpty && tags.isEmpty) {
          return const SizedBox.shrink();
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              FilterChip(
                label: const Text('All'),
                selected: currentFilter.taskId == null && currentFilter.tag == null,
                onSelected: (selected) {
                  if (selected) {
                    ref.read(statisticsFilterNotifierProvider.notifier).clearFilters();
                  }
                },
              ),
              if (tags.isNotEmpty) ...[
                const SizedBox(width: 16),
                const Text('Tags:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                ...tags.map(
                  (tag) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(tag),
                      selected: currentFilter.tag == tag,
                      onSelected: (selected) {
                        ref
                            .read(statisticsFilterNotifierProvider.notifier)
                            .setTagFilter(selected ? tag : null);
                      },
                    ),
                  ),
                ),
              ],
              if (tasks.isNotEmpty) ...[
                const SizedBox(width: 16),
                const Text('Tasks:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                ...tasks.map(
                  (task) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(task.title),
                      selected: currentFilter.taskId == task.id,
                      onSelected: (selected) {
                        ref
                            .read(statisticsFilterNotifierProvider.notifier)
                            .setTaskFilter(selected ? task.id : null);
                      },
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
      loading: () => const SizedBox(
        height: 48,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
