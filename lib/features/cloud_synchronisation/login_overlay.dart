import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:virkey/common_widgets/app_button.dart';
import 'package:virkey/common_widgets/app_icon.dart';
import 'package:virkey/constants/radius.dart';
import 'package:virkey/features/cloud_synchronisation/authentication.dart';
import 'package:virkey/features/cloud_synchronisation/signup_overlay.dart';
import 'package:virkey/utils/overlay.dart';
import 'package:virkey/common_widgets/app_text.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/fonts.dart';

class LoginOverlay {
  final BuildContext context;
  final TickerProvider vsync;

  LoginOverlay({
    required this.context,
    required this.vsync,
  });

  void close() {
    _overlay.close();
  }

  void open() {
    _overlay.open();
  }

  late final SignupOverlay _signupOverlay =
      SignupOverlay(context: context, vsync: vsync);

  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  final FocusNode _loginEmailFocusNode = FocusNode();
  final FocusNode _loginPasswordFocusNode = FocusNode();

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
                      text: 'Login',
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
                                  MediaQuery.of(context).size.width * .16)
                          : EdgeInsets.zero,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: Form(
                              key: _loginFormKey,
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      children: [
                                        AppTextFormField(
                                          focusNode: _loginEmailFocusNode,
                                          labelText: 'E-Mail',
                                          onSaved: (value) =>
                                              {_email = value ?? ''},
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter some text';
                                            }
                                            return null;
                                          },
                                          textInputAction:
                                              TextInputAction.next,
                                          nextFieldFocusNode:
                                              _loginPasswordFocusNode,
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        AppTextFormField(
                                          focusNode: _loginPasswordFocusNode,
                                          labelText: 'Password',
                                          onFieldSubmitted: (value) =>
                                              {print('onSubmit: $value')},
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter some text';
                                            }
                                            return null;
                                          },
                                          onSaved: (value) =>
                                              {_password = value ?? ''},
                                          textInputAction:
                                              TextInputAction.done,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  AppButton(
                                    appText: const AppText(
                                      text: 'Log in',
                                      color: AppColors.white,
                                      size: 22,
                                      letterSpacing: 5,
                                    ),
                                    onPressed: () {
                                      // call the validate function defined in the form fields
                                      // if the validation was successful -> returns true
                                      if (_loginFormKey.currentState!
                                          .validate()) {
                                        // call the onSave function defined in the form fields
                                        _loginFormKey.currentState!.save();

                                        AppAuthentication.logIn(
                                            _email, _password);
                                        close();
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
                          GestureDetector(
                            onTap: () => {},
                            child: const AppText(
                              textAlign: TextAlign.center,
                              text: 'Forgot Password?',
                              letterSpacing: 3,
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          const AppText(
                            text: 'Don\'t have an account?',
                            weight: AppFonts.weightLight,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          GestureDetector(
                            onTap: () => {_signupOverlay.open(), close()},
                            child: const AppText(
                              textAlign: TextAlign.center,
                              text: 'Sign up',
                              letterSpacing: 3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    ],
  );
}

class AppTextFormField extends StatelessWidget {
  const AppTextFormField({
    Key? key,
    required this.labelText,
    this.onFieldSubmitted,
    required this.onSaved,
    required this.validator,
    required this.textInputAction,
    required this.focusNode,
    this.nextFieldFocusNode,
  }) : super(key: key);

  final String labelText;
  final dynamic onFieldSubmitted;
  final Function(String?) onSaved;
  final Function(String?) validator;
  final TextInputAction textInputAction;
  final FocusNode focusNode;
  final FocusNode? nextFieldFocusNode;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {
        FocusScope.of(context).requestFocus(focusNode),
      },
      child: TextFormField(
        focusNode: focusNode,
        validator: (value) {
          return validator(value);
        },
        onSaved: (value) {
          onSaved(value);
        },
        onFieldSubmitted: (value) {
          // if true -> there is a following field
          if (textInputAction == TextInputAction.next) {
            // set the focus to the following field through the passed focus node
            FocusScope.of(context).requestFocus(nextFieldFocusNode);
          }
        },
        textInputAction: textInputAction,
        maxLines: 1,
        minLines: 1,
        style: const TextStyle(
            letterSpacing: 3, fontSize: 16, fontWeight: AppFonts.weightLight),
        decoration: InputDecoration(
          isDense: true,
          labelText: labelText,
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(AppRadius.radius),
            borderSide: BorderSide(color: AppColors.dark),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(AppRadius.radius),
            borderSide: BorderSide(color: AppColors.dark),
          ),
        ),
      ),
    );
  }
}
