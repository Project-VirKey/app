import 'package:flutter/material.dart';
import 'package:virkey/constants/colors.dart';

class AppSlider extends StatelessWidget {
  const AppSlider(
      {Key? key,
      this.value = 0,
      required this.onChanged,
      this.onChangeStart,
      this.onChangedEnd})
      : super(key: key);

  final double value;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChangedEnd;

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
          thumbShape: CircleSliderThumb(thumbRadius: 18, sliderValue: value),
          trackHeight: 5,
          overlayColor: AppColors.dark.withOpacity(.2),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
          activeTrackColor: AppColors.primary,
          inactiveTrackColor: AppColors.tertiary),
      child: Slider(
        value: value,
        min: 0,
        max: 100,
        onChangeStart: (value) {
          if (onChangeStart != null) {
            onChangeStart!(value);
          }
        },
        onChanged: (value) {
          onChanged(value);
        },
        onChangeEnd: (value) {
          if (onChangedEnd != null) {
            onChangedEnd!(value);
          }
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
    final Paint outerPathColor = Paint()
      ..color = AppColors.dark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    Path outerPath = Path();

    outerPath.addOval(Rect.fromCircle(
      center: center,
      radius: 9.0,
    ));

    outerPath.close();
    canvas.drawPath(outerPath, outerPathColor);

    // inner Path
    Paint innerPathColor = Paint()
      ..color = AppColors.secondary
      ..style = PaintingStyle.fill;

    Path innerPath = Path();

    innerPath.addOval(Rect.fromCircle(
      center: center,
      radius: 9.0,
    ));

    innerPath.close();
    canvas.drawPath(innerPath, innerPathColor);
  }
}
