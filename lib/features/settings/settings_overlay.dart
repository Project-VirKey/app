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
import 'package:virkey/features/cloud_synchronisation/authentication.dart';
import 'package:virkey/features/cloud_synchronisation/login_overlay.dart';
import 'package:virkey/features/settings/settings_model.dart';
import 'package:virkey/features/settings/settings_provider.dart';
import 'package:virkey/utils/confirm_overlay.dart';
import 'package:virkey/utils/overlay.dart';
import 'package:virkey/common_widgets/app_text.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/fonts.dart';
import 'package:virkey/features/cloud_synchronisation/cloud_provider.dart';

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

  late final LoginOverlay _loginOverlay =
      LoginOverlay(context: context, vsync: vsync);

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
                                onChanged: (val) {
                                  if (settingsProvider
                                          .settings.audioVolume.soundLibrary !=
                                      val.toInt()) {
                                    settingsProvider.settings.audioVolume
                                        .soundLibrary = val.toInt();
                                    settingsProvider.saveData();
                                  }
                                }),
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
                                onChanged: (val) {
                                  if (settingsProvider
                                          .settings.audioVolume.audioPlayback !=
                                      val.toInt()) {
                                    settingsProvider.settings.audioVolume
                                        .audioPlayback = val.toInt();
                                    settingsProvider.saveData();
                                  }
                                }),
                          ),
                          const PropertiesDescriptionTitle(
                              title: 'Default Folder'),
                          PropertyDescriptionActionCombination(
                            title: settingsProvider
                                .settings.defaultFolder.displayName,
                            child: const AppIcon(
                              icon: HeroIcons.folder,
                              color: AppColors.dark,
                            ),
                          ),
                          const PropertiesDescriptionTitle(
                              title: 'Default saved Files'),
                          PropertyDescriptionActionCombination(
                            title: 'MP3',
                            child: AppSwitch(
                              value: settingsProvider
                                  .settings.defaultSavedFiles.mp3,
                              onChanged: (bool val) {
                                settingsProvider
                                    .settings.defaultSavedFiles.mp3 = val;
                                settingsProvider.saveData();
                              },
                            ),
                          ),
                          PropertyDescriptionActionCombination(
                              title: 'MP3 + Audio-Playback',
                              child: AppSwitch(
                                value: settingsProvider
                                    .settings.defaultSavedFiles.mp3AndPlayback,
                                onChanged: (bool val) {
                                  settingsProvider.settings.defaultSavedFiles
                                      .mp3AndPlayback = val;
                                  settingsProvider.saveData();
                                },
                              )),
                          const PropertiesDescriptionTitle(
                              title: 'Sound Library'),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: AppIcon(
                              icon: HeroIcons.arrowDownTray,
                              color: AppColors.dark,
                              onPressed: () => {},
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
                                      AppIcon(
                                          icon: HeroIcons.trash,
                                          color: AppColors.dark,
                                          onPressed: () => AppConfirmOverlay(
                                              vsync: vsync,
                                              context: context,
                                              displayText:
                                                  'Delete sound library "${soundLibrary.name}"?',
                                              confirmButtonText: 'Delete',
                                              onConfirm: () => {
                                                    print(
                                                        'Deleted sound library.')
                                                  }).open()),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      AppCheckbox(
                                          value: soundLibrary.selected,
                                          onChanged: (bool val) =>
                                              settingsProvider
                                                  .selectSoundLibrary(
                                                      soundLibrary)),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const PropertiesDescriptionTitle(
                              title: 'Account Settings'),
                          Consumer(
                            builder: (BuildContext context,
                                    CloudProvider cloudProvider,
                                    Widget? child) =>
                                Column(
                              children: [
                                Visibility(
                                  visible: cloudProvider.cloud.loggedIn,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const AppText(
                                        text: 'Logged in as',
                                        weight: AppFonts.weightLight,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const AppText(
                                        text: 'Richard Krikler',
                                        weight: AppFonts.weightLight,
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      PropertyDescriptionActionCombination(
                                        title: 'Log out',
                                        child: AppIcon(
                                          icon: HeroIcons.arrowRightOnRectangle,
                                          color: AppColors.dark,
                                          onPressed: () => AppConfirmOverlay(
                                              vsync: vsync,
                                              context: context,
                                              displayText:
                                                  'Are you sure you want to log out?',
                                              additionalText:
                                                  'Your files and settings will no longer be synchronised.',
                                              confirmButtonText: 'Log out',
                                              onConfirm: () {
                                                AppAuthentication.logout();
                                              }).open(),
                                        ),
                                      ),
                                      PropertyDescriptionActionCombination(
                                          title: 'Last synced',
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: const [
                                              AppText(
                                                text: '16:45',
                                                weight: AppFonts.weightLight,
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              AppText(
                                                text: '27.11.2022',
                                                weight: AppFonts.weightLight,
                                              ),
                                            ],
                                          )),
                                      PropertyDescriptionActionCombination(
                                        title: 'Synchronise now',
                                        child: AppIcon(
                                          icon:
                                              HeroIcons.arrowPathRoundedSquare,
                                          color: AppColors.dark,
                                          onPressed: () =>
                                              {print('Synchronise now')},
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 9),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: const [
                                                AppText(
                                                  text: 'Firstname',
                                                  weight: AppFonts.weightLight,
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                AppText(
                                                  text: 'Richard',
                                                  weight: AppFonts.weightLight,
                                                ),
                                              ],
                                            ),
                                            AppIcon(
                                              icon: HeroIcons.pencilSquare,
                                              color: AppColors.dark,
                                              onPressed: () =>
                                                  {print('Firstname')},
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 9),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: const [
                                                AppText(
                                                  text: 'Lastname',
                                                  weight: AppFonts.weightLight,
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                AppText(
                                                  text: 'Krikler',
                                                  weight: AppFonts.weightLight,
                                                ),
                                              ],
                                            ),
                                            AppIcon(
                                              icon: HeroIcons.pencilSquare,
                                              color: AppColors.dark,
                                              onPressed: () =>
                                                  {print('Lastname')},
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 9),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: const [
                                                AppText(
                                                  text: 'E-Mail',
                                                  weight: AppFonts.weightLight,
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                AppText(
                                                  text:
                                                      'richard.krikler@virke..',
                                                  weight: AppFonts.weightLight,
                                                ),
                                              ],
                                            ),
                                            AppIcon(
                                              icon: HeroIcons.pencilSquare,
                                              color: AppColors.dark,
                                              onPressed: () =>
                                                  {print('E-Mail')},
                                            ),
                                          ],
                                        ),
                                      ),
                                      PropertyDescriptionActionCombination(
                                        title: 'Delete Account',
                                        child: AppIcon(
                                          icon: HeroIcons.trash,
                                          color: AppColors.dark,
                                          onPressed: () => AppConfirmOverlay(
                                              vsync: vsync,
                                              context: context,
                                              displayText:
                                                  'Are you sure you want to delete your account?',
                                              additionalText:
                                                  'Your files, settings and account information will be deleted from the database but are still available locally.',
                                              confirmButtonText:
                                                  'Delete Account',
                                              onConfirm: () => {
                                                    print('Deleted Account')
                                                  }).open(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!cloudProvider.cloud.loggedIn)
                                  PropertyDescriptionActionCombination(
                                    title: 'Login / Sign up',
                                    child: AppIcon(
                                      icon: HeroIcons.arrowLeftOnRectangle,
                                      color: AppColors.dark,
                                      onPressed: () => {_loginOverlay.open()},
                                    ),
                                  ),
                              ],
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
