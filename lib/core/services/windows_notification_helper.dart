import 'package:local_notifier/local_notifier.dart';

Future<void> initWindowsNotifications() async {
  await localNotifier.setup(
    appName: 'Pomer',
    shortcutPolicy: ShortcutPolicy.requireCreate,
  );
}

Future<void> showWindowsNotification({
  required String title,
  required String body,
}) async {
  final LocalNotification notification = LocalNotification(
    title: title,
    body: body,
  );
  await notification.show();
}
