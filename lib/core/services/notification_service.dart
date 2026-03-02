import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_service.g.dart';

@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) {
  return NotificationService();
}

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  late final Future<void> _initFuture;

  NotificationService() {
    _initFuture = _init();
  }

  Future<void> _init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Currently no iOS/macOS support planned, but this satisfies the config
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    // flutter_local_notifications recently added Windows/Linux settings via respective packages if needed,
    // but the plugin currently defaults to basic platform implementations if unconfigured.
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
    );

    await requestPermissions();
  }

  Future<void> requestPermissions() async {
    // Permission handler handles mostly mobile. On windows/web this may no-op or throw, so catch it.
    try {
      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }
    } catch (e) {
      // Ignored for platforms where Permission.notification is not implemented (e.g. some Desktop/Web)
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await _initFuture;

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'pomer_timer_channel',
      'Pomer Timer',
      channelDescription: 'Notifications for Pomodoro timer phases',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      macOS: darwinNotificationDetails, // Adds support for Windows/macOS if applicable
      linux: null, // Depending on plugin support
    );

    await _flutterLocalNotificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
    );
  }
}
