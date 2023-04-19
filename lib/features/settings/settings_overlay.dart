import 'dart:io';

import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:virkey/common_widgets/app_checkbox.dart';
import 'package:virkey/common_widgets/app_icon.dart';
import 'package:virkey/common_widgets/app_properties_description_title.dart';
import 'package:virkey/common_widgets/app_property_description_action_combination.dart';
import 'package:virkey/common_widgets/app_slider.dart';
import 'package:virkey/common_widgets/app_switch.dart';
import 'package:virkey/common_widgets/app_text.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/fonts.dart';
import 'package:virkey/features/app_introduction/introduction_overlay.dart';
import 'package:virkey/features/piano/piano.dart';
import 'package:virkey/features/piano/piano_provider.dart';
import 'package:virkey/features/recordings/recordings_provider.dart';
import 'package:virkey/features/settings/settings_model.dart';
import 'package:virkey/features/settings/settings_provider.dart';
import 'package:virkey/features/settings/settings_shared_preferences.dart';
import 'package:virkey/utils/confirm_overlay.dart';
import 'package:virkey/utils/file_system.dart';
import 'package:virkey/utils/overlay.dart';
import 'package:virkey/utils/platform_helper.dart';
import 'package:virkey/utils/snackbar.dart';

class SettingsOverlay {
  final BuildContext context;
  final TickerProvider vsync;

  SettingsOverlay({
    required this.context,
    required this.vsync,
  });

  void close() {
    _overlay.close();
  }

  void open() {
    _overlay.open();
  }

