import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomer/features/timer/screens/timer_screen.dart';
import 'package:pomer/database/database.dart';
import 'package:pomer/core/providers/active_task_provider.dart';
import 'package:pomer/core/providers/database_provider.dart';
import 'package:pomer/core/services/audio_service.dart';
import 'package:pomer/core/services/foreground_service.dart';
import 'package:pomer/core/services/notification_service.dart';
import 'package:drift/drift.dart' as drift;

import '../../helpers/test_helpers.dart';
import '../../helpers/mock_services.mocks.dart';

import 'package:flutter/services.dart';

void main() {
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter.baseflow.com/permissions/methods'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'checkPermissionStatus') {
          return 1; // 1 = granted in permission_handler
        }
        return null;
      },
    );
  });

  testWidgets('TimerScreen displays active task and toggles play/pause', (tester) async {
    final mockAudioService = MockAudioService();
    final mockNotificationService = MockNotificationService();
    final mockForegroundService = MockForegroundService();

    final testTask = Task(
      id: 'mock-id',
      title: 'Mock Active Task',
      tag: 'Mock Tag',
      isCompleted: false,
      createdAt: DateTime.now(),
    );

    final container = createTestContainer(
      overrides: [
        audioServiceProvider.overrideWithValue(mockAudioService),
        notificationServiceProvider.overrideWithValue(mockNotificationService),
        foregroundServiceProvider.overrideWithValue(mockForegroundService),
      ],
    );

    // Need to pre-populate the database so taskListProvider returns the task for the DropdownMenu
    final db = container.read(appDatabaseProvider);
    await db.into(db.tasks).insert(TasksCompanion.insert(
          id: drift.Value(testTask.id),
          title: testTask.title,
        ));

    // Provide the testTask directly to the provider container state before pumping UI
    container.read(activeTaskProvider.notifier).setActiveTask(testTask);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: TimerScreen(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Active Task is displayed (in the DropdownMenu)
    expect(find.text('Mock Active Task'), findsWidgets);

    // Initial state: Play button visible
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    expect(find.byIcon(Icons.pause), findsNothing);

    // Tap Play (it's part of a button containing 'Start')
    final startButton = find.text('Start');
    expect(startButton, findsOneWidget);

    // Using runAsync since TimerNotifier uses genuine timers and permissions
    await tester.runAsync(() async {
      await tester.tap(startButton);
      // Wait for timers to start
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump();

    // After Play, Pause button is visible
    expect(find.byIcon(Icons.pause), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsNothing);

    // Stop timer to clean up async tasks
    await tester.runAsync(() async {
      await tester.tap(find.byIcon(Icons.pause));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
  });
}
