import 'package:flutter/material.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/fonts.dart';

class AppText extends StatelessWidget {
  const AppText({
    Key? key,
    required this.text,
    this.family = AppFonts.primary,
    this.color = AppColors.dark,
    this.size = AppFonts.sizeDefault,
    this.weight = AppFonts.weightRegular,
    this.letterSpacing = 0,
    this.textAlign = TextAlign.left,
    this.shadows = const [],
  }) : super(key: key);

  final String text;
  final String family;
  final Color color;
  final double size;
  final FontWeight? weight;
  final double? letterSpacing;
  final TextAlign textAlign;
  final List<Shadow> shadows;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      // overflow ellipsis does not work
      // https://www.kindacode.com/article/text-overflow-in-flutter/#TextOverflowellipsis
      // overflow: TextOverflow.ellipsis,
      // softWrap: false,
      style: TextStyle(
        fontFamily: family,
        color: color,
        fontSize: size,
        fontWeight: weight,
        letterSpacing: letterSpacing,
        decoration: TextDecoration.none,
        shadows: shadows,
      ),
    );
  }
}
