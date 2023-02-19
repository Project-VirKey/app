import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:virkey/common_widgets/app_icon.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/shadows.dart';
import 'package:virkey/utils/platform_helper.dart';
import 'package:virkey/constants/radius.dart';
import 'package:virkey/common_widgets/app_text.dart';

class AppSnackBar {
  final String message;
  final BuildContext context;
  final TickerProvider vsync;

  AppSnackBar({
    required this.message,
    required this.context,
    required this.vsync,
  });

  void close() {
    _animationController.reverse().whenComplete(() => {_overlay.remove()});
  }

  void open() {
    _animationController.addListener(() {
      _overlayState.setState(() {});
    });
    _overlayState.insert(_overlay);
    _animationController.forward();

    Future.delayed(const Duration(seconds: 5), () => close());
  }

  late final OverlayState _overlayState = Overlay.of(context);

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
        alignment: Alignment.bottomCenter,
        child: SafeArea(
          bottom: MediaQuery.of(context).orientation == Orientation.portrait,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero, // goal position
            ).animate(_animationController),
            child: Container(
              // height: 80,
              width: PlatformHelper.isDesktop ? 650 : null,
              margin: const EdgeInsets.all(31),
              decoration: const BoxDecoration(
                color: AppColors.dark,
                borderRadius: BorderRadius.all(AppRadius.radius),
                boxShadow: [AppShadows.boxShadow],
              ),
              child: Padding(
                padding: const EdgeInsets.all(11),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: AppText(
                        text: message,
                        color: AppColors.secondary,
                        size: 20,
                        letterSpacing: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AppIcon(
                      icon: HeroIcons.xMark,
                      color: AppColors.secondary,
                      onPressed: () => close(),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  });
}
