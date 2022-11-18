import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:virkey/common_widgets/app_checkbox.dart';
import 'package:virkey/utils/audio_player.dart';
import 'package:virkey/utils/confirm_overlay.dart';
import 'package:virkey/common_widgets/app_slider.dart';
import 'package:virkey/common_widgets/app_switch.dart';
import 'package:virkey/common_widgets/app_text.dart';
import 'package:virkey/common_widgets/app_button.dart';

import 'package:virkey/common_widgets/app_icon.dart';
import 'package:virkey/common_widgets/app_shadow.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/fonts.dart';

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
    AppConfirmOverlay appConfirmOverlayExample = AppConfirmOverlay(
      context: context,
      vsync: this,
      displayText: 'Delete recording "Recording #3"?',
      confirmButtonText: 'Delete',
      onConfirm: () => {print('Delete recording 1')},
    );

    return Column(
      children: [
        AppIcon(
            icon: HeroIcons.arrowDownLeft,
            color: AppColors.primary,
            onPressed: () => {print('tt')}),
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
        AppSwitch(value: enable, onChanged: (bool val) => {print(val)}),
        AppSlider(
          onChanged: (double value) => {print(value)},
        ),
        AppButton(
          appText: const AppText(text: 'Confirm Overlay'),
          onPressed: () => appConfirmOverlayExample.open(),
        ),
        AppCheckbox(onChanged: (bool val) => {print(val)}),
        const AppAudioPlayer()
      ],
    );
  }
}
