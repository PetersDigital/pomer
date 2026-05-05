import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pomer/core/utils/platform_utils.dart';
import 'package:pomer/features/timer/models/timer_state.dart';
import 'package:pomer/features/timer/providers/timer_provider.dart';

class TimerControls extends ConsumerStatefulWidget {
  const TimerControls({super.key});

  @override
  ConsumerState<TimerControls> createState() => _TimerControlsState();
}

class _TimerControlsState extends ConsumerState<TimerControls> {
  bool _skipResetConfirmation = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _skipResetConfirmation =
              prefs.getBool('skip_reset_session_confirmation') ?? false;
        });
      }
    } catch (e) {
      // Ignore errors in tests or unsupported platforms
      // SharedPreferences may not be available in test environment
    }
  }

  Future<void> _showResetSessionConfirmation() async {
    if (_skipResetConfirmation) {
      ref.read(timerNotifierProvider.notifier).resetFullSession();
      return;
    }

    bool dontShowAgain = false;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Start Fresh?'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'This will reset all completed cycles and sessions for this timer. This action cannot be undone.',
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: dontShowAgain,
                        onChanged: (value) {
                          setDialogState(() {
                            dontShowAgain = value ?? false;
                          });
                        },
                      ),
                      const Expanded(
                        child: Text("Don't ask again"),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,),
                  child: const Text('Start Fresh'),
                ),
              ],
              actionsPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            );
          },
        );
      },
    );

    if (confirmed == true && mounted) {
      if (dontShowAgain) {
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('skip_reset_session_confirmation', true);
          if (mounted) {
            setState(() {
              _skipResetConfirmation = true;
            });
          }
        } catch (e) {
          // Ignore errors in tests or unsupported platforms
        }
      }
      ref.read(timerNotifierProvider.notifier).resetFullSession();
    }
  }

  @override
  Widget build(BuildContext context) {
    final timerStatus = ref.watch(timerNotifierProvider.select((state) => state.status));
    final notifier = ref.read(timerNotifierProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (timerStatus == TimerStatus.idle) ...[
          FilledButton.icon(
            onPressed: () async {
              if (PlatformUtils.isMobile &&
                  await Permission.notification.isDenied) {
                await Permission.notification.request();
              }
              notifier.start();
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start'),
          ),
        ] else ...[
          if (timerStatus == TimerStatus.running)
            IconButton.filled(
              onPressed: notifier.pause,
              icon: const Icon(Icons.pause),
              tooltip: 'Pause',
            )
          else
            IconButton.filled(
              onPressed: () async {
                if (PlatformUtils.isMobile &&
                    await Permission.notification.isDenied) {
                  await Permission.notification.request();
                }
                notifier.start();
              },
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
        const SizedBox(width: 8),
        IconButton(
          onPressed: _showResetSessionConfirmation,
          icon: const Icon(Icons.restore),
          tooltip: 'Start Fresh',
          color: colorScheme.error,
        ),
      ],
    );
  }
}
