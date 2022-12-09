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
  final String additionalText;
  final String confirmButtonText;
  final dynamic onConfirm;
  final TickerProvider vsync;

  AppConfirmOverlay({
    required this.context,
    required this.displayText,
    this.additionalText = '',
    required this.confirmButtonText,
    required this.onConfirm,
    required this.vsync,
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
      _button(confirmButtonText, true, () {
        onConfirm();
        close();
      });
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

  late final AppOverlay _overlay = AppOverlay(
      context: context,
      vsync: vsync,
      fillDesktopScreen: false,
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: Padding(
            padding: const EdgeInsets.all(11),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.05),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppText(
                        text: displayText,
                        weight: AppFonts.weightMedium,
                        size: 26,
                        height: 1.5,
                        textAlign: TextAlign.center,
                      ),
                      if (additionalText.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: AppText(
                            text: additionalText,
                            weight: AppFonts.weightMedium,
                            size: 16,
                            height: 1.6,
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(11),
          child: Column(
            children: [..._buttons()],
          ),
        )
      ]);
}
