import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:virkey/common_widgets/app_icon.dart';

import 'package:virkey/constants/colors.dart';

class AppPlayPauseButton extends StatefulWidget {
   AppPlayPauseButton({
    Key? key,
    this.value = false,
    this.light = false,
    required this.onPressed,
  }) : super(key: key);

  bool value;
  bool light;
  final dynamic onPressed;

  @override
  State<AppPlayPauseButton> createState() => _AppPlayPauseButtonState();
}

class _AppPlayPauseButtonState extends State<AppPlayPauseButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onPressed(),
      child: AnimatedCrossFade(
        crossFadeState:
            widget.value ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 150),
        firstChild: AppIcon(
          icon: HeroIcons.play,
          color: widget.light ? AppColors.secondary : AppColors.dark,
          displayShadow: false,
          size: 30,
        ),
        secondChild: AppIcon(
          icon: HeroIcons.pause,
          color: widget.light ? AppColors.secondary : AppColors.dark,
          displayShadow: false,
          size: 30,
        ),
      ),
    );
  }
}
