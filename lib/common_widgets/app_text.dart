import 'package:flutter/material.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/fonts.dart';

class AppText extends StatelessWidget {
  const AppText(
      {Key? key,
      required this.text,
      this.family = AppFonts.primary,
      this.color = AppColors.dark,
      this.size = AppFonts.sizeDefault,
      this.weight = AppFonts.weightRegular})
      : super(key: key);

  final String text;
  final String family;
  final Color color;
  final double size;
  final FontWeight? weight;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
          fontFamily: family,
          color: color,
          fontSize: size,
          fontWeight: weight),
    );
  }
}
