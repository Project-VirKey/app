import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/features/piano/piano_screen.dart';
import 'package:virkey/home_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          // orientation -> portrait
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitDown,
            DeviceOrientation.portraitUp,
          ]);

          // SafeArea: https://stackoverflow.com/questions/49227667/using-safearea-in-flutter, 15.11.2022
          return Container(
            color: AppColors.secondary,
            child: const SafeArea(bottom: false, child: HomeScreen()),
          );
        },
      ),
      GoRoute(
        path: '/piano',
        builder: (BuildContext context, GoRouterState state) {
          // orientation -> landscape
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]);

          // https://api.flutter.dev/flutter/services/SystemChrome/setEnabledSystemUIMode.html
          // hide notification bar
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,
              overlays: null);

          return const PianoScreen();
        },
      ),
    ],
  );
}
