import 'dart:html' as html;

Future<void> requestWebNotificationPermissionImpl() async {
  if (!html.Notification.supported) {
    return;
  }

  if (html.Notification.permission != 'granted') {
    await html.Notification.requestPermission();
  }
}

Future<void> showWebNotificationImpl({
  required String title,
  required String body,
}) async {
  if (!html.Notification.supported) {
    return;
  }

  if (html.Notification.permission != 'granted') {
    final permission = await html.Notification.requestPermission();
    if (permission != 'granted') {
      return;
    }
  }

  html.Notification(title, body: body);
}
