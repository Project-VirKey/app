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

          return Container(
            color: AppColors.secondary,
            child: const SafeArea(child: HomeScreen()),
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

          return const PianoScreen();
        },
      ),
    ],
  );
}
