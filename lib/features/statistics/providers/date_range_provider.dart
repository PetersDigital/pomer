import 'package:pomer/features/statistics/models/date_range.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'date_range_provider.g.dart';

@Riverpod(keepAlive: true)
class DateRangeNotifier extends _$DateRangeNotifier {
  @override
  DateRange build() {
    return _getPresetRange(DateRangePreset.thisWeek);
  }

  void setPreset(DateRangePreset preset) {
    if (preset == DateRangePreset.custom) {
      return; // Must provide dates for custom
    }
    state = _getPresetRange(preset);
  }

  void setCustomRange(DateTime start, DateTime end) {
    var finalStart = start;
    var finalEnd = end;

    // Ensure start is not after end
    if (finalEnd.isBefore(finalStart)) {
      final tmp = finalStart;
      finalStart = finalEnd;
      finalEnd = tmp;
    }

    // Normalize to full-day range, matching preset behavior
    final normalizedStart =
        DateTime(finalStart.year, finalStart.month, finalStart.day);
    final normalizedEnd = DateTime(finalEnd.year, finalEnd.month, finalEnd.day)
        .add(const Duration(days: 1))
        .subtract(const Duration(microseconds: 1));

    state = DateRange(
      start: normalizedStart,
      end: normalizedEnd,
      preset: DateRangePreset.custom,
    );
  }

  DateRange _getPresetRange(DateRangePreset preset) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (preset) {
      case DateRangePreset.today:
        return DateRange(
          start: today,
          end: today
              .add(const Duration(days: 1))
              .subtract(const Duration(microseconds: 1)),
          preset: preset,
        );
      case DateRangePreset.thisWeek:
        // Week starts on Monday
        final daysSinceMonday = today.weekday - 1;
        final startOfWeek = today.subtract(Duration(days: daysSinceMonday));
        return DateRange(
          start: startOfWeek,
          end: startOfWeek
              .add(const Duration(days: 7))
              .subtract(const Duration(microseconds: 1)),
          preset: preset,
        );
      case DateRangePreset.thisMonth:
        final startOfMonth = DateTime(now.year, now.month, 1);
        final nextMonth = DateTime(now.year, now.month + 1, 1);
        return DateRange(
          start: startOfMonth,
          end: nextMonth.subtract(const Duration(microseconds: 1)),
          preset: preset,
        );
      case DateRangePreset.allTime:
        return DateRange(
          start: DateTime.fromMillisecondsSinceEpoch(0),
          end: now,
          preset: preset,
        );
      case DateRangePreset.custom:
        return state;
    }
  }
}
