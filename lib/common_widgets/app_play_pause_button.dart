import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:virkey/common_widgets/app_icon.dart';

import 'package:virkey/constants/colors.dart';
import 'package:virkey/common_widgets/app_shadow.dart';

class AppPlayPauseButton extends StatefulWidget {
  AppPlayPauseButton({
    Key? key,
    this.value = false,
    required this.onChanged,
  }) : super(key: key);

  bool value;
  final ValueChanged<bool> onChanged;

  @override
  State<AppPlayPauseButton> createState() => _AppPlayPauseButtonState();
}

class _AppPlayPauseButtonState extends State<AppPlayPauseButton> {
  @override
  Widget build(BuildContext context) {
    return AppShadow(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            setState(() {
              widget.value = !widget.value;
              widget.onChanged(widget.value);
            });
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  border: Border.all(color: AppColors.dark),
                  borderRadius: BorderRadius.circular(100.0),
                ),
              ),
              Visibility(
                visible: widget.value,
                child: const AppIcon(
                  icon: HeroIcons.play,
                  color: AppColors.dark,
                  size: 30,
                ),
              ),
              Visibility(
                visible: !widget.value,
                child: const AppIcon(
                  icon: HeroIcons.pause,
                  color: AppColors.dark,
                  size: 30,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
