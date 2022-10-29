import 'package:flutter/material.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/fonts.dart';

class AppText extends StatelessWidget {
  const AppText(
      {Key? key,
      required this.text,
      this.family = AppFonts.primary,
      this.light = false,
      this.color = AppColors.dark,
      this.size = AppFonts.sizeDefault,
      this.weight = AppFonts.weightRegular})
      : super(key: key);

  final String text;
  final String family;
  final bool light;
  final Color color;
  final double size;
  final FontWeight? weight;

  @override
  Widget build(BuildContext context) {
    Color fontColor = light ? AppColors.secondary : color;

    return Text(
      text,
      style: TextStyle(
          fontFamily: family,
          color: fontColor,
          fontSize: size,
          fontWeight: weight),
    );
  }
}
