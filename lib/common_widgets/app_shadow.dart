import 'package:flutter/material.dart';
import 'package:virkey/constants/colors.dart';

class AppShadow extends StatelessWidget {
  const AppShadow({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
              color: AppColors.shadow, blurRadius: 8, offset: Offset(6, 6)),
        ],
      ),
      child: child,
    );
  }
}
