import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:virkey/common_widgets/app_shadow.dart';

class AppIcon extends StatelessWidget {
  const AppIcon(
      {Key? key,
      required this.icon,
      this.size = 24,
      required this.color,
      this.displayShadow = true,
      this.onPressed})
      : super(key: key);

  final Object icon;
  final double size;
  final Color color;
  final bool displayShadow;
  final dynamic onPressed;

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = (icon is HeroIcons)
        ? HeroIcon(
            icon as HeroIcons,
            color: color,
            size: size,
          )
        : (icon is IconData)
            ? Icon(
                icon as IconData,
                color: color,
                size: size,
              )
            : Container();

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
          onTap: onPressed,
          child: displayShadow
              ? AppShadow(child: iconWidget)
              : Container(child: iconWidget)),
    );
  }
}
