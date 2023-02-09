import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';
import 'package:provider/provider.dart';
import 'package:virkey/common_widgets/app_keyboard_shortcut.dart';
import 'package:virkey/common_widgets/app_play_pause_button.dart';
import 'package:virkey/common_widgets/app_text.dart';
import 'package:virkey/common_widgets/app_icon.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/fonts.dart';
import 'package:virkey/features/midi_device/midi_device_provider.dart';
import 'package:virkey/features/piano/import_overlay.dart';
import 'package:virkey/features/piano/piano_key.dart';
import 'package:virkey/features/piano/piano_provider.dart';
import 'package:virkey/features/piano/piano_recording_title_overlay.dart';
import 'package:virkey/features/recordings/recordings_provider.dart';
import 'package:virkey/features/settings/settings_overlay.dart';
import 'package:virkey/features/settings/settings_provider.dart';
import 'package:virkey/utils/platform_helper.dart';
import 'package:virkey/utils/snackbar.dart';

class PianoScreen extends StatefulWidget {
  const PianoScreen({Key? key}) : super(key: key);

  @override
  State<PianoScreen> createState() => _PianoScreenState();
}

class _PianoScreenState extends State<PianoScreen>
    with TickerProviderStateMixin {
  late final SettingsOverlay _settingsOverlay =
      SettingsOverlay(context: context, vsync: this);
  late final ImportOverlay _importOverlay =
      ImportOverlay(context: context, vsync: this);

  late final AnimationController _recordButtonAnimationController =
      AnimationController(vsync: this, duration: const Duration(seconds: 1));

  // https://api.flutter.dev/flutter/animation/ColorTween-class.html, 06.01.2022
  late final Animation _recordButtonAnimation =
      ColorTween(begin: AppColors.secondary, end: AppColors.primary)
          .animate(_recordButtonAnimationController);

  int prevValue = -1;

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    _recordButtonAnimation.addListener(() {
      setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (Provider.of<PianoProvider>(context).isRecording) {
      if (!_recordButtonAnimationController.isAnimating) {
        _recordButtonAnimationController.repeat(reverse: true);
      }
    } else {
      _recordButtonAnimationController.reset();
    }

    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: Center(
        child: Consumer3<SettingsProvider, PianoProvider, RecordingsProvider>(
          builder: (BuildContext context,
                  SettingsProvider settingsProvider,
                  PianoProvider pianoProvider,
                  RecordingsProvider recordingsProvider,
                  Widget? child) =>
              AppKeyboardShortcut(
            focusNode: _focusNode,
            shortcuts: pianoProvider.keyboardKeyPianoKey,
            child: Column(
              children: [
                Container(
                  color: AppColors.dark,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 15,
                            children: [
                              const SizedBox(
                                width: 5,
                              ),
                              AppIcon(
                                icon: HeroIcons.arrowUturnLeft,
                                color: AppColors.secondary,
                                onPressed: () {
                                  if (pianoProvider.isRecording) {
                                    AppSnackBar(
                                            message: 'Active Recording!',
                                            context: context,
                                            vsync: this)
                                        .open();
                                  } else {
                                    context.go('/');
                                    if (pianoProvider.isSomethingPlaying) {
                                      pianoProvider.playPause();
                                    }
                                  }
                                },
                                size: 30,
                              ),
                              AppIcon(
                                icon: HeroIcons.arrowDownTray,
                                color: AppColors.secondary,
                                onPressed: () => _importOverlay.open(),
                                size: 30,
                              ),
                              AppIcon(
                                icon: HeroIcons.cog6Tooth,
                                color: AppColors.secondary,
                                onPressed: () => _settingsOverlay.open(),
                                size: 30,
                              ),
                              // Selector -> only listens to one value of MidiDeviceProvider
                              Selector<MidiDeviceProvider, bool>(
                                selector: (_, midiDeviceProvider) =>
                                    midiDeviceProvider.connected,
                                builder: (_, midiDeviceConnected, __) {
                                  return AppIcon(
                                    icon: midiDeviceConnected
                                        ? Icons.usb
                                        : Icons.usb_off,
                                    color: midiDeviceConnected
                                        ? AppColors.primary
                                        : AppColors.secondary,
                                    size: 30,
                                  );
                                },
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AppIcon(
                                    icon: HeroIcons.chevronLeft,
                                    color: AppColors.secondary,
                                    onPressed: () =>
                                        pianoProvider.decrementOctaveIndex(),
                                    size: 30,
                                  ),
                                  SizedBox(
                                    width: 40,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        AppText(
                                          text:
                                              '${pianoProvider.currentOctaveIndex == 2 ? '+' : ''}${pianoProvider.currentOctaveIndex - 1}',
                                          size: 25,
                                          color: AppColors.secondary,
                                          weight: AppFonts.weightLight,
                                          letterSpacing: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                  AppIcon(
                                    icon: HeroIcons.chevronRight,
                                    color: AppColors.secondary,
                                    onPressed: () =>
                                        pianoProvider.incrementOctaveIndex(),
                                    size: 30,
                                  ),
                                ],
                              ),
                            ],
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
                              AppText(
                                text: pianoProvider.displayTime,
                                size: 20,
                                color: AppColors.secondary,
                                weight: AppFonts.weightLight,
                                letterSpacing: 4,
                              ),
                              AppIcon(
                                icon: Icons.radio_button_checked,
                                color: _recordButtonAnimation.value,
                                onPressed: () {
                                  if (pianoProvider.isRecording) {
                                    pianoProvider.toggleRecording();
                                    AppSnackBar(
                                      message:
                                          'Saved "${pianoProvider.recordingTitle}"',
                                      context: context,
                                      vsync: this,
                                    ).open();
                                    recordingsProvider
                                        .refreshRecordingsFolderFiles();
                                  } else {
                                    RecordingTitleOverlay(
                                            context: context, vsync: this)
                                        .open();
                                  }
                                },
                                size: 30,
                              ),
                              AppPlayPauseButton(
                                value: pianoProvider.isSomethingPlaying,
                                light: true,
                                onPressed: () => pianoProvider.playPause(),
                              ),
                              AppIcon(
                                icon: HeroIcons.stop,
                                color: AppColors.secondary,
                                size: 30,
                                onPressed: () {
                                  pianoProvider.stop();
                                },
                              ),
                              const SizedBox(
                                width: 5,
                              )
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
                    child: GestureDetector(
                      onVerticalDragUpdate: (DragUpdateDetails details) {
                        if (PlatformHelper.isDesktop) {
                          return;
                        }

                        int keyIndex = (details.globalPosition.dx /
                                (MediaQuery.of(context).size.width) *
                                7)
                            .floor();

                        if (keyIndex != prevValue) {
                          // FlutterMidi().playMidiNote(
                          //     midi: PianoKeys.white[keyIndex][1] +
                          //         PianoKeys.midiOffset);
                          prevValue = keyIndex;
                        }
                      },
                      onVerticalDragEnd: (DragEndDetails details) =>
                          {prevValue = -1},
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
