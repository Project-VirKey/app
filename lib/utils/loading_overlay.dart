import 'package:flutter/material.dart';
import 'package:virkey/common_widgets/app_text.dart';
import 'package:virkey/constants/colors.dart';

class AppLoadingOverlay {
  final BuildContext context;
  final TickerProvider vsync;

  AppLoadingOverlay({
    required this.context,
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

  late final OverlayEntry _overlay = OverlayEntry(builder: (context) {
    return Opacity(
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
            child: Column(
              children: const [AppText(text: 'Loading')],
            ),
          ),
        ),
      ),
    );
  });
}
