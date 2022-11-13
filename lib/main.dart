import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/fonts.dart';
import 'package:virkey/routing/router.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: AppRouter.router,
      title: 'VirKey',
      theme: ThemeData(
        primaryColor: AppColors.primary,
        fontFamily: AppFonts.primary,
      ),
    );
  }
}
