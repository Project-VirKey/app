import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:virkey/common_widgets/app_icon.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/utils/overlay.dart';

class AppTextFieldOverlay {
  final BuildContext context;
  final String value;
  final dynamic onConfirm;
  final TickerProvider vsync;

  AppTextFieldOverlay({
    required this.context,
    required this.value,
    required this.onConfirm,
    required this.vsync,
  });

  void close() {
    _overlay.close();
  }

  void open() {
    _overlay.open();
  }

  // FocusScope.of(context).requestFocus(_focusNode);

  late final AppOverlay _overlay = AppOverlay(
      context: context,
      vsync: vsync,
      fillDesktopScreen: false,
      children: [
        Row(
          children: [
            Material(
              color: Colors.transparent,
              child: TextFormField(
                focusNode: FocusNode(),
                autofocus: true,
                initialValue: value,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                ),
              ),
            ),
            AppIcon(
              icon: HeroIcons.check,
              color: AppColors.dark,
              onPressed: () => {},
            )
          ],
        ),
      ]);
}
