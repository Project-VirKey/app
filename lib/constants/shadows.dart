import 'package:flutter/material.dart';
import 'package:virkey/constants/colors.dart';

class AppShadows {
  static const Shadow title =
      Shadow(blurRadius: 6, color: Color(0x1F000000), offset: Offset(6, 6));
  static const Shadow text =
      Shadow(blurRadius: 6, color: Color(0x1F000000), offset: Offset(6, 6));
  static const BoxShadow boxShadow = BoxShadow(
      // color: AppColors.shadow, blurRadius: 0, offset: Offset(4, 4)),
      // color: AppColors.shadow, blurRadius: 8, offset: Offset(4, 4)),
      color: AppColors.shadow,
      blurRadius: 8,
      offset: Offset(4, 4));
}
