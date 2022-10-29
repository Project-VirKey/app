import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:virkey/common_widgets/app_button.dart';
import 'package:virkey/common_widgets/app_text.dart';
import 'package:virkey/default_components.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        AppButton(
            appText: const AppText(text: 'Piano Screen'),
            onPressed: () => context.go('/piano')),
        const Center(
          child: AppText(text: 'Home Screen'),
        ),
        const DefaultComponents()
      ],
    );
  }
}
