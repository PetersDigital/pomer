import 'package:flutter/foundation.dart';

/// Utilities for detecting the current runtime platform.
class PlatformUtils {
  PlatformUtils._();

  static bool get isAndroid => defaultTargetPlatform == TargetPlatform.android;
  static bool get isWindows => defaultTargetPlatform == TargetPlatform.windows;
  static bool get isWeb => kIsWeb;

  /// Desktop targets currently supported by Pomer (expand if macOS/Linux added).
  static bool get isDesktop => isWindows;

  /// Mobile targets currently supported by Pomer (expand if iOS added).
  static bool get isMobile => isAndroid;
}
