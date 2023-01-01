import 'dart:io';

import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:provider/provider.dart';
import 'package:virkey/common_widgets/app_icon.dart';
import 'package:virkey/common_widgets/app_properties_description_title.dart';
import 'package:virkey/common_widgets/app_property_description_action_combination.dart';
import 'package:virkey/common_widgets/app_switch.dart';
import 'package:virkey/common_widgets/app_text.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/fonts.dart';
import 'package:virkey/features/piano/piano_provider.dart';
import 'package:virkey/utils/confirm_overlay.dart';
import 'package:virkey/utils/file_system.dart';
import 'package:virkey/utils/overlay.dart';
import 'package:virkey/utils/snackbar.dart';

class ImportOverlay {
  final BuildContext context;
  final TickerProvider vsync;

  ImportOverlay({required this.context, required this.vsync});

  void close() {
    _overlay.close();
  }

  void open() {
    _overlay.open();
  }

  late final AppOverlay _overlay = AppOverlay(
    context: context,
    vsync: vsync,
    children: [
      Padding(
        padding: const EdgeInsets.all(11),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 40,
          child: Stack(
            children: [
              const Positioned.fill(
                  left: 0,
                  right: 0,
                  child: Center(
                    child: AppText(
                        text: 'Import', size: 30, family: AppFonts.secondary),
                  )),
              Positioned(
                left: 0,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: AppIcon(
                      icon: HeroIcons.arrowUturnLeft,
                      color: AppColors.dark,
                      onPressed: () => close()),
                ),
              ),
            ],
          ),
        ),
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.all(11),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Padding(
              padding:
                  MediaQuery.of(context).orientation == Orientation.landscape
                      ? EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * .15)
                      : EdgeInsets.zero,
              child: Consumer<PianoProvider>(
                builder: (BuildContext context, PianoProvider pianoProvider,
                        Widget? child) =>
                    Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const PropertiesDescriptionTitle(
                      title: 'Audio-Playback',
                    ),
                    if (pianoProvider.playbackPath == null)
                      PropertyDescriptionActionCombination(
                        type:
                            PropertyDescriptionActionCombinationType.onlyChild,
                        child: AppIcon(
                          icon: HeroIcons.arrowDownTray,
                          color: AppColors.dark,
                          onPressed: () async {
                            File? playbackFile = await AppFileSystem.filePicker(
                                title: 'Select Audio Playback (MP3/WAV)',
                                allowedExtensions: ['mp3', 'wav']);

                            if (playbackFile == null) {
                              AppSnackBar(
                                      message: 'Could not load Playback!',
                                      context: context,
                                      vsync: vsync)
                                  .open();
                            } else {
                              // if (await AppFileSystem.savePlaybackFile(
                              //         playbackFile, recording.title) !=
                              //     null) {
                              //   await recordingsProvider
                              //       .loadPlayback(recording);
                              // }
                              pianoProvider.setPlayback(playbackFile.path);
                            }
                          },
                        ),
                      ),
                    if (pianoProvider.playbackPath != null)
                      PropertyDescriptionActionCombination(
                        title: pianoProvider.playbackFileName ?? 'File',
                        child: Row(
                          children: [
                            AppSwitch(
                              value: pianoProvider.isPlaybackPlaying,
                              onChanged: (bool val) => {
                                pianoProvider.isPlaybackPlaying =
                                    !pianoProvider.isPlaybackPlaying
                              },
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            AppIcon(
                              icon: HeroIcons.xMark,
                              color: AppColors.dark,
                              onPressed: () => AppConfirmOverlay(
                                  vsync: vsync,
                                  context: context,
                                  displayText:
                                      'Remove playback "${pianoProvider.playbackFileName}"?',
                                  confirmButtonText: 'Remove',
                                  onConfirm: () =>
                                      pianoProvider.removePlayback()).open(),
                            ),
                          ],
                        ),
                      ),
                    const PropertiesDescriptionTitle(
                      title: 'MIDI',
                    ),
                    PropertyDescriptionActionCombination(
                      type: PropertyDescriptionActionCombinationType.onlyChild,
                      child: AppIcon(
                        icon: HeroIcons.arrowDownTray,
                        color: AppColors.dark,
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      )
    ],
  );
}
