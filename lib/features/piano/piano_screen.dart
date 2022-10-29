import 'package:flutter/material.dart';
import 'package:virkey/common_widgets/app_text.dart';

class PianoScreen extends StatelessWidget {
  const PianoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: AppText(text: 'Piano Screen'),
    );
  }
}
