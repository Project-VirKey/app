import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';
import 'package:virkey/common_widgets/app_icon.dart';
import 'package:virkey/common_widgets/app_shadow.dart';
import 'package:virkey/common_widgets/app_text.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/fonts.dart';
import 'package:virkey/constants/radius.dart';
import 'package:virkey/default_components.dart';
import 'package:virkey/features/settings/settings_overlay.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    // https://medium.flutterdevs.com/implemented-overlay-in-flutter-fe60d2b33a04
    OverlayState? homeOverlayState = Overlay.of(context);

    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppIcon(
                  icon: HeroIcons.cog6Tooth,
                  color: AppColors.dark,
                  onPressed: () => homeOverlayState?.insert(settingsOverlay),
                  size: 30,
                ),
                const Center(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                    child: AppShadow(
                      child: AppText(
                          text: 'ViRKEY',
                          size: 40,
                          family: AppFonts.secondary,
                          letterSpacing: 4),
                    ),
                  ),
                ),
                AppIcon(
                  icon: HeroIcons.arrowPathRoundedSquare,
                  color: AppColors.dark,
                  onPressed: () => {},
                  size: 30,
                ),
              ],
            ),
          ),
          AppShadow(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dark,
                foregroundColor: AppColors.dark,
                padding: const EdgeInsets.fromLTRB(30, 25, 30, 20),
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(AppRadius.radius)),
              ),
              onPressed: () => context.go('/piano'),
              child: Column(
                children: <Widget>[
                  Image.asset(
                    'assets/VIK_Logo_v2.png',
                    width: 80,
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 5),
                    child: AppText(
                      text: 'Play',
                      family: AppFonts.secondary,
                      color: AppColors.secondary,
                      letterSpacing: 5,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          AppShadow(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dark,
                foregroundColor: AppColors.dark,
                padding: const EdgeInsets.fromLTRB(25, 25, 25, 20),
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(AppRadius.radius)),
              ),
              onPressed: () => context.go('/piano'),
              child: Column(
                children: <Widget>[
                  SvgPicture.asset(
                    'assets/VIK_Logo_v2.svg',
                    width: 65,
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(0, 7, 0, 0),
                    child: AppText(
                      text: 'Play',
                      family: AppFonts.secondary,
                      color: AppColors.secondary,
                      letterSpacing: 5,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          AppShadow(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dark,
                foregroundColor: AppColors.dark,
                padding: const EdgeInsets.fromLTRB(27, 25, 27, 20),
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(AppRadius.radius)),
              ),
              onPressed: () => context.go('/piano'),
              child: Column(
                children: <Widget>[
                  SvgPicture.asset(
                    'assets/VIK_Logo_v2.svg',
                    height: 70,
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(0, 7, 0, 2),
                    child: AppText(
                      text: 'Play',
                      family: AppFonts.secondary,
                      color: AppColors.secondary,
                      letterSpacing: 5,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const DefaultComponents()
        ],
      ),
    );
  }
}
