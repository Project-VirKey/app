import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:virkey/common_widgets/app_checkbox.dart';
import 'package:virkey/common_widgets/app_icon.dart';
import 'package:virkey/common_widgets/app_properties_description_title.dart';
import 'package:virkey/common_widgets/app_property_description_action_combination.dart';
import 'package:virkey/common_widgets/app_switch.dart';
import 'package:virkey/utils/overlay.dart';
import 'package:virkey/common_widgets/app_text.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/fonts.dart';

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
      SizedBox(
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
      Expanded(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).orientation == Orientation.landscape
                            ? (MediaQuery.of(context).size.width * .5)
                            : double.infinity,
                  ),
                  child: Column(
                    children: [
                      const PropertiesDescriptionTitle(title: 'Volume'),
                      const PropertiesDescriptionTitle(title: 'Default Folder'),
                      PropertyDescriptionActionCombination(
                        title: '/dfdg/dsdf/folder/',
                        child: const AppIcon(
                          icon: HeroIcons.folder,
                          color: AppColors.dark,
                        ),
                        onPressed: () => {},
                      ),
                      const PropertiesDescriptionTitle(
                          title: 'Default saved Files'),
                      PropertyDescriptionActionCombination(
                          title: 'MP3',
                          child: AppSwitch(
                            value: false,
                            onChanged: (bool val) => {print(val)},
                          )),
                      PropertyDescriptionActionCombination(
                          title: 'MP3 + Audio-Playback',
                          child: AppSwitch(
                            value: false,
                            onChanged: (bool val) => {print(val)},
                          )),
                      const PropertiesDescriptionTitle(title: 'Sound Library'),
                      AppIcon(
                        icon: HeroIcons.arrowDownTray,
                        color: AppColors.dark,
                        onPressed: () => {},
                      ),
                      PropertyDescriptionActionCombination(
                        title: 'Default Piano',
                        child: AppCheckbox(
                            value: false,
                            onChanged: (bool val) => {print(val)}),
                      ),
                      PropertyDescriptionActionCombination(
                        title: 'Electric',
                        child: AppCheckbox(
                            value: false,
                            onChanged: (bool val) => {print(val)}),
                      ),
                      GestureDetector(
                        onTap: _launchUrl,
                        child: const AppText(
                          textAlign: TextAlign.center,
                          text: 'www.virkey.at',
                          letterSpacing: 3,
                          weight: AppFonts.weightLight,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
