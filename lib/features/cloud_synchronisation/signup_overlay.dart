import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:virkey/common_widgets/app_button.dart';
import 'package:virkey/common_widgets/app_icon.dart';
import 'package:virkey/common_widgets/app_text.dart';
import 'package:virkey/common_widgets/app_text_form_field.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/fonts.dart';
import 'package:virkey/features/cloud_synchronisation/authentication.dart';
import 'package:virkey/features/cloud_synchronisation/login_overlay.dart';
import 'package:virkey/utils/overlay.dart';
import 'package:virkey/utils/snackbar.dart';

class SignupOverlay {
  final BuildContext context;
  final TickerProvider vsync;

  SignupOverlay({
    required this.context,
    required this.vsync,
  });

  void close() {
    _overlay.close();
  }

  void open() {
    _overlay.open();
  }

  late final LoginOverlay _loginOverlay =
      LoginOverlay(context: context, vsync: vsync);

  final GlobalKey<FormState> _signupFormKey = GlobalKey<FormState>();
  final FocusNode _signupUsernameNode = FocusNode();
  final FocusNode _signupEmailFocusNode = FocusNode();
  final FocusNode _signupPasswordFocusNode = FocusNode();

  String _username = '';
  String _email = '';
  String _password = '';

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
                      text: 'Sign up',
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
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(11),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: MediaQuery.of(context).orientation ==
                              Orientation.landscape
                          ? EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * .15)
                          : EdgeInsets.zero,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: Form(
                              key: _signupFormKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      children: [
                                        AppTextFormField(
                                          focusNode: _signupUsernameNode,
                                          labelText: 'Username',
                                          onSaved: (value) =>
                                              {_username = value ?? ''},
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter a Username!';
                                            } else if (value.length < 2) {
                                              return 'Please enter at least 2 characters!';
                                            }
                                            return null;
                                          },
                                          textInputAction: TextInputAction.next,
                                          nextFieldFocusNode:
                                              _signupEmailFocusNode,
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        AppTextFormField(
                                          focusNode: _signupEmailFocusNode,
                                          labelText: 'E-Mail',
                                          onSaved: (value) =>
                                              {_email = value ?? ''},
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter your email address!';
                                            } else if (!EmailValidator.validate(
                                                value)) {
                                              return 'Incorrect email address!';
                                            }
                                            return null;
                                          },
                                          textInputAction: TextInputAction.next,
                                          nextFieldFocusNode:
                                              _signupPasswordFocusNode,
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        AppTextFormField(
                                          focusNode: _signupPasswordFocusNode,
                                          labelText: 'Password',
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter a Password!';
                                            } else if (value.length < 6) {
                                              return 'Please enter at least 6 characters!';
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
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  AppButton(
                                    appText: const AppText(
                                      text: 'Sign up',
                                      color: AppColors.white,
                                      size: 22,
                                      letterSpacing: 5,
                                    ),
                                    onPressed: () async {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();

                                      if (_signupFormKey.currentState!
                                          .validate()) {
                                        // call the onSave function defined in the form fields
                                        _signupFormKey.currentState!.save();

                                        List response =
                                            await AppAuthentication.signUp(
                                                _username, _email, _password);

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
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const AppText(
                            text: 'Have an account already?',
                            weight: AppFonts.weightLight,
                          ),
                          GestureDetector(
                            onTap: () {
                              _loginOverlay.open();
                              close();
                            },
                            child: const AppText(
                              textAlign: TextAlign.center,
                              text: 'Log in',
                              letterSpacing: 3,
                            ),
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
  );
}
