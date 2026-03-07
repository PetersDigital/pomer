enum DateRangePreset {
  today('Today'),
  thisWeek('This Week'),
  thisMonth('This Month'),
  allTime('All Time'),
  custom('Custom');

  final String label;
  const DateRangePreset(this.label);
}

class DateRange {
  final DateTime start;
  final DateTime end;
  final DateRangePreset preset;

  const DateRange({
    required this.start,
    required this.end,
    this.preset = DateRangePreset.custom,
  });

  bool get isCustom => preset == DateRangePreset.custom;
}
