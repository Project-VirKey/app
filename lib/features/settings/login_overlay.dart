import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:virkey/common_widgets/app_button.dart';
import 'package:virkey/common_widgets/app_icon.dart';
import 'package:virkey/constants/radius.dart';
import 'package:virkey/features/settings/signup_overlay.dart';
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(11),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: MediaQuery.of(context).orientation ==
                          Orientation.landscape
                      ? EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * .16)
                      : EdgeInsets.zero,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: Form(
                          key: _loginFormKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                margin: const EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    AppTextFormField(
                                      parentContext: context,
                                      labelText: 'E-Mail',
                                      onSaved: (value) =>
                                          {print('onSaved: $value')},
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter some text';
                                        }
                                        return null;
                                      },
                                    ),
                                    AppTextFormField(
                                      parentContext: context,
                                      labelText: 'Password',
                                      onFieldSubmitted: (value) =>
                                          {print(value)},
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter some text';
                                        }
                                        return null;
                                      },
                                      onSaved: (value) =>
                                          {print('onSaved: $value')},
                                    ),
                                  ],
                                ),
                              ),
                              AppButton(
                                appText: const AppText(
                                  text: 'Log in',
                                  color: AppColors.white,
                                  size: 22,
                                  letterSpacing: 5,
                                ),
                                onPressed: () =>
                                    {_loginFormKey.currentState?.validate()},
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => {},
                        child: const AppText(
                          textAlign: TextAlign.center,
                          text: 'Forgot Password?',
                          letterSpacing: 3,
                        ),
                      ),
                      const AppText(
                        text: 'Don\'t have an account?',
                        weight: AppFonts.weightLight,
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
        ),
      ),
    ],
  );
}

class AppTextFormField extends StatelessWidget {
  const AppTextFormField({
    Key? key,
    required this.parentContext,
    required this.labelText,
    this.onFieldSubmitted,
    required this.onSaved,
    required this.validator,
  }) : super(key: key);

  final BuildContext parentContext;
  final String labelText;
  final dynamic onFieldSubmitted;
  final Function(String?) onSaved;
  final Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    final FocusNode focusNode = FocusNode();

    return GestureDetector(
      onTap: () => {
        FocusScope.of(parentContext).requestFocus(focusNode),
      },
      child: TextFormField(
        validator: (value) {
          String? validation = validator(value);
          if (validation == null) {
            onSaved(value);
          }
          return validation;
        },
        onFieldSubmitted: (value) => onFieldSubmitted,
        maxLines: 1,
        minLines: 1,
        focusNode: focusNode,
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
