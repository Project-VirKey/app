import 'package:flutter/foundation.dart';

class PlatformHelper {
  // https://stackoverflow.com/questions/64319073/how-to-know-if-my-flutter-web-app-is-running-on-mobile-or-desktop, 15.11.2022
  static bool isDesktop = defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS;
}
