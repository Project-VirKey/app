import 'dart:io';

import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:virkey/common_widgets/app_icon.dart';
import 'package:virkey/common_widgets/app_play_pause_button.dart';
import 'package:virkey/common_widgets/app_properties_description_title.dart';
import 'package:virkey/common_widgets/app_property_description_action_combination.dart';
import 'package:virkey/common_widgets/app_slider.dart';
import 'package:virkey/common_widgets/app_switch.dart';
import 'package:virkey/common_widgets/app_text.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/fonts.dart';
import 'package:virkey/constants/shadows.dart';
import 'package:virkey/features/recordings/recordings_provider.dart';
import 'package:virkey/utils/confirm_overlay.dart';
import 'package:virkey/utils/file_system.dart';
import 'package:virkey/utils/platform_helper.dart';

class RecordingsListItem extends StatelessWidget {
  const RecordingsListItem(
      {Key? key,
      required this.index,
      required this.vsync,
      required this.recordingsProvider})
      : super(key: key);

  final int index;
  final TickerProvider vsync;
  final RecordingsProvider recordingsProvider;

  @override
  Widget build(BuildContext context) {
    String? recordingsTitleField;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: SizedBox(
            width: 1060,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 30,
                  ),
                  child: TextButton(
                    onPressed: () async {
                      if (recordingsProvider.expandedItem) {
                        recordingsProvider.contractRecordingItem();
                      } else {
                        await recordingsProvider
                            .loadPlayback(recordingsProvider.recordings[index]);

                        recordingsProvider.expandRecordingItem(index);
                      }
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: AppColors.dark,
                      padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: PlatformHelper.isDesktop ? 18 : 14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: AppText(
                            text: recordingsProvider.recordings[index].title,
                            size: 18,
                            letterSpacing: 3,
                            shadows: const [AppShadows.text],
                            overflow: TextOverflow.fade,
                            softWrap: false,
                          ),
                        ),
                        AppIcon(
                          icon: recordingsProvider.expandedItem
                              ? HeroIcons.chevronUp
                              : HeroIcons.chevronDown,
                          color: AppColors.dark,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 5,
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  decoration: const BoxDecoration(
                      color: AppColors.tertiary,
                      borderRadius: BorderRadius.all(Radius.circular(50))),
                ),
                if (recordingsProvider.expandedItem)
                  Container(
                    margin: const EdgeInsets.only(
                      left: 50,
                      right: 50,
                      top: 15,
                      bottom: 35,
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 5,
                          ),
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: const [
                                  AppText(
                                    text: '0:12',
                                    size: 18,
                                    letterSpacing: 3,
                                  ),
                                  AppText(
                                    text: '4:23',
                                    size: 18,
                                    letterSpacing: 3,
                                  ),
                                ],
                              ),
                              Positioned(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 7),
                                  child: AppPlayPauseButton(
                                    onChanged: (val) => {},
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        AppSlider(
                          value: 20,
                          onChanged: (val) => {print(val)},
                        ),
                        PropertyDescriptionActionCombination(
                          title: '',
                          type: PropertyDescriptionActionCombinationType
                              .onlyChild,
                          child: Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    onChanged: (value) {
                                      recordingsTitleField = value;
                                    },
                                    onFieldSubmitted: (value) {
                                      recordingsProvider.updateRecordingTitle(
                                          recordingsProvider.recordings[index],
                                          value);
                                      recordingsProvider
                                          .disableRecordingTitleTextField();
                                    },
                                    focusNode: FocusNode(),
                                    autofocus: true,
                                    initialValue: recordingsProvider
                                        .recordings[index].title,
                                    enabled: recordingsProvider
                                        .recordingTitleTextFieldVisible,
                                    maxLines: 1,
                                    minLines: 1,
                                    style: const TextStyle(
                                        letterSpacing: 3,
                                        fontSize: 16,
                                        fontWeight: AppFonts.weightLight),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                if (recordingsProvider
                                    .recordingTitleTextFieldVisible)
                                  AppIcon(
                                    icon: HeroIcons.check,
                                    color: AppColors.dark,
                                    onPressed: () {
                                      recordingsProvider.updateRecordingTitle(
                                          recordingsProvider.recordings[index],
                                          recordingsTitleField ??
                                              recordingsProvider
                                                  .recordings[index].title);
                                      recordingsProvider
                                          .disableRecordingTitleTextField();
                                    },
                                  ),
                                if (!recordingsProvider
                                    .recordingTitleTextFieldVisible)
                                  AppIcon(
                                    icon: HeroIcons.pencilSquare,
                                    color: AppColors.dark,
                                    onPressed: () {
                                      recordingsProvider
                                              .recordingTitleTextFieldVisible =
                                          true;
                                      recordingsProvider.expandRecordingsList();
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const PropertiesDescriptionTitle(
                            title: 'Audio-Playback'),
                        PropertyDescriptionActionCombination(
                          title: 'Audio',
                          child: AppIcon(
                            icon: HeroIcons.arrowDownTray,
                            color: AppColors.dark,
                            onPressed: () async {
                              // open file picker
                              File? playbackFile =
                                  await AppFileSystem.filePicker(
                                      title: 'Select Audio Playback (MP3/WAV)',
                                      allowedExtensions: ['mp3', 'wav']);

                              // if file has been selected -> store in recordings folder
                              if (playbackFile != null) {
                                if (await AppFileSystem.savePlaybackFile(
                                        playbackFile,
                                        recordingsProvider
                                            .recordings[index].title) !=
                                    null) {
                                  await recordingsProvider.loadPlayback(
                                      recordingsProvider.recordings[index]);
                                }
                              }
                            },
                          ),
                        ),
                        if (recordingsProvider.recordings[index].playback !=
                            null)
                          PropertyDescriptionActionCombination(
                            title: recordingsProvider
                                    .recordings[index].playbackTitle ??
                                '',
                            child: Row(
                              children: [
                                AppSwitch(
                                  value: recordingsProvider
                                      .recordings[index].playbackActive,
                                  onChanged: (bool val) {
                                    recordingsProvider.setPlaybackStatus(
                                        recordingsProvider.recordings[index],
                                        val);
                                  },
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                AppIcon(
                                  icon: HeroIcons.trash,
                                  color: AppColors.dark,
                                  onPressed: () => AppConfirmOverlay(
                                      vsync: vsync,
                                      context: context,
                                      displayText:
                                          'Delete playback "${recordingsProvider.recordings[index].playbackTitle}"?',
                                      confirmButtonText: 'Delete',
                                      onConfirm: () {
                                        recordingsProvider
                                            .recordings[index].playback
                                            ?.delete()
                                            .whenComplete(() async {
                                          await recordingsProvider.loadPlayback(
                                              recordingsProvider
                                                  .recordings[index]);
                                        });
                                      }).open(),
                                ),
                              ],
                            ),
                          ),
                        const PropertiesDescriptionTitle(title: 'Export'),
                        const PropertyDescriptionActionCombination(
                          title: 'Audio',
                          child: AppIcon(
                            icon: HeroIcons.arrowUpTray,
                            color: AppColors.dark,
                          ),
                        ),
                        const PropertyDescriptionActionCombination(
                          title: 'MIDI',
                          child: AppIcon(
                            icon: HeroIcons.arrowUpTray,
                            color: AppColors.dark,
                          ),
                        ),
                        const PropertyDescriptionActionCombination(
                          title: 'Audio & MIDI',
                          child: AppIcon(
                            icon: HeroIcons.arrowUpTray,
                            color: AppColors.dark,
                          ),
                        ),
                        const PropertiesDescriptionTitle(
                          title: 'Delete',
                        ),
                        PropertyDescriptionActionCombination(
                          title: 'Delete Recording',
                          child: AppIcon(
                            icon: HeroIcons.trash,
                            color: AppColors.dark,
                            onPressed: () => AppConfirmOverlay(
                                vsync: vsync,
                                context: context,
                                displayText:
                                    'Delete recording "${recordingsProvider.recordings[index].title}"?',
                                confirmButtonText: 'Delete',
                                onConfirm: () {
                                  recordingsProvider.deleteRecording(
                                      recordingsProvider.recordings[index]);
                                }).open(),
                          ),
                        ),
                      ],
                    ),
                  )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
