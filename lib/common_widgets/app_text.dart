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
    this.height = 1,
    this.letterSpacing = 3,
    this.textAlign = TextAlign.left,
    this.shadows = const [],
    this.overflow,
  }) : super(key: key);

  final String text;
  final String family;
  final Color color;
  final double size;
  final FontWeight? weight;
  final double height;
  final double? letterSpacing;
  final TextAlign textAlign;
  final List<Shadow> shadows;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      // https://www.kindacode.com/article/text-overflow-in-flutter/#TextOverflowellipsis
      // https://stackoverflow.com/a/58470417/17399214 -> for overflow inside of Row, put AppText inside of Expanded-Widget
      overflow: overflow,
      style: TextStyle(
        height: height,
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
