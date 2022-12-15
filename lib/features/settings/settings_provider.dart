import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virkey/features/settings/settings_model.dart';
import 'package:virkey/utils/file_system.dart';

class SettingsProvider extends ChangeNotifier {
  Settings _settings = Settings(
    audioVolume: AudioVolume(soundLibrary: 0, audioPlayback: 0),
    defaultFolder: DefaultFolder(displayName: '/folder/', path: ''),
    defaultSavedFiles: DefaultSavedFiles(mp3: false, mp3AndPlayback: false),
    soundLibraries: [
      // SoundLibrary(name: 'Default Piano', selected: true, path: '', url: ''),
    ],
    account: Account(loggedIn: false),
  );

  SettingsProvider() {
    // load the data from SharedPreferences when the Provider is placed
    // loadData();

    loadSoundLibraries();
  }

  Future<void> loadSoundLibraries() async {
    _settings.soundLibraries.add(SoundLibrary(
        name: 'Default',
        selected: true,
        path: '',
        url: '',
        defaultLibrary: true));

    List<FileSystemEntity>? folderSoundLibraries =
        (await AppFileSystem.listFilesInFolder(
            AppFileSystem.soundLibrariesFolder));

    print(folderSoundLibraries);

    folderSoundLibraries?.forEach((element) {
      _settings.soundLibraries.add(SoundLibrary(
          name: AppFileSystem.getFilenameFromPath(element.path),
          selected: true,
          path: '',
          url: '',
          defaultLibrary: true));
    });
  }

  Settings get settings => _settings;

  void selectSoundLibrary(SoundLibrary soundLibrary) {
    for (var soundLibrary in _settings.soundLibraries) {
      soundLibrary.selected = false;
    }

    soundLibrary.selected = true;

    print(_settings.soundLibraries);

    saveData();
    notifyListeners();
  }

  void saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('settings', settingsToJson(_settings));

    // notify listeners to rebuild affected components
    notifyListeners();
  }

  void loadData() async {
    // Obtain shared preferences.
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('settings')) {
      _settings = settingsFromJson(prefs.getString('settings') ?? '');
    } else {
      prefs.setString('settings', settingsToJson(settings));
    }

    // print(prefs.getString('settings'));

    // prefs.setBool('defaultSavedFileMp3', val);
    // print(prefs.getBool('defaultSavedFileMp3'));

    notifyListeners();
  }
}
