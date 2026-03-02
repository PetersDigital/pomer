import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomer/features/timer/models/timer_state.dart';
import 'package:pomer/features/timer/providers/timer_provider.dart';
import 'package:pomer/features/timer/widgets/phase_utils.dart';
import 'package:pomer/features/timer/widgets/timer_controls.dart';
import 'package:pomer/features/timer/widgets/timer_display.dart';
import 'package:pomer/features/timer/providers/audio_enabled_provider.dart';

/// Full Pomodoro timer screen — v0.4.0.
class TimerScreen extends ConsumerWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerNotifierProvider);
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
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Chip(
                        label: Text(timerState.phase.label),
                        backgroundColor: color.withAlpha(40),
                        labelStyle: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: Icon(
                          ref.watch(audioEnabledNotifierProvider)
                              ? Icons.volume_up
                              : Icons.volume_off,
                          color: color,
                        ),
                        onPressed: () {
                          ref.read(audioEnabledNotifierProvider.notifier).toggle();
                        },
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const TimerDisplay(),
                const Spacer(),
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
