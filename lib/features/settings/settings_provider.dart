import 'dart:io';

import 'package:flutter/material.dart';
import 'package:virkey/features/piano/piano_key.dart';
import 'package:virkey/features/settings/settings_model.dart';
import 'package:virkey/features/settings/settings_shared_preferences.dart';
import 'package:virkey/utils/file_system.dart';
import 'package:virkey/utils/platform_helper.dart';

class SettingsProvider extends ChangeNotifier {
  final Settings _settings = Settings(
    audioVolume: AudioVolume(soundLibrary: 0, audioPlayback: 0),
    defaultFolder: DefaultFolder(path: AppFileSystem.basePath ?? ''),
    defaultSavedFiles: DefaultSavedFiles(mp3: false, mp3AndPlayback: false),
    soundLibraries: [],
  );

  SettingsProvider() {
    initialLoad();
  }

  Future<void> initialLoad() async {
    await loadSoundLibraries();
    _settings.defaultFolder.path = AppFileSystem.basePath ?? '';

    // load the data from SharedPreferences when the Provider is placed
    Settings? loadedSettings = await AppSharedPreferences.loadData();
    if (loadedSettings == null) {
      AppSharedPreferences.saveData(_settings);
    }

    if (loadedSettings != null) {
      _settings.audioVolume = loadedSettings.audioVolume;
      if (PlatformHelper.isDesktop &&
          loadedSettings.defaultFolder.path.isNotEmpty) {
        _settings.defaultFolder = loadedSettings.defaultFolder;
      }
      _settings.defaultSavedFiles.mp3 = loadedSettings.defaultSavedFiles.mp3;
      _settings.defaultSavedFiles.mp3AndPlayback =
          loadedSettings.defaultSavedFiles.mp3AndPlayback;
    }

    SoundLibrary? selectedLibrary = loadedSettings?.soundLibraries
        .where((soundLibrary) => soundLibrary.selected)
        .first;

    for (var soundLibrary in _settings.soundLibraries) {
      soundLibrary.selected = soundLibrary.name == selectedLibrary?.name;
    }

    // load the selected sound library
    PianoKeys().loadLibrary(_settings.soundLibraries
        .where((soundLibrary) => soundLibrary.selected)
        .first
        .path);
  }

  Future<void> loadSoundLibraries() async {
    _settings.soundLibraries = [];

    _settings.soundLibraries.add(SoundLibrary(
        name: 'Default',
        selected: true,
        path: 'assets/sound_libraries/Grand-Piano.sf2',
        url: '',
        defaultLibrary: true));

    List<FileSystemEntity>? folderSoundLibraries =
        (await AppFileSystem.listFilesInFolder(
            AppFileSystem.soundLibrariesFolder, ['sf2']));

    folderSoundLibraries?.forEach((element) {
      _settings.soundLibraries.add(SoundLibrary(
          name: AppFileSystem.getFilenameWithoutExtension(element.path),
          selected: false,
          path: element.path,
          url: '',
          defaultLibrary: false));
    });

    // notify listeners to rebuild affected components
    notifyListeners();
  }

  Settings get settings => _settings;

  void selectSoundLibrary(SoundLibrary selectedSoundLibrary) {
    for (var soundLibrary in _settings.soundLibraries) {
      soundLibrary.selected = false;
    }

    selectedSoundLibrary.selected = true;

    // load the selected sound library
    PianoKeys().loadLibrary(selectedSoundLibrary.path);

    AppSharedPreferences.saveData(_settings);
    notifyListeners();
  }

  Future<void> resetBasePath() async {
    await updateBasePath(
        await AppFileSystem.getBasePath());
  }

  Future<void> updateBasePath(String? newBasePath) async {
    if (newBasePath != null) {
      if (AppFileSystem.getFilenameFromPath(newBasePath) ==
          AppFileSystem.rootFolderName) {
        AppFileSystem.basePath = newBasePath;
      } else {
        AppFileSystem.basePath =
            newBasePath + Platform.pathSeparator + AppFileSystem.rootFolderName;
        await AppFileSystem.createFolder('');
      }

      await AppFileSystem.createFolder(AppFileSystem.recordingsFolder);
      await AppFileSystem.createFolder(AppFileSystem.soundLibrariesFolder);

      _settings.defaultFolder.path = newBasePath;

      AppSharedPreferences.saveData(_settings);
      notifyListeners();
    }
  }
}
