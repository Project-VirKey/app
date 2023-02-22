import 'package:flutter/material.dart';
import 'package:virkey/common_widgets/app_text.dart';
import 'package:virkey/constants/fonts.dart';

enum PropertyDescriptionActionCombinationType { onlyChild, titleAndChild }

class PropertyDescriptionActionCombination extends StatelessWidget {
  const PropertyDescriptionActionCombination({
    Key? key,
    this.title = '',
    this.child,
    this.type = PropertyDescriptionActionCombinationType.titleAndChild,
  }) : super(key: key);

  final String title;
  final dynamic child;
  final PropertyDescriptionActionCombinationType type;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        mainAxisAlignment:
            type != PropertyDescriptionActionCombinationType.titleAndChild
                ? MainAxisAlignment.center
                : MainAxisAlignment.spaceBetween,
        children: [
          if (type != PropertyDescriptionActionCombinationType.onlyChild)
            Expanded(
              child: ClipRect(
                child: AppText(
                  text: title,
                  weight: AppFonts.weightLight,
                  overflow: TextOverflow.fade,
                ),
              ),
            ),
          child,
        ],
      ),
    );
  }
}
