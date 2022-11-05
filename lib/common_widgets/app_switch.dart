import 'package:flutter/material.dart';

import 'package:virkey/constants/colors.dart';
import 'package:virkey/common_widgets/app_shadow.dart';

class AppSwitch extends StatefulWidget {
  AppSwitch({
    super.key,
    this.value = false,
    required this.onChanged,
  });

  bool value;
  final ValueChanged<bool> onChanged;

  @override
  State<AppSwitch> createState() => _AppSwitchState();
}

class _AppSwitchState extends State<AppSwitch> {
  Alignment switchControlAlignment = Alignment.centerLeft;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        child: Stack(
          children: <Widget>[
            Positioned(
                child: Container(
              margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
              width: 40,
              height: 15,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50.0),
                color: widget.value ? AppColors.primary : AppColors.tertiary,
              ),
            )),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.decelerate,
              width: 40,
              height: 25,
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                alignment:
                    widget.value ? Alignment.centerRight : Alignment.centerLeft,
                curve: Curves.decelerate,
                child: AppShadow(
                  child: Container(
                    width: 25,
                    height: 25,
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
