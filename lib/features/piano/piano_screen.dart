import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';
import 'package:virkey/common_widgets/app_button.dart';
import 'package:virkey/common_widgets/app_text.dart';
import 'package:virkey/common_widgets/app_icon.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/fonts.dart';
import 'package:virkey/features/piano/import_overlay.dart';
import 'package:virkey/features/settings/settings_overlay.dart';

class PianoScreen extends StatefulWidget {
  const PianoScreen({Key? key}) : super(key: key);

  @override
  State<PianoScreen> createState() => _PianoScreenState();
}

class _PianoScreenState extends State<PianoScreen> {
  @override
  Widget build(BuildContext context) {
    OverlayState? pianoOverlayState = Overlay.of(context);

    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: Center(
        child: Column(
          children: [
            Container(
              color: AppColors.dark,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 11, horizontal: 11),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        AppIcon(
                          icon: HeroIcons.arrowUturnLeft,
                          color: AppColors.secondary,
                          onPressed: () => context.go('/'),
                          size: 30,
                        ),
                        AppIcon(
                          icon: HeroIcons.arrowDownTray,
                          color: AppColors.secondary,
                          onPressed: () => {},
                          size: 30,
                        ),
                        AppIcon(
                          icon: HeroIcons.cog6Tooth,
                          color: AppColors.secondary,
                          onPressed: () =>
                              pianoOverlayState?.insert(settingsOverlay),
                          size: 30,
                        ),
                      ],
                    ),
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                        child: AppText(
                            text: 'ViRKEY',
                            size: 45,
                            family: AppFonts.secondary,
                            color: AppColors.secondary),
                      ),
                    ),
                    Row(
                      children: [
                        const AppText(
                            text: '00:00:00', color: AppColors.secondary),
                        AppIcon(
                          icon: Icons.radio_button_checked,
                          color: AppColors.secondary,
                          onPressed: () => {},
                          size: 30,
                        ),
                        AppIcon(
                          icon: HeroIcons.play,
                          color: AppColors.secondary,
                          onPressed: () => {},
                          size: 30,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            AppButton(
                appText: const AppText(text: 'Home'),
                onPressed: () => context.go('/')),
            AppButton(
                appText: const AppText(
                  text: 'Import Overlay',
                ),
                onPressed: () => pianoOverlayState?.insert(importOverlay))
          ],
        ),
      ),
    );
  }
}
