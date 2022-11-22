import 'package:flutter/material.dart';

import 'package:virkey/constants/colors.dart';
import 'package:virkey/common_widgets/app_shadow.dart';

class AppSwitch extends StatefulWidget {
  AppSwitch({
    Key? key,
    this.value = false,
    required this.onChanged,
  }) : super(key: key);

  bool value;
  final ValueChanged<bool> onChanged;

  @override
  State<AppSwitch> createState() => _AppSwitchState();
}

class _AppSwitchState extends State<AppSwitch> {
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        child: Stack(
          children: <Widget>[
            Positioned(
                child: Container(
              margin: const EdgeInsets.symmetric(vertical: 2.5),
              width: 35,
              height: 15,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50.0),
                color: widget.value ? AppColors.primary : AppColors.tertiary,
              ),
            )),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.decelerate,
              width: 35,
              height: 20,
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 150),
                alignment:
                    widget.value ? Alignment.centerRight : Alignment.centerLeft,
                curve: Curves.decelerate,
                child: AppShadow(
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      border: Border.all(color: AppColors.dark),
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          setState(() {
            widget.value = !widget.value;
            widget.onChanged(widget.value);
          });
        },
      ),
    );
  }
}
