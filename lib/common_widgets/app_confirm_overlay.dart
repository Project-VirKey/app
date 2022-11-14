import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:virkey/common_widgets/app_button.dart';
import 'package:virkey/common_widgets/app_keyboard_shortcut.dart';
import 'package:virkey/common_widgets/app_text.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/fonts.dart';
import 'package:virkey/constants/radius.dart';

OverlayEntry confirmOverlay = OverlayEntry(builder: (context) {
  return OrientationBuilder(
    builder: (context, orientation) {
      return AppKeyboardShortcut(
        shortcuts: {
          PhysicalKeyboardKey.escape: () => confirmOverlay.remove(),
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
                    const Expanded(
                        child: AppText(
                            text: 'Delete recording "Recording #3"?',
                            weight: AppFonts.weightMedium,
                            size: 26)),
                    AppButton(
                        appText: const AppText(
                          text: 'Delete',
                          color: AppColors.white,
                          size: 22,
                        ),
                        onPressed: () => {}),
                    AppButton(
                        appText: const AppText(
                          text: 'Cancel',
                          color: AppColors.secondary,
                          size: 22,
                        ),
                        backgroundColor: AppColors.dark,
                        onPressed: () => {})
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  );
});
