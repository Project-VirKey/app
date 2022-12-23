import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:virkey/common_widgets/app_button.dart';
import 'package:virkey/common_widgets/app_icon.dart';
import 'package:virkey/common_widgets/app_text_form_field.dart';
import 'package:virkey/features/cloud_synchronisation/authentication.dart';
import 'package:virkey/utils/overlay.dart';
import 'package:virkey/common_widgets/app_text.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/fonts.dart';
import 'package:virkey/utils/platform_helper.dart';
import 'package:virkey/utils/snackbar.dart';

class UpdatePasswordOverlay {
  final BuildContext context;
  final TickerProvider vsync;

  UpdatePasswordOverlay({
    required this.context,
    required this.vsync,
  });

  void close() {
    _overlay.close();
  }

  void open() {
    _overlay.open();
  }

  final GlobalKey<FormState> _updatePasswordFormKey = GlobalKey<FormState>();
  final FocusNode _updatePasswordFocusNode = FocusNode();
  final FocusNode _updateNewPasswordFocusNode = FocusNode();

  String _password = '';
  String _newPassword = '';

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
                      text: 'Password',
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
                        key: _updatePasswordFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                children: [
                                  AppTextFormField(
                                    focusNode: _updatePasswordFocusNode,
                                    labelText: 'Password',
                                    onChanged: (value) =>
                                        {_password = value ?? ''},
                                    onSaved: (value) =>
                                        {_password = value ?? ''},
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your password!';
                                      }
                                      return null;
                                    },
                                    textInputAction: TextInputAction.next,
                                    nextFieldFocusNode:
                                        _updateNewPasswordFocusNode,
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  AppTextFormField(
                                    focusNode: _updateNewPasswordFocusNode,
                                    labelText: 'New Password',
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your new Password!';
                                      } else if (value.length < 6) {
                                        return 'Please enter at least 6 characters!';
                                      }
                                      return null;
                                    },
                                    onSaved: (value) =>
                                        {_newPassword = value ?? ''},
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
                  text: 'Update',
                  color: AppColors.white,
                  size: 22,
                  letterSpacing: 5,
                ),
                onPressed: () async {
                  FocusManager.instance.primaryFocus?.unfocus();

                  if (_updatePasswordFormKey.currentState!.validate()) {
                    _updatePasswordFormKey.currentState!.save();

                    List response = await AppAuthentication.updatePassword(
                        _password, _newPassword);

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
