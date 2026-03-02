import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'foreground_service.g.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isServiceExpectedToDestroy) async {
  }

  @override
  void onReceiveData(Object data) {
  }

  @override
  void onNotificationButtonPressed(String id) {
    FlutterForegroundTask.sendDataToMain({'action': id});
  }
}

@Riverpod(keepAlive: true)
ForegroundService foregroundService(Ref ref) {
  final service = ForegroundService();
  service.init();
  return service;
}

class ForegroundService {
  void init() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'pomer_foreground_service',
        channelName: 'Foreground Timer Service',
        channelDescription: 'Ongoing notification for Pomer timer',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(1000), // Check events/lifecycle
        autoRunOnBoot: false,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  Future<void> startService(String title, String text, {bool isPaused = false}) async {
    final buttons = [
      if (isPaused)
        const NotificationButton(id: 'resume', text: 'Resume')
      else
        const NotificationButton(id: 'pause', text: 'Pause'),
      const NotificationButton(id: 'skip', text: 'Skip'),
    ];

    if (await FlutterForegroundTask.isRunningService) {
      await updateService(title, text, isPaused: isPaused);
    } else {
      await FlutterForegroundTask.startService(
        notificationTitle: title,
        notificationText: text,
        callback: startCallback,
        notificationButtons: buttons,
      );
    }
  }

  Future<void> updateService(String title, String text, {bool isPaused = false}) async {
    final buttons = [
      if (isPaused)
        const NotificationButton(id: 'resume', text: 'Resume')
      else
        const NotificationButton(id: 'pause', text: 'Pause'),
      const NotificationButton(id: 'skip', text: 'Skip'),
    ];

    await FlutterForegroundTask.updateService(
      notificationTitle: title,
      notificationText: text,
      notificationButtons: buttons,
    );
  }

  Future<void> stopService() async {
    await FlutterForegroundTask.stopService();
  }
}
