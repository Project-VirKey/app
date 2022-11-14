import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heroicons/heroicons.dart';
import 'package:virkey/common_widgets/app_icon.dart';
import 'package:virkey/common_widgets/app_keyboard_shortcut.dart';
import 'package:virkey/common_widgets/app_text.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/fonts.dart';
import 'package:virkey/constants/radius.dart';

OverlayEntry importOverlay = OverlayEntry(builder: (context) {
  return OrientationBuilder(builder: (context, orientation) {
    return AppKeyboardShortcut(
      shortcuts: {
        PhysicalKeyboardKey.escape: () => importOverlay.remove(),
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
                                  text: 'Import',
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
                                onPressed: () => importOverlay.remove()),
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
      ),
    );
  });
});
