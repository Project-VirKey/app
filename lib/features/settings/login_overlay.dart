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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            margin: const EdgeInsets.all(10),
                            child: Material(
                              color: Colors.transparent,
                              child: AppTextField(
                                parentContext: context,
                              ),
                            ),
                          ),
                          AppButton(
                            appText: const AppText(
                              text: 'Log in',
                              color: AppColors.white,
                              size: 22,
                              letterSpacing: 5,
                            ),
                            onPressed: () => {print('Log in')},
                          ),
                        ],
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

class AppTextField extends StatelessWidget {
  const AppTextField({
    Key? key,
    required this.parentContext,
  }) : super(key: key);

  final BuildContext parentContext;

  @override
  Widget build(BuildContext context) {
    final FocusNode focusNode = FocusNode();

    return GestureDetector(
      onTap: () => {
        // FocusManager.instance.primaryFocus?.unfocus(),
        FocusScope.of(parentContext).requestFocus(focusNode),

        // FocusManager.instance.primaryFocus?.unfocus(),
        // FocusManager.instance.primaryFocus?.requestFocus(focusNode)
      },
      child: TextFormField(
        onTap: () => {},
        onFieldSubmitted: (value) => {print('submitted')},
        maxLines: 1,
        minLines: 1,
        focusNode: focusNode,
        style: const TextStyle(
            letterSpacing: 3, fontSize: 16, fontWeight: AppFonts.weightLight),
        decoration: const InputDecoration(
          isDense: true,
          labelText: 'Password',
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(AppRadius.radius),
            borderSide: BorderSide(color: AppColors.dark),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(AppRadius.radius),
            borderSide: BorderSide(color: AppColors.dark),
          ),
        ),
      ),
    );
  }
}
