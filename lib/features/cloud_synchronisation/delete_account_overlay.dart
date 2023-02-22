import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:virkey/common_widgets/app_button.dart';
import 'package:virkey/common_widgets/app_icon.dart';
import 'package:virkey/common_widgets/app_text.dart';
import 'package:virkey/common_widgets/app_text_form_field.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/fonts.dart';
import 'package:virkey/features/cloud_synchronisation/authentication.dart';
import 'package:virkey/utils/overlay.dart';
import 'package:virkey/utils/platform_helper.dart';
import 'package:virkey/utils/snackbar.dart';

class DeleteAccountOverlay {
  final BuildContext context;
  final TickerProvider vsync;

  DeleteAccountOverlay({
    required this.context,
    required this.vsync,
  });

  void close() {
    _overlay.close();
  }

  void open() {
    _overlay.open();
  }

  final GlobalKey<FormState> _deleteEmailFormKey = GlobalKey<FormState>();
  final FocusNode _deletePasswordFocusNode = FocusNode();

  String _password = '';

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
                      text: 'Delete Account',
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
                        key: _deleteEmailFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                children: [
                                  AppTextFormField(
                                    focusNode: _deletePasswordFocusNode,
                                    labelText: 'Password',
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your Password!';
                                      }
                                      return null;
                                    },
                                    onSaved: (value) =>
                                        {_password = value ?? ''},
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
              child: AppButton(
                appText: const AppText(
                  text: 'Delete',
                  color: AppColors.white,
                  size: 22,
                  letterSpacing: 5,
                ),
                onPressed: () async {
                  FocusManager.instance.primaryFocus?.unfocus();

                  if (_deleteEmailFormKey.currentState!.validate()) {
                    _deleteEmailFormKey.currentState!.save();

                    List response =
                        await AppAuthentication.deleteAccount(_password);

                    AppSnackBar(
                            message: response[1],
                            context: context,
                            vsync: vsync)
                        .open();

                    if (response[0]) {
                      close();
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
