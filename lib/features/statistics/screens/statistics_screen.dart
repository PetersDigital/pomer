import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomer/features/statistics/widgets/date_range_selector.dart';
import 'package:pomer/features/statistics/widgets/focus_bar_chart.dart';
import 'package:pomer/features/statistics/widgets/summary_stats_card.dart';
import 'package:pomer/features/statistics/services/csv_export_service.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              try {
                await ref.read(csvExportServiceProvider).exportSessions();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Export successful')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Export failed: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: DateRangeSelector(),
            ),
            SummaryStatsCard(),
            FocusBarChart(),
          ],
        ),
      ),
    );
  }
}
