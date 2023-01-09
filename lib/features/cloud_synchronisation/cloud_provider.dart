import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:virkey/features/cloud_synchronisation/firestore.dart';
import 'package:virkey/features/settings/settings_model.dart' as app_settings;
import 'package:virkey/features/settings/settings_provider.dart';

class CloudProvider extends ChangeNotifier {
  final Cloud _cloud = Cloud(loggedIn: false);

  Cloud get cloud => _cloud;

  bool get loggedIn => _cloud.loggedIn;

  CloudProvider(this.settingsProvider) {
    checkAuthStatus();
    test();
  }

  SettingsProvider settingsProvider;

  setSettingsProvider(SettingsProvider sP) {
    settingsProvider = sP;
    notifyListeners();
  }

  void checkAuthStatus() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
        _cloud.loggedIn = false;
      } else {
        // do not print user on windows => causes exception
        // print(user);
        print('User is signed in!');
        _cloud.loggedIn = true;
        _cloud.user = user;
      }
      notifyListeners();
    });
  }

  void reload() async {
    FirebaseAuth.instance.currentUser?.reload();
    notifyListeners();
  }

  void synchronise(app_settings.Settings settings) async {
    print(settings.lastUpdated);
  }

  bool isLocalLatest(int localTimestamp, int cloudTimestamp) {
    return localTimestamp > cloudTimestamp;
  }

  Future<void> test() async {
    for (var soundLibrary in settingsProvider.settings.soundLibraries) {
      print(soundLibrary.name);
    }
    print(AppFirestore.document);
  }
}

class Cloud {
  Cloud({required this.loggedIn});

  bool loggedIn;
  User? user;
}
