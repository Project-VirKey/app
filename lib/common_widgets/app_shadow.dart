import 'package:flutter/material.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/radius.dart';

class AppShadow extends StatelessWidget {
  const AppShadow({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(AppRadius.radius),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadowDim, blurRadius: 8, offset: Offset(4, 4)),
        ],
      ),
      child: child,
    );
  }
}
