import 'package:flutter/material.dart';

import 'package:virkey/constants/colors.dart';

class AppSlider extends StatefulWidget {
  AppSlider({
    Key? key,
    this.value = 0,
    required this.onChanged
  }) : super(key: key);

  double value;
  final ValueChanged<double> onChanged;

  @override
  State<AppSlider> createState() => _AppSliderState();
}

class _AppSliderState extends State<AppSlider> {
  @override
  Widget build(BuildContext context) {
    return Slider(
      value: widget.value,
      min: 0,
      max: 100,
      inactiveColor: AppColors.tertiary,
      activeColor: AppColors.primary,
      thumbColor: AppColors.secondary,
      onChanged: (value) {
        setState(() {
          widget.value = value;
          widget.onChanged(widget.value);
        });

      },
    );
  }
}
