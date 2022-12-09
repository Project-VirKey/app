import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:virkey/common_widgets/app_keyboard_shortcut.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/radius.dart';
import 'package:virkey/utils/platform_helper.dart';

class AppOverlay {
  final BuildContext context;
  final bool fillDesktopScreen;
  final List<Widget> children;
  final TickerProvider vsync;

  AppOverlay({
    required this.context,
    this.fillDesktopScreen = true,
    required this.children,
    required this.vsync,
  });

  void close() {
    _animationController.reverse().whenComplete(() => {_overlay.remove()});
  }

  void open() {
    _animationController.addListener(() {
      _overlayState?.setState(() {});
    });
    _overlayState?.insert(_overlay);
    _animationController.forward();
  }

  late final OverlayState? _overlayState = Overlay.of(context);

  late final AnimationController _animationController = AnimationController(
    vsync: vsync,
    duration: const Duration(milliseconds: 150),
  );
  late final Animation<double> _animation =
      Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);

  final FocusNode _focusNode = FocusNode();

  late final OverlayEntry _overlay = OverlayEntry(builder: (context) {
    return AppKeyboardShortcut(
      focusNode: _focusNode,
      shortcuts: {
        PhysicalKeyboardKey.escape: () => close(),
      },
      child: Opacity(
        opacity: _animation.value,
        child: Container(
          alignment: Alignment.center,
          color: AppColors.black50,
          child: SafeArea(
            bottom: MediaQuery.of(context).orientation == Orientation.portrait,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                // starting position (x, y) -> y = 1 -> bottom
                end: Offset.zero, // goal position
              ).animate(_animationController),
              child: Container(
                height:
                    !fillDesktopScreen && PlatformHelper.isDesktop ? 300 : null,
                width:
                    !fillDesktopScreen && PlatformHelper.isDesktop ? 650 : null,
                margin: const EdgeInsets.all(11),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.all(AppRadius.radius),
                ),
                child: Column(
                  children: children,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  });
}