  final Uri _url = Uri.parse('https://www.virkey.at');

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw 'Could not launch $_url';
    }
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
                      text: 'Settings',
                      size: 30,
                      family: AppFonts.secondary,
                    ),
                  )),
              Positioned(
                left: 0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(11),
            child: Column(
              children: [
                Consumer<SettingsProvider>(
                  builder: (BuildContext context,
                          SettingsProvider settingsProvider, Widget? child) =>
                      Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Padding(
                      padding: MediaQuery.of(context).orientation ==
                              Orientation.landscape
                          ? EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * .15)
                          : EdgeInsets.zero,
                      child: Column(
                        children: [
                          const PropertiesDescriptionTitle(title: 'Volume'),
                          const Padding(
                            padding: EdgeInsets.only(top: 9, bottom: 6),
                            child: AppText(
                              text: 'Sound Library',
                              weight: AppFonts.weightLight,
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: AppSlider(
                              value: settingsProvider
                                  .settings.audioVolume.soundLibrary
                                  .toDouble(),
                              onChanged: (value) => settingsProvider
                                  .setAudioVolumeSoundLibrary(value),
                              onChangedEnd: (value) {
                                AppSharedPreferences.saveData(
                                    settings: settingsProvider.settings);
                                Piano.changeNotePlayerVolume(settingsProvider
                                    .settings.audioVolume.soundLibrary);
                              },
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 9, bottom: 6),
                            child: AppText(
                              text: 'Audio-Playback',
                              weight: AppFonts.weightLight,
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: AppSlider(
                              value: settingsProvider
                                  .settings.audioVolume.audioPlayback
                                  .toDouble(),
                              onChanged: (value) => settingsProvider
                                  .setAudioVolumeAudioPlayback(value),
                              onChangedEnd: (value) {
                                AppSharedPreferences.saveData(
                                    settings: settingsProvider.settings);
                                Provider.of<PianoProvider>(context,
                                        listen: false)
                                    .setPlaybackVolume(settingsProvider
                                        .settings.audioVolume.audioPlayback);
                                Provider.of<RecordingsProvider>(context,
                                        listen: false)
                                    .setPlaybackVolume(settingsProvider
                                        .settings.audioVolume.audioPlayback);
                              },
                            ),
                          ),
                          const PropertiesDescriptionTitle(title: 'Folder'),
                          if (PlatformHelper.isDesktop)
                            PropertyDescriptionActionCombination(
                              title:
                                  settingsProvider.settings.defaultFolder.path,
                              child: Consumer<RecordingsProvider>(
                                builder: (BuildContext context,
                                        RecordingsProvider recordingsProvider,
                                        Widget? child) =>
                                    Row(
                                  children: [
                                    AppIcon(
                                        icon: HeroIcons.arrowUturnLeft,
                                        color: AppColors.dark,
                                        onPressed: () async {
                                          await settingsProvider
                                              .resetBasePath();
                                          settingsProvider.loadSoundLibraries();
                                          recordingsProvider
                                              .refreshRecordingsFolderFiles();
                                        }),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    AppIcon(
                                      icon: HeroIcons.folder,
                                      color: AppColors.dark,
                                      onPressed: () async {
                                        String? newBasePath =
                                            await AppFileSystem.directoryPicker(
                                                title: 'Select Base Folder');

                                        await settingsProvider
                                            .updateBasePath(newBasePath);

                                        settingsProvider.loadSoundLibraries();
                                        recordingsProvider
                                            .refreshRecordingsFolderFiles();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (!PlatformHelper.isDesktop)
                            AppText(
                              text:
                                  settingsProvider.settings.defaultFolder.path,
                              weight: AppFonts.weightLight,
                              textAlign: TextAlign.center,
                              height: 1.5,
                            ),
                          const SizedBox(
                            height: 9,
                          ),
                          const PropertiesDescriptionTitle(
                              title: 'Default saved Files'),
                          PropertyDescriptionActionCombination(
                            title: 'Audio',
                            child: AppSwitch(
                              value: settingsProvider
                                  .settings.defaultSavedFiles.wav,
                              onChanged: (bool value) {
                                settingsProvider
                                    .settings.defaultSavedFiles.wav = value;
                                settingsProvider.notify();
                                AppSharedPreferences.saveData(
                                    settings: settingsProvider.settings);
                              },
                            ),
                          ),
                          PropertyDescriptionActionCombination(
                              title: 'Audio + Audio-Playback',
                              child: AppSwitch(
                                value: settingsProvider
                                    .settings.defaultSavedFiles.wavAndPlayback,
                                onChanged: (bool value) {
                                  settingsProvider.settings.defaultSavedFiles
                                      .wavAndPlayback = value;
                                  settingsProvider.notify();
                                  AppSharedPreferences.saveData(
                                      settings: settingsProvider.settings);
                                },
                              )),
                          const PropertiesDescriptionTitle(
                              title: 'Sound Library'),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: AppIcon(
                              icon: HeroIcons.arrowDownTray,
                              color: AppColors.dark,
                              onPressed: () async {
                                // specifying allowedExtensions not possible -> 'sf2' not allowed as allowed extension
                                File? soundFontFile =
                                    await AppFileSystem.filePicker(
                                        title: 'Select Sound-Library (SF2)');

                                if (soundFontFile != null) {
                                  if (!(await AppFileSystem.checkIfFileInFolder(
                                      AppFileSystem.soundLibrariesFolder,
                                      AppFileSystem.getFilenameFromPath(
                                          soundFontFile.path)))) {
                                    await AppFileSystem.copyFileToFolder(
                                        soundFontFile,
                                        AppFileSystem.soundLibrariesFolder);

                                    settingsProvider.loadSoundLibraries();

                                    AppSnackBar(
                                            message: 'Imported SoundFont!',
                                            context: context,
                                            vsync: vsync)
                                        .open();
                                  } else {
                                    AppSnackBar(
                                            message:
                                                'SoundFont already imported!',
                                            context: context,
                                            vsync: vsync)
                                        .open();
                                  }
                                } else {
                                  AppSnackBar(
                                          message:
                                              'Could not import SoundFont!',
                                          context: context,
                                          vsync: vsync)
                                      .open();
                                }
                              },
                            ),
                          ),
                          Column(
                            children: [
                              for (SoundLibrary soundLibrary
                                  in settingsProvider.settings.soundLibraries)
                                PropertyDescriptionActionCombination(
                                  title: soundLibrary.name,
                                  child: Row(
                                    children: [
                                      if (!soundLibrary.defaultLibrary)
                                        AppIcon(
                                            icon: HeroIcons.trash,
                                            color: AppColors.dark,
                                            onPressed: () => AppConfirmOverlay(
                                                vsync: vsync,
                                                context: context,
                                                displayText:
                                                    'Delete sound library "${soundLibrary.name}"?',
                                                confirmButtonText: 'Delete',
                                                onConfirm: () {
                                                  File(soundLibrary.path)
                                                      .delete()
                                                      .whenComplete(() async {
                                                    await settingsProvider
                                                        .loadSoundLibraries();
                                                  });
                                                }).open()),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      AppCheckbox(
                                          value: soundLibrary.selected,
                                          onChanged: (bool value) =>
                                              settingsProvider
                                                  .selectSoundLibrary(
                                                      soundLibrary)),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const PropertiesDescriptionTitle(
                              title: 'Introduction'),
                          PropertyDescriptionActionCombination(
                            title: 'Open',
                            child: AppIcon(
                              icon: HeroIcons.chevronRight,
                              color: AppColors.dark,
                              onPressed: () {
                                close();
                                IntroductionOverlay(
                                        context: context, vsync: vsync)
                                    .open();
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          GestureDetector(
                            onTap: _launchUrl,
                            child: const AppText(
                              textAlign: TextAlign.center,
                              text: 'www.virkey.at',
                              letterSpacing: 3,
                              weight: AppFonts.weightLight,
                            ),
                          ),
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
    ],
  );
}
