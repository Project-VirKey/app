import 'package:flutter/material.dart';

import 'package:virkey/constants/colors.dart';

class AppSlider extends StatefulWidget {
  AppSlider({Key? key, this.value = 0, required this.onChanged, this.onChangedEnd})
      : super(key: key);

  double value;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangedEnd;

  @override
  State<AppSlider> createState() => _AppSliderState();
}

class _AppSliderState extends State<AppSlider> {
  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
          thumbShape:
              CircleSliderThumb(thumbRadius: 18, sliderValue: widget.value),
          trackHeight: 5,
          overlayColor: AppColors.dark.withOpacity(.2),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
          activeTrackColor: AppColors.primary,
          inactiveTrackColor: AppColors.tertiary),
      child: Slider(
        value: widget.value,
        min: 0,
        max: 100,
        onChanged: (value) {
          setState(() {
            widget.value = value;
            widget.onChanged(widget.value);
          });
        },
        onChangeEnd: (value) {
          widget.onChangedEnd!(widget.value);
        },
      ),
    );
  }
}

class CircleSliderThumb extends SliderComponentShape {
  // https://blog.logrocket.com/flutter-slider-widgets-deep-dive-with-examples, 21.11.2022

  final double thumbRadius;
  final double sliderValue;

  const CircleSliderThumb({
    required this.thumbRadius,
    required this.sliderValue,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(PaintingContext context, Offset center,
      {required Animation<double> activationAnimation,
      required Animation<double> enableAnimation,
      required bool isDiscrete,
      required TextPainter labelPainter,
      required RenderBox parentBox,
      required SliderThemeData sliderTheme,
      required TextDirection textDirection,
      required double value,
      required double textScaleFactor,
      required Size sizeWithOverflow}) {
    final Canvas canvas = context.canvas;

    // outer path
    final outerPathColor = Paint()
      ..color = AppColors.dark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    var outerPath = Path();

    outerPath.addOval(Rect.fromCircle(
      center: center,
      radius: 9.0,
    ));

    outerPath.close();
    canvas.drawPath(outerPath, outerPathColor);

    // inner Path
    final innerPathColor = Paint()
      ..color = AppColors.secondary
      ..style = PaintingStyle.fill;

    var innerPath = Path();

    innerPath.addOval(Rect.fromCircle(
      center: center,
      radius: 9.0,
    ));

    innerPath.close();
    canvas.drawPath(innerPath, innerPathColor);
  }
}
