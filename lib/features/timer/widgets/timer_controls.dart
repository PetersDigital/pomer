import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomer/features/timer/models/timer_state.dart';
import 'package:pomer/features/timer/providers/timer_provider.dart';

class TimerControls extends ConsumerWidget {
  const TimerControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerNotifierProvider);
    final notifier = ref.read(timerNotifierProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (timerState.status == TimerStatus.idle) ...[
          FilledButton.icon(
            onPressed: notifier.start,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start'),
          ),
        ] else ...[
          if (timerState.status == TimerStatus.running)
            IconButton.filled(
              onPressed: notifier.pause,
              icon: const Icon(Icons.pause),
              tooltip: 'Pause',
            )
          else
            IconButton.filled(
              onPressed: notifier.start,
              icon: const Icon(Icons.play_arrow),
              tooltip: 'Resume',
            ),
          const SizedBox(width: 16),
          IconButton.filledTonal(
            onPressed: notifier.reset,
            icon: const Icon(Icons.stop),
            tooltip: 'Reset',
          ),
        ],
        const SizedBox(width: 16),
        IconButton(
          onPressed: notifier.skip,
          icon: const Icon(Icons.skip_next),
          tooltip: 'Skip',
        ),
      ],
    );
  }
}
