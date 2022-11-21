import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:virkey/common_widgets/app_icon.dart';
import 'package:virkey/common_widgets/app_properties_description_title.dart';
import 'package:virkey/common_widgets/app_property_description_action_combination.dart';
import 'package:virkey/common_widgets/app_switch.dart';
import 'package:virkey/common_widgets/app_text.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/fonts.dart';
import 'package:virkey/utils/overlay.dart';

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
      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const PropertiesDescriptionTitle(
                title: 'Audio-Playback',
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).orientation == Orientation.landscape
                      ? (MediaQuery.of(context).size.width * .5)
                      : double.infinity,
                ),
                child: PropertyDescriptionActionCombination(
                  title: 'File3.mp3',
                  child: Row(
                    children: [
                      AppSwitch(
                        value: false,
                        onChanged: (bool val) => {print(val)},
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      const AppIcon(
                        icon: HeroIcons.trash,
                        color: AppColors.dark,
                      ),
                    ],
                  ),
                ),
              ),
              const PropertiesDescriptionTitle(
                title: 'MIDI',
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * .5),
                child: PropertyDescriptionActionCombination(
                  title: '',
                  child: const AppIcon(
                    icon: HeroIcons.arrowDownTray,
                    color: AppColors.dark,
                  ),
                  onPressed: () => {},
                ),
              ),
            ],
          ),
        ),
      )
    ],
  );
}
