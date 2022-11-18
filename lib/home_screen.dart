import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';
import 'package:virkey/common_widgets/app_icon.dart';
import 'package:virkey/common_widgets/app_shadow.dart';
import 'package:virkey/common_widgets/app_text.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/fonts.dart';
import 'package:virkey/constants/radius.dart';
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
    SettingsOverlay settingsOverlay = SettingsOverlay(context: context);

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
                  onPressed: () => settingsOverlay.open(),
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
          // AppShadow(
          //   child: ElevatedButton(
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: AppColors.dark,
          //       foregroundColor: AppColors.dark,
          //       padding: const EdgeInsets.fromLTRB(30, 25, 30, 20),
          //       shape: const RoundedRectangleBorder(
          //           borderRadius: BorderRadius.all(AppRadius.radius)),
          //     ),
          //     onPressed: () => context.go('/piano'),
          //     child: Column(
          //       children: <Widget>[
          //         Image.asset(
          //           'assets/VIK_Logo_v2.png',
          //           width: 80,
          //         ),
          //         const Padding(
          //           padding: EdgeInsets.fromLTRB(0, 10, 0, 5),
          //           child: AppText(
          //             text: 'Play',
          //             family: AppFonts.secondary,
          //             color: AppColors.secondary,
          //             letterSpacing: 5,
          //             size: 24,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          // const SizedBox(
          //   height: 20,
          // ),
          // AppShadow(
          //   child: ElevatedButton(
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: AppColors.dark,
          //       foregroundColor: AppColors.dark,
          //       padding: const EdgeInsets.fromLTRB(25, 25, 25, 20),
          //       shape: const RoundedRectangleBorder(
          //           borderRadius: BorderRadius.all(AppRadius.radius)),
          //     ),
          //     onPressed: () => context.go('/piano'),
          //     child: Column(
          //       children: <Widget>[
          //         SvgPicture.asset(
          //           'assets/VIK_Logo_v2.svg',
          //           width: 65,
          //         ),
          //         const Padding(
          //           padding: EdgeInsets.fromLTRB(0, 7, 0, 0),
          //           child: AppText(
          //             text: 'Play',
          //             family: AppFonts.secondary,
          //             color: AppColors.secondary,
          //             letterSpacing: 5,
          //             size: 24,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          // const SizedBox(
          //   height: 20,
          // ),
          const SizedBox(
            height: 60,
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
                    'assets/images/VIK_Logo_v2.svg',
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
          // const DefaultComponents(),
          const SizedBox(
            height: 25,
          ),
          // --> for later: Expanded List View
          // Row(
          //   children: [
          //     Expanded(
          //       child: Container(
          //         padding: const EdgeInsets.all(5),
          //         color: AppColors.dark,
          //         child: const AppText(
          //           text: 'Recordings',
          //           color: AppColors.secondary,
          //           size: 26,
          //           weight: AppFonts.weightLight,
          //           textAlign: TextAlign.center,
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
          const AppText(
            text: 'Find Device ...',
            size: 20,
            weight: AppFonts.weightLight,
            letterSpacing: 3,
          ),
          const SizedBox(
            height: 60,
          ),
          Row(
            children: [
              Expanded(
                child: AppShadow(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                        color: AppColors.dark,
                        borderRadius: BorderRadius.all(AppRadius.radius)),
                    child: const AppText(
                      text: 'Recordings',
                      color: AppColors.secondary,
                      size: 26,
                      weight: AppFonts.weightLight,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            // Expanded -> contain LisView (https://daill.de/flutter-handle-listview-overflow-in-column)
            child: NotificationListener<UserScrollNotification>(
              onNotification: (notification) {
                // if (notification.direction is ScrollDirection.forward) {
                //   print(notification.direction);
                // }
                return true;
              },
              child: ListView.separated(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 30),
                          child: TextButton(
                            onPressed: () => {print('expand #$index')},
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: AppColors.dark,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 14),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AppShadow(
                                  child: AppText(
                                    text: 'Recording #${index + 1}',
                                    size: 18,
                                  ),
                                ),
                                const AppIcon(
                                  icon: HeroIcons.chevronDown,
                                  color: AppColors.dark,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Container(
                    height: 5,
                    margin: const EdgeInsets.symmetric(horizontal: 30),
                    decoration: const BoxDecoration(
                        color: AppColors.tertiary,
                        borderRadius: BorderRadius.all(Radius.circular(50))),
                  );
                },
                itemCount: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
