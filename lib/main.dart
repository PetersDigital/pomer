import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:pomer/core/utils/platform_utils.dart';

import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (PlatformUtils.isAndroid) {
    FlutterForegroundTask.initCommunicationPort();
  }

  // Draw behind the system bars and make them transparent
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  runApp(const ProviderScope(child: App()));
}
