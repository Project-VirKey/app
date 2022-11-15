import 'package:flutter/material.dart';
import 'package:virkey/common_widgets/app_button.dart';
import 'package:virkey/common_widgets/app_overlay.dart';
import 'package:virkey/common_widgets/app_text.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/fonts.dart';

class AppConfirmOverlay {
  final BuildContext context;
  final String displayText;
  final String confirmButtonText;
  final dynamic onConfirm;

  AppConfirmOverlay({
    required this.context,
    required this.displayText,
    required this.confirmButtonText,
    required this.onConfirm,
  });

  void close() {
    _overlay.close();
  }

  void open() {
    _overlay.open();
  }

  late final AppOverlay _overlay = AppOverlay(context: context, children: [
    Expanded(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppText(
          text: displayText,
          weight: AppFonts.weightMedium,
          size: 26,
          textAlign: TextAlign.center,
        ),
      ],
    )),
    Row(
      children: [
        Flexible(
          fit: FlexFit.tight,
          child: AppButton(
            appText: AppText(
              text: confirmButtonText,
              color: AppColors.white,
              size: 22,
              letterSpacing: 5,
            ),
            onPressed: () => onConfirm(),
          ),
        ),
      ],
    ),
    const SizedBox(
      height: 5,
    ),
    Row(
      children: [
        Flexible(
          fit: FlexFit.tight,
          child: AppButton(
            appText: const AppText(
              text: 'Cancel',
              color: AppColors.secondary,
              size: 22,
              letterSpacing: 5,
            ),
            backgroundColor: AppColors.dark,
            onPressed: () => close(),
          ),
        ),
      ],
    )
  ]);
}
