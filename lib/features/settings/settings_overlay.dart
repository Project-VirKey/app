import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:virkey/common_widgets/app_icon.dart';
import 'package:virkey/utils/overlay.dart';
import 'package:virkey/common_widgets/app_text.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/fonts.dart';

class SettingsOverlay {
  final BuildContext context;

  SettingsOverlay({required this.context});

  void close() {
    _overlay.close();
  }

  void open() {
    _overlay.open();
  }

  late final AppOverlay _overlay = AppOverlay(context: context, children: [
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
                    text: 'Settings', size: 30, family: AppFonts.secondary),
              )),
          Positioned(
            left: 0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: AppIcon(
                  icon: HeroIcons.arrowUturnLeft,
                  color: AppColors.dark,
                  onPressed: () => close()),
            ),
          ),
        ],
      ),
    )
  ]);
}
