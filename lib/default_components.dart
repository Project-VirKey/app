import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:virkey/common_widgets/app_button.dart';
import 'package:virkey/common_widgets/app_checkbox.dart';
import 'package:virkey/common_widgets/app_icon.dart';
import 'package:virkey/common_widgets/app_shadow.dart';
import 'package:virkey/common_widgets/app_slider.dart';
import 'package:virkey/common_widgets/app_switch.dart';
import 'package:virkey/common_widgets/app_text.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/fonts.dart';
import 'package:virkey/utils/confirm_overlay.dart';

class DefaultComponents extends StatefulWidget {
  const DefaultComponents({Key? key}) : super(key: key);

  @override
  State<DefaultComponents> createState() => _DefaultComponentsState();
}

class _DefaultComponentsState extends State<DefaultComponents>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    bool enable = true;

    return Column(
      children: [
        AppIcon(
            icon: HeroIcons.arrowDownLeft,
            color: AppColors.primary,
            onPressed: () => {}),
        const AppIcon(
          icon: Icons.record_voice_over_outlined,
          color: AppColors.dark,
        ),
        const AppShadow(child: Text('Test Shadow')),
        AppButton(
            appText: const AppText(
              text: 'Delete',
              color: AppColors.white,
            ),
            onPressed: () => {}),
        AppButton(
            appText: const AppText(text: 'Cancel', color: AppColors.secondary),
            onPressed: () => {},
            backgroundColor: AppColors.dark),
        const AppText(text: 'Hallo'),
        const AppText(
            text: 'Hallo',
            color: AppColors.secondary,
            weight: AppFonts.weightMedium,
            size: 30),
        AppSwitch(value: enable, onChanged: (bool value) => {}),
        AppSlider(
          onChanged: (double value) => {},
        ),
        AppButton(
          appText: const AppText(text: 'Confirm Overlay'),
          onPressed: () => AppConfirmOverlay(
              vsync: this,
              context: context,
              displayText: 'Delete recording "Recording #3"?',
              confirmButtonText: 'Delete',
              onConfirm: () => {}).open(),
        ),
        AppCheckbox(onChanged: (bool value) => {}),
      ],
    );
  }
}
