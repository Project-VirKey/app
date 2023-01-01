import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:provider/provider.dart';
import 'package:virkey/common_widgets/app_button.dart';
import 'package:virkey/common_widgets/app_icon.dart';
import 'package:virkey/common_widgets/app_text_form_field.dart';
import 'package:virkey/features/piano/piano_provider.dart';
import 'package:virkey/utils/overlay.dart';
import 'package:virkey/common_widgets/app_text.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/fonts.dart';
import 'package:virkey/utils/platform_helper.dart';

class RecordingTitleOverlay {
  final BuildContext context;
  final TickerProvider vsync;

  RecordingTitleOverlay({
    required this.context,
    required this.vsync,
  });

  void close() {
    _overlay.close();
  }

  void open() {
    _overlay.open();
  }

  final GlobalKey<FormState> _recordingTitleFormKey = GlobalKey<FormState>();
  final FocusNode _recordingTitleFocusNode = FocusNode();

  String _title = '';

  late final AppOverlay _overlay = AppOverlay(
    context: context,
    vsync: vsync,
    fillDesktopScreen: false,
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
                      text: 'Title',
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
      Flexible(
        fit: FlexFit.loose,
        child: Padding(
          padding: const EdgeInsets.all(11),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: PlatformHelper.isDesktop
                        ? (MediaQuery.of(context).size.width * 0.05)
                        : 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: Form(
                        key: _recordingTitleFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                children: [
                                  AppTextFormField(
                                    focusNode: _recordingTitleFocusNode,
                                    labelText: 'Recording Title',
                                    onChanged: (value) =>
                                        {_title = value ?? ''},
                                    onSaved: (value) => {_title = value ?? ''},
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a title!';
                                      } else if (value.length < 2) {
                                        // TODO: implement check for existing titles
                                        return '...';
                                      }
                                      return null;
                                    },
                                    textInputAction: TextInputAction.done,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(11),
        child: Row(
          children: [
            Expanded(
              child: Consumer<PianoProvider>(
                builder: (BuildContext context, PianoProvider pianoProvider,
                        Widget? child) =>
                    AppButton(
                  appText: const AppText(
                    text: 'Start Recording',
                    color: AppColors.white,
                    size: 22,
                    letterSpacing: 5,
                  ),
                  onPressed: () async {
                    FocusManager.instance.primaryFocus?.unfocus();

                    if (_recordingTitleFormKey.currentState!.validate()) {
                      _recordingTitleFormKey.currentState!.save();
                      close();
                      pianoProvider.recordingTitle = _title;
                      pianoProvider.toggleRecording();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
