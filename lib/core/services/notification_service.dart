import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pomer/core/utils/platform_utils.dart';
import 'package:pomer/core/services/web_notification_helper.dart';

part 'notification_service.g.dart';

@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) {
  return NotificationService();
}

class NotificationService {
  static const String _androidChannelIdSilent = 'pomer_timer_channel_silent';
  static const String _androidChannelIdSound = 'pomer_timer_channel_sound';

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  late final Future<void> _initFuture;
  DateTime? _lastNotificationTimestamp;
  int? _lastNotificationId;
  String? _lastNotificationTitle;
  String? _lastNotificationBody;

  static const Duration _duplicateWindow = Duration(seconds: 3);

  NotificationService() {
    _initFuture = _init();
  }

  Future<void> _init() async {
    if (PlatformUtils.isWeb) {
      return;
    }

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
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    try {
      await _flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (details) {},
      );

      await requestPermissions();
    } catch (_) {
      // Ignore when platform implementation is unavailable (e.g. widget tests).
    }
  }

  Future<void> requestPermissions() async {
    if (PlatformUtils.isWeb) {
      await requestWebNotificationPermission();
      return;
    }

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
    bool playSound = false,
  }) async {
    if (PlatformUtils.isWeb) {
      await showWebNotification(title: title, body: body);
      return;
    }

    await _initFuture;

    final now = DateTime.now();
    final isDuplicateNotification = _lastNotificationTimestamp != null &&
        _lastNotificationId == id &&
        _lastNotificationTitle == title &&
        _lastNotificationBody == body &&
        now.difference(_lastNotificationTimestamp!) < _duplicateWindow;

    if (isDuplicateNotification) {
      return;
    }

    final androidNotificationDetails = AndroidNotificationDetails(
      playSound ? _androidChannelIdSound : _androidChannelIdSilent,
      'Pomer Timer',
      channelDescription: 'Notifications for Pomodoro timer phases',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      playSound: playSound,
      onlyAlertOnce: true,
    );

    final darwinNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: playSound,
    );

    final notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      macOS:
          darwinNotificationDetails, // Adds support for Windows/macOS if applicable
      linux: null, // Depending on plugin support
    );

    try {
      await _flutterLocalNotificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
      );
      _lastNotificationTimestamp = now;
      _lastNotificationId = id;
      _lastNotificationTitle = title;
      _lastNotificationBody = body;
    } catch (_) {
      // Ignore unsupported platform plugin calls.
    }
  }

  Future<void> cancelNotification(int id) async {
    if (PlatformUtils.isWeb) {
      return;
    }

    await _initFuture;
    try {
      await _flutterLocalNotificationsPlugin.cancel(id: id);
    } catch (_) {
      // Ignore unsupported platform plugin calls.
    }
  }

  Future<void> cancelAllNotifications() async {
    if (PlatformUtils.isWeb) {
      return;
    }

    await _initFuture;
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
    } catch (_) {
      // Ignore unsupported platform plugin calls.
    }
  }
}
