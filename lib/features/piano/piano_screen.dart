import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';
import 'package:virkey/common_widgets/app_text.dart';
import 'package:virkey/common_widgets/app_icon.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/fonts.dart';
import 'package:virkey/features/piano/import_overlay.dart';
import 'package:virkey/features/piano/piano_key.dart';
import 'package:virkey/features/settings/settings_overlay.dart';

class PianoScreen extends StatefulWidget {
  const PianoScreen({Key? key}) : super(key: key);

  @override
  State<PianoScreen> createState() => _PianoScreenState();
}

class _PianoScreenState extends State<PianoScreen>
    with TickerProviderStateMixin {
  late SettingsOverlay settingsOverlay =
      SettingsOverlay(context: context, vsync: this);
  late ImportOverlay importOverlay =
      ImportOverlay(context: context, vsync: this);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: Center(
        child: Column(
          children: [
            Container(
              color: AppColors.dark,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Wrap(
                          spacing: 15,
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
                              onPressed: () => importOverlay.open(),
                              size: 30,
                            ),
                            AppIcon(
                              icon: HeroIcons.cog6Tooth,
                              color: AppColors.secondary,
                              onPressed: () => settingsOverlay.open(),
                              size: 30,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.only(top: 5),
                          child: AppText(
                            text: 'ViRKEY',
                            size: 28,
                            letterSpacing: 4,
                            family: AppFonts.secondary,
                            color: AppColors.secondary,
                          ),
                        )),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Wrap(
                        // vertical centering of containing widgets
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 15,
                        children: [
                          const AppText(
                            text: '00:00:00',
                            size: 20,
                            color: AppColors.secondary,
                            weight: AppFonts.weightLight,
                            letterSpacing: 4,
                          ),
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
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: Stack(
                      // alignment: Alignment.topCenter,
                      children: const [
                        PianoKeysWhite(),
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 0,
                              child: PianoKeysBlack(),
                        )
                      ],
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
