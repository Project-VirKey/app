import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
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

class _DefaultComponentsState extends State<DefaultComponents> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppIcon(
            icon: HeroIcons.arrowDownLeft,
            color: AppColors.primary,
            onPressed: () => {print('tt')}),
        AppIcon(
            icon: Icons.record_voice_over_outlined,
            color: AppColors.dark,
            onPressed: () => {}),
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
      ],
    );
  }
}
