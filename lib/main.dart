import 'package:flutter/material.dart';

import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/fonts.dart';
import 'package:virkey/routing/router.dart';
import 'package:virkey/utils/platform_helper.dart';
import 'package:window_size/window_size.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (PlatformHelper.isDesktop) {
    // setWindowTitle('My App');
    // setWindowMaxSize(const Size(max_width, max_height));
    setWindowMinSize(const Size(650, 550));
  }

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
        primaryColor: AppColors.secondary,
        primarySwatch: Colors.grey,
        fontFamily: AppFonts.primary,
      ),
    );
  }
}
