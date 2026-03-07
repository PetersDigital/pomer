import 'dart:js_interop';

import 'package:web/web.dart' as web;

bool _isNotificationSupported() {
  try {
    web.Notification.permission;
    return true;
  } on Object {
    return false;
  }
}

Future<void> requestWebNotificationPermissionImpl() async {
  if (!_isNotificationSupported()) {
    return;
  }

  if (web.Notification.permission.toString() != 'granted') {
    await web.Notification.requestPermission().toDart;
  }
}

Future<void> showWebNotificationImpl({
  required String title,
  required String body,
}) async {
  if (!_isNotificationSupported()) {
    return;
  }

  if (web.Notification.permission.toString() != 'granted') {
    final result = await web.Notification.requestPermission().toDart;
    if (result.toString() != 'granted') {
      return;
    }
  }

  web.Notification(title, web.NotificationOptions(body: body));
}
