import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomer/features/timer/models/timer_state.dart';
import 'package:pomer/features/timer/providers/timer_provider.dart';
import 'package:pomer/features/timer/widgets/phase_utils.dart';
import 'package:pomer/features/timer/widgets/timer_controls.dart';
import 'package:pomer/features/timer/widgets/timer_display.dart';
import 'package:pomer/features/timer/providers/audio_preferences_provider.dart';
import 'package:pomer/core/providers/active_task_provider.dart';
import 'package:pomer/core/providers/task_list_provider.dart';

/// Full Pomodoro timer screen.
class TimerScreen extends ConsumerWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerNotifierProvider);
    final audioPrefsAsync = ref.watch(audioPreferencesNotifierProvider);
    final activeTask = ref.watch(activeTaskProvider);
    final tasksAsync = ref.watch(taskListProvider);

    final colorScheme = Theme.of(context).colorScheme;
    final color = phaseColor(timerState.phase, colorScheme);

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                Chip(
                  label: Text(timerState.phase.label),
                  backgroundColor: color.withAlpha(40),
                  labelStyle: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                audioPrefsAsync.when(
                  data: (prefs) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: prefs.focusAudioEnabled
                              ? 'Mute Focus Music'
                              : 'Unmute Focus Music',
                          icon: Icon(
                            prefs.focusAudioEnabled
                                ? Icons.headphones
                                : Icons.headphones_outlined,
                            color: prefs.focusAudioEnabled
                                ? color
                                : colorScheme.onSurfaceVariant.withAlpha(120),
                            size: 20,
                          ),
                          onPressed: () {
                            ref
                                .read(audioPreferencesNotifierProvider.notifier)
                                .toggleFocusAudio();
                          },
                        ),
                        IconButton(
                          tooltip: prefs.breakAudioEnabled
                              ? 'Mute Long Break Music'
                              : 'Unmute Long Break Music',
                          icon: Icon(
                            prefs.breakAudioEnabled
                                ? Icons.coffee
                                : Icons.coffee_outlined,
                            color: prefs.breakAudioEnabled
                                ? color
                                : colorScheme.onSurfaceVariant.withAlpha(120),
                            size: 20,
                          ),
                          onPressed: () {
                            ref
                                .read(audioPreferencesNotifierProvider.notifier)
                                .toggleBreakAudio();
                          },
                        ),
                        IconButton(
                          tooltip: prefs.alarmAudioEnabled
                              ? 'Mute Alarm'
                              : 'Unmute Alarm',
                          icon: Icon(
                            prefs.alarmAudioEnabled
                                ? Icons.alarm
                                : Icons.alarm_off,
                            color: prefs.alarmAudioEnabled
                                ? color
                                : colorScheme.onSurfaceVariant.withAlpha(120),
                            size: 20,
                          ),
                          onPressed: () {
                            ref
                                .read(audioPreferencesNotifierProvider.notifier)
                                .toggleAlarmAudio();
                          },
                        ),
                      ],
                    );
                  },
                  loading: () => const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const Spacer(),
                const TimerDisplay(),
                const Spacer(),
                tasksAsync.when(
                  data: (tasks) {
                    final uncompletedTasks =
                        tasks.where((t) => !t.isCompleted).toList();
                    if (uncompletedTasks.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: DropdownMenu<String>(
                        width: 250,
                        initialSelection: activeTask?.id,
                        label: const Text('Active Task'),
                        onSelected: (String? taskId) {
                          if (taskId == null || taskId.isEmpty) {
                            ref
                                .read(activeTaskProvider.notifier)
                                .clearActiveTask();
                          } else {
                            final selectedTask = uncompletedTasks
                                .firstWhere((t) => t.id == taskId);
                            ref
                                .read(activeTaskProvider.notifier)
                                .setActiveTask(selectedTask);
                          }
                        },
                        dropdownMenuEntries: [
                          const DropdownMenuEntry<String>(
                            value: '',
                            label: 'None',
                          ),
                          ...uncompletedTasks.map((t) {
                            return DropdownMenuEntry<String>(
                              value: t.id,
                              label: t.title,
                            );
                          }),
                        ],
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const TimerControls(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
