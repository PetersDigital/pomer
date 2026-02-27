import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomer/core/constants/app_constants.dart';
import 'package:pomer/features/timer/models/timer_state.dart';
import 'package:pomer/features/timer/providers/timer_provider.dart';
import 'package:pomer/features/timer/widgets/phase_utils.dart';

class TimerDisplay extends ConsumerWidget {
  const TimerDisplay({super.key});

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerNotifierProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final progress = timerState.totalSeconds > 0
        ? timerState.remainingSeconds / timerState.totalSeconds
        : 0.0;
    final color = phaseColor(timerState.phase, colorScheme);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 260,
          height: 260,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 12,
                  strokeCap: StrokeCap.round,
                  color: color,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(timerState.remainingSeconds),
                    style: textTheme.displayMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timerState.phase.label,
                    style: textTheme.titleMedium?.copyWith(
                      color: color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Session ${timerState.completedCycles + 1} of '
          '${AppConstants.defaultCyclesBeforeLongBreak}',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
