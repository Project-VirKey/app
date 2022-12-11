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
                    onPressed: () => {
                      if (recordingsProvider.expandedItem)
                        {recordingsProvider.contractRecordingItem()}
                      else
                        {recordingsProvider.expandRecordingItem(index)}
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
                        AppText(
                          text: recordingsProvider.recordings[index].title,
                          size: 18,
                          letterSpacing: 3,
                          shadows: const [AppShadows.text],
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
                          child: Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    onFieldSubmitted: (value) {
                                      recordingsProvider.recordings[index] =
                                          Recording(title: value);
                                      recordingsProvider
                                              .recordingTitleTextFieldVisible =
                                          false;
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
                                      // TODO: set title value from text field
                                      recordingsProvider
                                              .recordingTitleTextFieldVisible =
                                          false;
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
                        const PropertyDescriptionActionCombination(
                          title: 'Audio',
                          child: AppIcon(
                            icon: HeroIcons.arrowDownTray,
                            color: AppColors.dark,
                          ),
                        ),
                        PropertyDescriptionActionCombination(
                          title: 'File1.mp3',
                          child: Row(
                            children: [
                              AppSwitch(
                                value: false,
                                onChanged: (bool val) => {print(val)},
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
                                    displayText: 'Delete playback "File1.mp3"?',
                                    confirmButtonText: 'Delete',
                                    onConfirm: () => {
                                          print('Deleted playback "File1.mp3"')
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
                                onConfirm: () => {
                                      print(
                                          'Deleted ${recordingsProvider.recordings[index].title}')
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
