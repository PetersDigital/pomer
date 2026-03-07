import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomer/features/statistics/providers/statistics_provider.dart';
import 'package:pomer/features/statistics/providers/date_range_provider.dart';
import 'package:pomer/features/statistics/models/date_range.dart';

class FocusBarChart extends ConsumerWidget {
  const FocusBarChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(sessionsByDateRangeProvider);
    final dateRange = ref.watch(dateRangeNotifierProvider);

    return sessionsAsync.when(
      data: (sessions) {
        final Map<DateTime, int> focusByDay = {};

        // If the range is massive (e.g. All Time), capping the UI days makes it performant.
        // We will collect the actual days that have sessions first, and then build a bounded range.
        final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
        DateTime minDate = today;
        DateTime maxDate = today;

        if (dateRange.preset == DateRangePreset.allTime) {
          if (sessions.isNotEmpty) {
            final firstSessionDate = sessions.first.startTime;
            minDate = DateTime(firstSessionDate.year, firstSessionDate.month, firstSessionDate.day);
          }
        } else {
           minDate = DateTime(dateRange.start.year, dateRange.start.month, dateRange.start.day);
           maxDate = DateTime(dateRange.end.year, dateRange.end.month, dateRange.end.day);
        }

        // Ensure we don't render more than ~100 bars to prevent UI freezing
        if (maxDate.difference(minDate).inDays > 100) {
           minDate = maxDate.subtract(const Duration(days: 100));
        }

        // Populate days in bounds
        for (var d = minDate; !d.isAfter(maxDate); d = d.add(const Duration(days: 1))) {
           focusByDay[DateTime(d.year, d.month, d.day)] = 0;
        }

        // Aggregate focus duration by day
        for (final session in sessions) {
          if (session.phaseType == 'focus') {
             final day = DateTime(session.startTime.year, session.startTime.month, session.startTime.day);
             if (focusByDay.containsKey(day)) {
               focusByDay[day] = focusByDay[day]! + session.durationSeconds;
             }
          }
        }

        final sortedDays = focusByDay.keys.toList()..sort();
        final spots = <BarChartGroupData>[];

        double maxDuration = 1;
        for (int i = 0; i < sortedDays.length; i++) {
          final day = sortedDays[i];
          final durationMinutes = focusByDay[day]! / 60.0;
          if (durationMinutes > maxDuration) {
             maxDuration = durationMinutes;
          }
          spots.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: durationMinutes,
                color: Theme.of(context).colorScheme.primary,
                width: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),);
        }

        return AspectRatio(
          aspectRatio: 1.5,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxDuration * 1.2,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toInt()} min',
                        TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= sortedDays.length) {
                          return const SizedBox.shrink();
                        }
                        final date = sortedDays[index];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            '${date.day}/${date.month}',
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      },
                      reservedSize: 28,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        return Text(
                          '${value.toInt()}m',
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: spots,
              ),
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error loading charts: $e')),
    );
  }
}
