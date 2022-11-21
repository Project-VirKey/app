import 'package:flutter/material.dart';
import 'package:virkey/common_widgets/app_text.dart';
import 'package:virkey/constants/fonts.dart';

class PropertyDescriptionActionCombination extends StatelessWidget {
  const PropertyDescriptionActionCombination({
    Key? key,
    required this.title,
    required this.child,
    this.onPressed,
  }) : super(key: key);

  final String title;
  final Widget child;
  final dynamic onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: title.isEmpty ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
        children: [
          if (title.isNotEmpty)
            AppText(
              text: title,
              size: 16,
              letterSpacing: 3,
              weight: AppFonts.weightLight,
            ),
          child,
        ],
      ),
    );
  }
}
