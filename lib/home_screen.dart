import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';
import 'package:provider/provider.dart';
import 'package:virkey/common_widgets/app_button.dart';
import 'package:virkey/common_widgets/app_icon.dart';
import 'package:virkey/common_widgets/app_text.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/fonts.dart';
import 'package:virkey/constants/radius.dart';
import 'package:virkey/constants/shadows.dart';
import 'package:virkey/features/cloud_synchronisation/cloud_provider.dart';
import 'package:virkey/features/midi_device/temp_midi_status.dart';
import 'package:virkey/features/piano/piano_play_button.dart';
import 'package:virkey/features/recordings/recordings_list.dart';
import 'package:virkey/features/recordings/recordings_provider.dart';
import 'package:virkey/features/recordings/recordings_title_bar.dart';
import 'package:virkey/features/settings/settings_overlay.dart';
import 'package:virkey/features/settings/settings_provider.dart';
import 'package:virkey/utils/confirm_overlay.dart';
import 'package:virkey/utils/platform_helper.dart';
import 'package:virkey/utils/snackbar.dart';

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
              Consumer<SettingsProvider>(
            builder: (BuildContext context, SettingsProvider settingsProvider,
                    Widget? child) =>
                Column(
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 11, horizontal: 20),
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
                                  crossFadeState:
                                      recordingsProvider.listExpanded
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
                                            borderRadius: BorderRadius.all(
                                                AppRadius.radius)),
                                      ),
                                      // TODO: stop playing recording when changing routes
                                      onPressed: () => context.go('/piano'),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                    fontSize: recordingsProvider.listExpanded
                                        ? 40
                                        : 45),
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
                      Consumer<CloudProvider>(
                        builder: (BuildContext context,
                                CloudProvider cloudProvider, Widget? child) =>
                            AppIcon(
                          icon: HeroIcons.arrowPathRoundedSquare,
                          color: AppColors.dark,
                          onPressed: () {
                            if (cloudProvider.loggedIn) {
                              AppConfirmOverlay(
                                      context: context,
                                      displayText: 'Synchronise with the Cloud',
                                      confirmButtonText: 'Synchronise',
                                      onConfirm: () {
                                        cloudProvider.synchronise();
                                      },
                                      vsync: this)
                                  .open();
                            } else {
                              AppSnackBar(
                                      message: 'Login to synchronise!',
                                      context: context,
                                      vsync: this)
                                  .open();
                            }
                          },
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
                // const TempMidiStatus(),
                const SizedBox(
                  height: 20,
                ),
                AnimatedCrossFade(
                  // https://www.geeksforgeeks.org/flutter-animatedcrossfade-widget
                  crossFadeState: recordingsProvider.listExpanded
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  duration: RecordingsProvider.expandDuration,
                  firstChild: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 0,
                  ),
                  secondChild: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: const [
                        SizedBox(
                          height: 40,
                        ),
                        PianoPlayButton(),
                        SizedBox(
                          height: 25,
                        ),
                        AppText(
                          text: 'Find Device ...',
                          size: 20,
                          weight: AppFonts.weightLight,
                          letterSpacing: 3,
                        ),
                        SizedBox(
                          height: 60,
                        ),
                      ],
                    ),
                  ),
                ),
                const RecordingsTitleBar(),
                const Expanded(child: RecordingsList()),
              ],
            ),
          ),
        ));
  }
}
