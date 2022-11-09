import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heroicons/heroicons.dart';
import 'package:virkey/common_widgets/app_icon.dart';
import 'package:virkey/common_widgets/app_text.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/fonts.dart';
import 'package:virkey/constants/radius.dart';

OverlayEntry settingsOverlay = OverlayEntry(builder: (context) {
  // https://api.flutter.dev/flutter/services/PhysicalKeyboardKey-class.html
  final FocusNode focusNode = FocusNode();
  FocusScope.of(context).requestFocus(focusNode);

  return Focus(
    autofocus: true,
    focusNode: focusNode,
    onKey: (FocusNode node, RawKeyEvent event) {
      if (event.physicalKey == PhysicalKeyboardKey.escape) {
        settingsOverlay.remove();
      }

      return event.physicalKey == PhysicalKeyboardKey.escape
          ? KeyEventResult.handled
          : KeyEventResult.ignored;
    },
    child: Container(
      color: AppColors.black50,
      child: Container(
        margin: const EdgeInsets.all(11),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.all(AppRadius.radius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(11),
          child: Column(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 40,
                child: Stack(
                  children: [
                    const Positioned.fill(
                        left: 0,
                        right: 0,
                        child: Center(
                          child: AppText(
                              text: 'Settings',
                              size: 30,
                              family: AppFonts.secondary),
                        )),
                    Positioned(
                      left: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: AppIcon(
                            icon: HeroIcons.arrowUturnLeft,
                            color: AppColors.dark,
                            onPressed: () => settingsOverlay.remove()),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    ),
  );
});
