import 'package:flutter/material.dart';
import 'package:virkey/common_widgets/app_shadow.dart';
import 'package:virkey/common_widgets/app_text.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/radius.dart';

class AppButton extends StatelessWidget {
  const AppButton(
      {Key? key,
      required this.appText,
      required this.onPressed,
      this.backgroundColor})
      : super(key: key);

  final AppText appText;
  final dynamic onPressed;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: AppShadow(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? AppColors.primary,
            padding: const EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 50,
            ),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(AppRadius.radius)),
          ),
          onPressed: onPressed,
          child: appText,
        ),
      ),
    );
  }
}
