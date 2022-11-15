import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:virkey/common_widgets/app_keyboard_shortcut.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/radius.dart';

class AppOverlay {
  final BuildContext context;
  final List<Widget> children;

  AppOverlay({required this.context, required this.children});

  void close() {
    _overlay.remove();
  }

  void open() {
    _overlayState?.insert(_overlay);
  }

  OverlayEntry get overlay => _overlay;

  late final OverlayState? _overlayState = Overlay.of(context);

  late final OverlayEntry _overlay = OverlayEntry(builder: (context) {
    return OrientationBuilder(builder: (context, orientation) {
      return AppKeyboardShortcut(
        shortcuts: {
          PhysicalKeyboardKey.escape: () => close(),
        },
        child: Container(
          color: AppColors.black50,
          child: SafeArea(
            bottom: orientation == Orientation.portrait,
            child: Container(
              margin: const EdgeInsets.all(11),
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.all(AppRadius.radius),
              ),
              child: Padding(
                padding: const EdgeInsets.all(11),
                child: Column(
                  children: children,
                ),
              ),
            ),
          ),
        ),
      );
    });
  });
}
