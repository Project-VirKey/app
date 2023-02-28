import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:virkey/common_widgets/app_text.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/fonts.dart';
import 'package:virkey/constants/radius.dart';
import 'package:virkey/features/midi_device/midi_device_provider.dart';
import 'package:wakelock/wakelock.dart';

class PianoPlayButton extends StatefulWidget {
  const PianoPlayButton({Key? key}) : super(key: key);

  @override
  State<PianoPlayButton> createState() => _PianoPlayButtonState();
}

// with SingleTickerProviderStateMixin -> fixing vsync parameter error
// https://stackoverflow.com/a/70089396/17399214, 01.01.2023
class _PianoPlayButtonState extends State<PianoPlayButton>
    with SingleTickerProviderStateMixin {
  // glow animation
  // adapted from https://mightytechno.com/flutter-glow-pulse-animation, 01.01.2023
  late final AnimationController _animationController =
      AnimationController(vsync: this, duration: const Duration(seconds: 1));
  late final Animation _animation =
      Tween(begin: 2.0, end: 6.0).animate(_animationController);

  @override
  void initState() {
    _animation.addListener(() {
      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (Provider.of<MidiDeviceProvider>(context).connected) {
      if (!_animationController.isAnimating) {
        _animationController.repeat(reverse: true);
      }
    } else {
      if (_animationController.isAnimating) {
        _animationController.reset();
      }
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(AppRadius.radius),
        boxShadow: [
          if (_animationController.isAnimating)
            BoxShadow(
              color: AppColors.primary,
              blurRadius: _animation.value,
              spreadRadius: _animation.value,
            ),
        ],
      ),
      child: SizedBox(
        width: 150,
        height: 150,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.dark,
            foregroundColor: AppColors.tertiary,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(AppRadius.radius)),
          ),
          onPressed: () {
            context.go('/piano');

            // enable the wakelock - keep awake
            Wakelock.enable();
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SvgPicture.asset(
                'assets/images/VIK_Logo_v2.svg',
                height: 73,
              ),
              const Padding(
                padding: EdgeInsets.only(top: 7.5),
                child: AppText(
                  text: 'Play',
                  family: AppFonts.secondary,
                  color: AppColors.secondary,
                  letterSpacing: 6,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
