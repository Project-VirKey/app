import 'package:flutter/material.dart';
import 'package:virkey/common_widgets/app_text.dart';

class PropertiesDescriptionTitle extends StatelessWidget {
  const PropertiesDescriptionTitle({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 9),
      child: AppText(
        text: title,
        size: 16,
        letterSpacing: 3,
        textAlign: TextAlign.center,
      ),
    );
  }
}
