import 'dart:convert';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:csv/csv.dart';
import 'package:pomer/core/providers/database_provider.dart';
import 'package:pomer/features/statistics/providers/date_range_provider.dart';
import 'package:pomer/features/statistics/providers/statistics_provider.dart';

final csvExportServiceProvider = Provider<CsvExportService>((ref) {
  return CsvExportService(ref);
});

class CsvExportService {
  final Ref _ref;

  CsvExportService(this._ref);

  Future<void> exportSessions() async {
    final db = _ref.read(appDatabaseProvider);
    final queryRows = await _ref.read(
      rawSessionsQueryProvider(requireTaskJoin: true).future,
    );
    final dateRange = _ref.read(dateRangeNotifierProvider);

    final List<List<dynamic>> rows = [];
    // Header
    rows.add([
      'ID',
      'Start Time',
      'End Time',
      'Duration (Seconds)',
      'Phase Type',
      'Status',
      'Task ID',
      'Task Title',
      'Task Tag',
    ]);

    for (final row in queryRows) {
      final session = row.readTable(db.sessions);
      final task = row.readTableOrNull(db.tasks);

      rows.add([
        session.id,
        session.startTime.toIso8601String(),
        session.endTime.toIso8601String(),
        session.durationSeconds,
        session.phaseType,
        session.status,
        session.taskId ?? '',
        task?.title ?? '',
        task?.tag ?? '',
      ]);
    }

    final String csv = const CsvEncoder().convert(rows);
    final Uint8List bytes = Uint8List.fromList(utf8.encode(csv));

    final startStr =
        '${dateRange.start.year}-${dateRange.start.month.toString().padLeft(2, '0')}-${dateRange.start.day.toString().padLeft(2, '0')}';
    final endStr =
        '${dateRange.end.year}-${dateRange.end.month.toString().padLeft(2, '0')}-${dateRange.end.day.toString().padLeft(2, '0')}';

    await FileSaver.instance.saveFile(
      name: 'pomer_sessions_${startStr}_to_$endStr.csv',
      bytes: bytes,
      mimeType: MimeType.csv,
    );
  }
}
