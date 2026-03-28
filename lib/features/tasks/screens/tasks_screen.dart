import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/task_list_provider.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsyncValue = ref.watch(taskListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
      ),
      body: tasksAsyncValue.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return const Center(
              child: Text('No tasks yet. Add one!'),
            );
          }
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return ListTile(
                leading: Checkbox(
                  value: task.isCompleted,
                  onChanged: (bool? value) {
                    if (value != null) {
                      ref
                          .read(taskListProvider.notifier)
                          .toggleTaskCompletion(task, value);
                    }
                  },
                ),
                title: Text(
                  task.title,
                  style: TextStyle(
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                subtitle: task.tag != null
                    ? Align(
                        alignment: Alignment.centerLeft,
                        child: Chip(
                          label: Text(task.tag!),
                          padding: EdgeInsets.zero,
                          labelStyle: const TextStyle(fontSize: 12),
                        ),
                      )
                    : null,
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    ref.read(taskListProvider.notifier).deleteTask(task);
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (BuildContext context) {
              return const _AddTaskModal();
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AddTaskModal extends ConsumerStatefulWidget {
  const _AddTaskModal();

  @override
  ConsumerState<_AddTaskModal> createState() => _AddTaskModalState();
}

class _AddTaskModalState extends ConsumerState<_AddTaskModal> {
  late final TextEditingController _titleController;
  late final TextEditingController _tagController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _tagController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16.0,
        right: 16.0,
        top: 24.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Add New Task',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Task Title',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _tagController,
            decoration: const InputDecoration(
              labelText: 'Tag (Optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              final title = _titleController.text.trim();
              final tag = _tagController.text.trim();

              if (title.isNotEmpty) {
                ref.read(taskListProvider.notifier).addTask(
                      title: title,
                      tag: tag.isEmpty ? null : tag,
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Add Task'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
