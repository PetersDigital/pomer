import 'package:flutter/material.dart';

/// Placeholder timer screen — full implementation coming in v0.2.0.
class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.timer_outlined,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Timer',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text('Coming in v0.2.0'),
          ],
        ),
      ),
    );
  }
}
