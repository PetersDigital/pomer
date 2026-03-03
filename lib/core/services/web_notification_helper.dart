import 'package:pomer/core/services/web_notification_stub.dart'
    if (dart.library.html) 'package:pomer/core/services/web_notification_web.dart';

Future<void> requestWebNotificationPermission() {
  return requestWebNotificationPermissionImpl();
}

Future<void> showWebNotification({
  required String title,
  required String body,
}) {
  return showWebNotificationImpl(title: title, body: body);
}
