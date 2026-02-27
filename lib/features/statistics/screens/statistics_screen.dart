import 'package:flutter/material.dart';

/// Placeholder statistics screen — full implementation coming in v0.5.0.
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.bar_chart_outlined,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Stats',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text('Coming in v0.5.0'),
          ],
        ),
      ),
    );
  }
}
