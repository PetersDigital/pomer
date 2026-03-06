import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pomer/core/utils/platform_utils.dart';
import 'package:pomer/core/services/web_notification_helper.dart';
import 'package:pomer/core/services/windows_notification_helper.dart';

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
  int _notificationCounter = 1000;

  static const Duration _duplicateWindow = Duration(seconds: 3);

  NotificationService() {
    _initFuture = _init();
  }

  Future<void> _init() async {
    if (PlatformUtils.isWeb) {
      return;
    }

    if (PlatformUtils.isWindows) {
      await initWindowsNotifications();
      return;
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

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

    try {
      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }
    } catch (e) {
      // Ignore unsupported platform permission checks
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

    if (PlatformUtils.isWindows) {
      await _initFuture;
      await showWindowsNotification(title: title, body: body);
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

    final normalizedBody = body.isEmpty ? 'Phase completed' : body;
    // Generate a unique ID to ensure consecutive push notifications actually appear on Android
    final effectiveId = _nextNotificationId();

    final androidNotificationDetails = AndroidNotificationDetails(
      playSound ? _androidChannelIdSound : _androidChannelIdSilent,
      'Pomer Timer',
      channelDescription: 'Notifications for Pomodoro timer phases',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      playSound: playSound,
      onlyAlertOnce: true,
      visibility: NotificationVisibility.public,
    );

    final darwinNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: playSound,
    );

    final notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
      macOS: darwinNotificationDetails,
      linux: null,
    );

    try {
      await _flutterLocalNotificationsPlugin.show(
        id: effectiveId,
        title: title,
        body: normalizedBody,
        notificationDetails: notificationDetails,
      );
      _lastNotificationTimestamp = now;
      _lastNotificationId = id;
      _lastNotificationTitle = title;
      _lastNotificationBody = normalizedBody;
    } catch (_) {
      // Ignore unsupported platform plugin calls.
    }
  }

  Future<void> cancelNotification(int id) async {
    if (PlatformUtils.isWeb) {
      return;
    }

    if (PlatformUtils.isWindows) {
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

    if (PlatformUtils.isWindows) {
      return;
    }

    await _initFuture;
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
    } catch (_) {
      // Ignore unsupported platform plugin calls.
    }
  }

  int _nextNotificationId() {
    _notificationCounter++;
    if (_notificationCounter >= 100000) {
      _notificationCounter = 1000;
    }
    return _notificationCounter;
  }
}
