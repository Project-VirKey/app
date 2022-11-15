import 'package:flutter/material.dart';
import 'package:virkey/common_widgets/app_button.dart';
import 'package:virkey/utils/overlay.dart';
import 'package:virkey/common_widgets/app_text.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/fonts.dart';
import 'package:virkey/utils/platform_helper.dart';

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

  Widget _button(String text, bool blue, dynamic onPressed) {
    return AppButton(
      appText: AppText(
        text: text,
        color: blue ? AppColors.white : AppColors.secondary,
        size: 22,
        letterSpacing: 5,
      ),
      backgroundColor: blue ? null : AppColors.dark,
      onPressed: () => onPressed(),
    );
  }

  late final Widget _confirmButton =
      _button(confirmButtonText, true, onConfirm);
  late final Widget _cancelButton = _button('Cancel', false, close);

  List<Widget> _buttons() {
    if (PlatformHelper.isDesktop) {
      return [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: _confirmButton),
            Expanded(child: _cancelButton),
          ],
        )
      ];
    } else {
      return [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _confirmButton,
            const SizedBox(
              height: 5,
            ),
            _cancelButton,
          ],
        )
      ];
    }
  }

  late final AppOverlay _overlay =
      AppOverlay(context: context, fillDesktopScreen: false, children: [
    Expanded(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: AppText(
            text: displayText,
            weight: AppFonts.weightMedium,
            size: 26,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    )),
    ..._buttons()
  ]);
}
