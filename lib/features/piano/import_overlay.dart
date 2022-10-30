import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:virkey/common_widgets/app_icon.dart';
import 'package:virkey/common_widgets/app_text.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/radius.dart';

OverlayEntry importOverlay = OverlayEntry(builder: (context) {
  return Container(
    color: AppColors.black50,
    child: Container(
        margin: const EdgeInsets.all(11),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.all(AppRadius.radius),
        ),
        child: Column(
          children: [
            Row(
              children: [
                AppIcon(
                    icon: HeroIcons.arrowUturnLeft,
                    color: AppColors.dark,
                    onPressed: () => importOverlay.remove()),
                const AppText(text: 'Import', size: 30),
              ],
            )
          ],
        )),
  );
});
