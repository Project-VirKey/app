import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:virkey/common_widgets/app_icon.dart';
import 'package:virkey/constants/colors.dart';

class AppPlayPauseButton extends StatelessWidget {
  const AppPlayPauseButton({
    Key? key,
    this.value = false,
    this.light = false,
    required this.onPressed,
  }) : super(key: key);

  final bool value;
  final bool light;
  final dynamic onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onPressed(),
      child: AnimatedCrossFade(
        crossFadeState:
            value ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 150),
        firstChild: AppIcon(
          icon: HeroIcons.play,
          color: light ? AppColors.secondary : AppColors.dark,
          displayShadow: false,
          size: 30,
        ),
        secondChild: AppIcon(
          icon: HeroIcons.pause,
          color: light ? AppColors.secondary : AppColors.dark,
          displayShadow: false,
          size: 30,
        ),
      ),
    );
  }
}
