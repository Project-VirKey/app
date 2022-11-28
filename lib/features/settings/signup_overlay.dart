import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:virkey/common_widgets/app_button.dart';
import 'package:virkey/common_widgets/app_icon.dart';
import 'package:virkey/features/settings/login_overlay.dart';
import 'package:virkey/utils/overlay.dart';
import 'package:virkey/common_widgets/app_text.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/fonts.dart';

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
      Expanded(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(11),
            child: Column(
              children: [
                Padding(
                  padding: MediaQuery.of(context).orientation ==
                          Orientation.landscape
                      ? EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * .15)
                      : EdgeInsets.zero,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppButton(
                        appText: const AppText(
                          text: 'Sign up',
                          color: AppColors.white,
                          size: 22,
                          letterSpacing: 5,
                        ),
                        onPressed: () => {print('Sign up')},
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
                        text: 'Have an account already?',
                        weight: AppFonts.weightLight,
                      ),
                      GestureDetector(
                        onTap: () => {_loginOverlay.open(), close()},
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
      ),
    ],
  );
}
