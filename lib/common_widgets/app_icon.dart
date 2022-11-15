import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:virkey/common_widgets/app_shadow.dart';

class AppIcon extends StatelessWidget {
  const AppIcon(
      {Key? key,
      required this.icon,
      this.size = 24,
      required this.color,
      this.onPressed})
      : super(key: key);

  final Object icon;
  final double size;
  final Color color;
  final dynamic onPressed;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onPressed,
        child: AppShadow(
          child: Column(
            children: [
              if (icon is HeroIcons) ...[
                HeroIcon(
                  icon as HeroIcons,
                  color: color,
                  size: size,
                ),
              ] else if (icon is IconData) ...[
                Icon(
                  icon as IconData,
                  color: color,
                  size: size,
                )
              ],
            ],
          ),
        ),
      ),
    );
  }
}
