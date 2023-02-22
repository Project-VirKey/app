import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:virkey/common_widgets/app_icon.dart';
import 'package:virkey/common_widgets/app_shadow.dart';
import 'package:virkey/constants/colors.dart';

class AppCheckbox extends StatefulWidget {
  const AppCheckbox({
    Key? key,
    this.value = false,
    required this.onChanged,
  }) : super(key: key);

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  State<AppCheckbox> createState() => _AppCheckBoxState();
}

class _AppCheckBoxState extends State<AppCheckbox> {
  @override
  Widget build(BuildContext context) {
    return AppShadow(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            widget.onChanged(widget.value);
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  border: Border.all(color: AppColors.dark),
                  borderRadius: BorderRadius.circular(100.0),
                ),
              ),
              Visibility(
                visible: widget.value,
                child: const AppIcon(
                  icon: HeroIcons.check,
                  color: AppColors.dark,
                  size: 17.5,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
