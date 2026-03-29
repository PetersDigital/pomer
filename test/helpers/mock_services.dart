import 'package:mockito/annotations.dart';
import 'package:pomer/core/services/audio_service.dart';
import 'package:pomer/core/services/notification_service.dart';
import 'package:pomer/core/services/foreground_service.dart';
import 'package:pomer/features/statistics/services/csv_export_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

@GenerateNiceMocks([
  MockSpec<AudioService>(),
  MockSpec<NotificationService>(),
  MockSpec<ForegroundService>(),
  MockSpec<CsvExportService>(),
  MockSpec<SharedPreferencesAsync>(),
])
void main() {}
