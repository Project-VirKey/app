import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';
import 'package:provider/provider.dart';
import 'package:virkey/common_widgets/app_icon.dart';
import 'package:virkey/common_widgets/app_text.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/fonts.dart';
import 'package:virkey/constants/radius.dart';
import 'package:virkey/constants/shadows.dart';
import 'package:virkey/features/recordings/recordings_list.dart';
import 'package:virkey/features/recordings/recordings_provider.dart';
import 'package:virkey/features/recordings/recordings_title_bar.dart';
import 'package:virkey/features/settings/settings_overlay.dart';
import 'package:virkey/utils/platform_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // https://medium.flutterdevs.com/implemented-overlay-in-flutter-fe60d2b33a04
  late final SettingsOverlay _settingsOverlay =
      SettingsOverlay(context: context, vsync: this);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ignore resizing due to system-ui elements (e.g. on-screen keyboard)
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.secondary,
      body: Consumer<RecordingsProvider>(
        builder: (BuildContext context, RecordingsProvider recordingsProvider,
                Widget? child) =>
            Column(
          children: <Widget>[
            // AppButton(appText: const AppText(text: 'Play Note',), onPressed: (() => {})),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppIcon(
                    icon: HeroIcons.cog6Tooth,
                    color: AppColors.dark,
                    onPressed: () => _settingsOverlay.open(),
                    size: 30,
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Row(
                        children: [
                          if (PlatformHelper.isDesktop)
                            AnimatedCrossFade(
                              crossFadeState: recordingsProvider.listExpanded
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              duration: RecordingsProvider.expandDuration,
                              firstChild: const SizedBox(
                                width: 0,
                                height: 65,
                              ),
                              secondChild: Container(
                                height: 65,
                                margin: const EdgeInsets.only(right: 35),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.dark,
                                    foregroundColor: AppColors.tertiary,
                                    shape: const RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.all(AppRadius.radius)),
                                  ),
                                  onPressed: () => context.go('/piano'),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      SvgPicture.asset(
                                        'assets/images/VIK_Logo_v2.svg',
                                        height: 45,
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.only(left: 7.5),
                                        child: AppText(
                                          text: 'Play',
                                          family: AppFonts.secondary,
                                          color: AppColors.secondary,
                                          letterSpacing: 6,
                                          size: 28,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          AnimatedDefaultTextStyle(
                            style: TextStyle(
                                fontSize:
                                    recordingsProvider.listExpanded ? 40 : 45),
                            duration: RecordingsProvider.expandDuration,
                            child: const Text(
                              'ViRKEY',
                              style: TextStyle(
                                fontFamily: AppFonts.secondary,
                                letterSpacing: 4,
                                color: AppColors.dark,
                                shadows: [AppShadows.title],
                              ),
                            ),
                          ),
                        ],
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
            const SizedBox(
              height: 20,
            ),
            AnimatedCrossFade(
              // https://www.geeksforgeeks.org/flutter-animatedcrossfade-widget
              crossFadeState: recordingsProvider.listExpanded
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: RecordingsProvider.expandDuration,
              firstChild: const SizedBox(
                width: 150,
                height: 0,
              ),
              secondChild: Column(
                children: [
                  const SizedBox(
                    height: 40,
                  ),
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.dark,
                        foregroundColor: AppColors.tertiary,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(AppRadius.radius)),
                      ),
                      onPressed: () => context.go('/piano'),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SvgPicture.asset(
                            'assets/images/VIK_Logo_v2.svg',
                            height: 73,
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 7.5),
                            child: AppText(
                              text: 'Play',
                              family: AppFonts.secondary,
                              color: AppColors.secondary,
                              letterSpacing: 6,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  const AppText(
                    text: 'Find Device ...',
                    size: 20,
                    weight: AppFonts.weightLight,
                    letterSpacing: 3,
                  ),
                  const SizedBox(
                    height: 60,
                  ),
                ],
              ),
            ),
            const RecordingsTitleBar(),
            Expanded(child: RecordingsList(vsync: this)),
          ],
        ),
      ),
    );
  }
}
