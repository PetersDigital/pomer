import 'package:pomer/core/services/web_notification_stub.dart'
    if (dart.library.js_interop) 'package:pomer/core/services/web_notification_wasm.dart';

Future<void> requestWebNotificationPermission() {
  return requestWebNotificationPermissionImpl();
}

Future<void> showWebNotification({
  required String title,
  required String body,
}) {
  return showWebNotificationImpl(title: title, body: body);
}
