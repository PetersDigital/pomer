import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pomer/core/utils/platform_utils.dart';

part 'foreground_service.g.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onDestroy(
    DateTime timestamp,
    bool isServiceExpectedToDestroy,
  ) async {}

  @override
  void onReceiveData(Object data) {}

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
  void Function(String action)? _actionHandler;
  bool _taskDataCallbackRegistered = false;

  void init() {
    if (!PlatformUtils.isAndroid) {
      return;
    }

    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'pomer_foreground_service',
        channelName: 'Foreground Timer Service',
        channelDescription: 'Ongoing notification for Pomer timer',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        visibility: NotificationVisibility.VISIBILITY_PUBLIC,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(15000),
        autoRunOnBoot: false,
        stopWithTask: true,
        allowWakeLock: false,
        allowWifiLock: false,
      ),
    );
  }

  void registerActionCallback(void Function(String action) onAction) {
    if (!PlatformUtils.isAndroid) {
      return;
    }

    _actionHandler = onAction;
    if (_taskDataCallbackRegistered) {
      return;
    }

    _taskDataCallbackRegistered = true;

    FlutterForegroundTask.addTaskDataCallback((data) {
      if (data is String) {
        _actionHandler?.call(data);
        return;
      }

      if (data is Map) {
        final action = data['action'];
        if (action is String) {
          _actionHandler?.call(action);
        }
      }
    });
  }

  Future<void> startService(
    String title,
    String text, {
    bool isPaused = false,
  }) async {
    if (!PlatformUtils.isAndroid) {
      return;
    }

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
      _lastTitle = title;
      _lastText = text;
      _lastIsPaused = isPaused;

      await FlutterForegroundTask.startService(
        notificationTitle: title,
        notificationText: text,
        callback: startCallback,
        notificationButtons: buttons,
      );
    }
  }

  String? _lastTitle;
  String? _lastText;
  bool? _lastIsPaused;

  Future<void> updateService(
    String title,
    String text, {
    bool isPaused = false,
  }) async {
    if (!PlatformUtils.isAndroid) {
      return;
    }

    if (_lastTitle == title && _lastText == text && _lastIsPaused == isPaused) {
      return; // Skip identical updates to prevent flickering lock screens
    }

    _lastTitle = title;
    _lastText = text;
    _lastIsPaused = isPaused;

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
    if (!PlatformUtils.isAndroid) {
      return;
    }

    await FlutterForegroundTask.stopService();
  }
}
