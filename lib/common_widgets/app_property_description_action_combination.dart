import 'package:flutter/material.dart';
import 'package:virkey/common_widgets/app_text.dart';
import 'package:virkey/constants/fonts.dart';

class PropertyDescriptionActionCombination extends StatelessWidget {
  const PropertyDescriptionActionCombination({
    Key? key,
    required this.title,
    required this.child,
  }) : super(key: key);

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    bool emptyChild =
        child is Container && ((child as Container).child == null);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: title.isEmpty || emptyChild
            ? MainAxisAlignment.center
            : MainAxisAlignment.spaceBetween,
        children: [
          if (title.isNotEmpty)
            AppText(
              text: title,
              size: 16,
              letterSpacing: 3,
              weight: AppFonts.weightLight,
            ),
          if (!emptyChild) child,
        ],
      ),
    );
  }
}
