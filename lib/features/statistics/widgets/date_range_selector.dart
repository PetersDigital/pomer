import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomer/features/statistics/models/date_range.dart';
import 'package:pomer/features/statistics/providers/date_range_provider.dart';

class DateRangeSelector extends ConsumerWidget {
  const DateRangeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateRange = ref.watch(dateRangeNotifierProvider);
    final notifier = ref.read(dateRangeNotifierProvider.notifier);

    return DropdownButton<DateRangePreset>(
      value: dateRange.preset,
      onChanged: (DateRangePreset? newValue) async {
        if (newValue == null) return;

        if (newValue == DateRangePreset.custom) {
          final picked = await showDateRangePicker(
            context: context,
            firstDate: DateTime(2023),
            lastDate: DateTime.now(),
          );
          if (picked != null) {
            notifier.setCustomRange(picked.start, picked.end);
          }
        } else {
          notifier.setPreset(newValue);
        }
      },
      items: DateRangePreset.values
          .map<DropdownMenuItem<DateRangePreset>>((DateRangePreset value) {
        return DropdownMenuItem<DateRangePreset>(
          value: value,
          child: Text(value.label),
        );
      }).toList(),
    );
  }
}
