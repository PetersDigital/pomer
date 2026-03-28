import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomer/core/providers/database_provider.dart';
import 'package:pomer/database/database.dart';
import 'package:pomer/features/statistics/providers/statistics_filter_provider.dart';

class StatisticsFilterSelector extends ConsumerStatefulWidget {
  const StatisticsFilterSelector({super.key});

  @override
  ConsumerState<StatisticsFilterSelector> createState() =>
      _StatisticsFilterSelectorState();
}

class _StatisticsFilterSelectorState extends ConsumerState<StatisticsFilterSelector> {
  List<Task> _tasks = [];
  List<String> _tags = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFilters();
  }

  Future<void> _loadFilters() async {
    final db = ref.read(appDatabaseProvider);
    try {
      final tasks = await db.select(db.tasks).get();

      final uniqueTags = <String>{};
      for (final task in tasks) {
        if (task.tag != null) {
          uniqueTags.add(task.tag!);
        }
      }

      if (mounted) {
        setState(() {
          _tasks = tasks;
          _tags = uniqueTags.toList()..sort();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(height: 48, child: Center(child: CircularProgressIndicator()));
    }

    if (_tasks.isEmpty && _tags.isEmpty) {
      return const SizedBox.shrink();
    }

    final currentFilter = ref.watch(statisticsFilterNotifierProvider);

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
                ref.read(statisticsFilterNotifierProvider.notifier).setTaskFilter(null);
                ref.read(statisticsFilterNotifierProvider.notifier).setTagFilter(null);
              }
            },
          ),
          if (_tags.isNotEmpty) ...[
            const SizedBox(width: 16),
            const Text('Tags:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            ..._tags.map(
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
          if (_tasks.isNotEmpty) ...[
            const SizedBox(width: 16),
            const Text('Tasks:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            ..._tasks.map(
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
  }
}
