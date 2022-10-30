import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:virkey/features/piano/piano_screen.dart';
import 'package:virkey/features/settings/settings_overlay.dart';
import 'package:virkey/home_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return const HomeScreen();
        },
      ),
      GoRoute(
        path: '/piano',
        builder: (BuildContext context, GoRouterState state) {
          return const PianoScreen();
        },
      ),
    ],
  );
}
