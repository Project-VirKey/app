import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:virkey/common_widgets/app_button.dart';
import 'package:virkey/common_widgets/app_text.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/default_components.dart';
import 'package:virkey/features/settings/settings_overlay.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  _showSettingsOverlay(BuildContext context) async {
    // https://medium.flutterdevs.com/implemented-overlay-in-flutter-fe60d2b33a04

    OverlayState? homeOverlayState = Overlay.of(context);
    homeOverlayState?.insertAll([settingsOverlay]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: Column(
        children: <Widget>[
          const Center(
            child: AppText(text: 'Home Screen', size: 45),
          ),
          AppButton(
              appText:
                  const AppText(text: 'Piano Screen', color: AppColors.white),
              onPressed: () => context.go('/piano')),
          AppButton(
              appText: const AppText(text: 'Settings Overlay'),
              onPressed: () => _showSettingsOverlay(context)),
          const DefaultComponents()
        ],
      ),
    );
  }
}
