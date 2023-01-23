import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:virkey/features/cloud_synchronisation/firestore.dart';
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

  void synchronise() async {
    print(settingsProvider.lastUpdated);
  }

  bool isLocalLatest(int localTimestamp, int cloudTimestamp) {
    return localTimestamp > cloudTimestamp;
  }

  Future<void> test() async {
    for (var soundLibrary in settingsProvider.settings.soundLibraries) {
      print(soundLibrary.name);
    }

    print(AppFirestore.document);

    if (AppFirestore.document == null) {
      print('upload to cloud');
      AppFirestore.setDocument(createCloudJson());
    } else if (AppFirestore.document!['lastUpdated'] == null) {
      print('upload to cloud');
      AppFirestore.setDocument(createCloudJson());
    } else {
      print('check most recent Update');

      // TODO: isLocalLatest is not actually the correct timestamp -> correction needed
      if (isLocalLatest(settingsProvider.lastUpdated,
          AppFirestore.document!['lastUpdated'])) {
        print('download from cloud');
      } else {
        print('upload to cloud');
        AppFirestore.setDocument(createCloudJson());
      }
    }

    print(createCloudJson());
  }

  void setFromCloud() {
    settingsProvider.lastUpdated = AppFirestore.document?['lastUpdated'];
    settingsProvider.settings.audioVolume =
    AppFirestore.document?['settings']['audioVolume'];
    settingsProvider.settings.audioVolume =
    AppFirestore.document?['settings']['defaultSavedFiles'];
    // settingsProvider.selectSoundLibrary(selectedSoundLibrary)


    notifyListeners();
  }

  Map<String, dynamic> createCloudJson() {
    Map<String, dynamic> settings = settingsProvider.settings.toJson();
    settings.remove('defaultFolder');
    int lastUpdated = settingsProvider.lastUpdated;
    settings.remove('lastUpdated');
    for (var soundLibrary in settings['soundLibraries']) {
      soundLibrary.remove('path');
    }

    Map<String, dynamic> result = {
      'lastUpdated': lastUpdated,
      'settings': settings,
      'recordings': []
    };

    return result;
  }
}

class Cloud {
  Cloud({required this.loggedIn});

  bool loggedIn;
  User? user;
}
