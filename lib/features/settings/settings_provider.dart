import 'dart:io';

import 'package:flutter/material.dart';
import 'package:virkey/features/piano/piano.dart';
import 'package:virkey/features/settings/settings_model.dart';
import 'package:virkey/features/settings/settings_shared_preferences.dart';
import 'package:virkey/utils/file_system.dart';
import 'package:virkey/utils/platform_helper.dart';

class SettingsProvider extends ChangeNotifier {
  final Settings _settings = Settings(
      audioVolume: AudioVolume(soundLibrary: 100, audioPlayback: 100),
      defaultFolder: DefaultFolder(path: AppFileSystem.basePath ?? ''),
      defaultSavedFiles: DefaultSavedFiles(wav: false, wavAndPlayback: false),
      soundLibraries: [],
      introDisplayed: false);

  int lastUpdated = 0;

  Settings get settings => _settings;

  SettingsProvider() {
    initialLoad();
  }

  void notify() {
    notifyListeners();
  }

  Future<void> initialLoad() async {
    await loadSoundLibraries();
    _settings.defaultFolder.path = AppFileSystem.basePath ?? '';

    // load the data from SharedPreferences when the Provider is placed
    lastUpdated =
        AppSharedPreferences.loadedSharedPreferences?['lastUpdated'] ?? 0;
    Settings? loadedSettings =
        AppSharedPreferences.loadedSharedPreferences?['settings'];

    if (loadedSettings == null) {
      AppSharedPreferences.saveData(settings: _settings);
    }

    if (loadedSettings != null) {
      _settings.audioVolume = loadedSettings.audioVolume;
      _settings.introDisplayed = loadedSettings.introDisplayed;
      if (PlatformHelper.isDesktop &&
          loadedSettings.defaultFolder.path.isNotEmpty) {
        _settings.defaultFolder = loadedSettings.defaultFolder;
      }
      _settings.defaultSavedFiles.wav = loadedSettings.defaultSavedFiles.wav;
      _settings.defaultSavedFiles.wavAndPlayback =
          loadedSettings.defaultSavedFiles.wavAndPlayback;

      SoundLibrary? selectedLibrary = loadedSettings.soundLibraries
          .where((soundLibrary) => soundLibrary.selected)
          .first;

      for (var i = 0; i < _settings.soundLibraries.length; i++) {
        int loadedSoundLibraryIndex = loadedSettings.soundLibraries.indexWhere(
            (SoundLibrary soundLibrary) =>
                soundLibrary.name == _settings.soundLibraries[i].name);

        if (loadedSoundLibraryIndex != -1) {
          _settings.soundLibraries[i].url =
              loadedSettings.soundLibraries[i].url;
        }

        _settings.soundLibraries[i].selected =
            _settings.soundLibraries[i].name == selectedLibrary.name;
      }
    }

    // load the selected sound library
    SoundLibrary soundLibrary = _settings.soundLibraries
        .where((soundLibrary) => soundLibrary.selected)
        .first;
    Piano.loadLibrary(soundLibrary.path, _settings.audioVolume.soundLibrary,
        soundLibrary.defaultLibrary);

    print('------------------');
    // print(loadedSettings?.toJson());
    print(_settings.toJson());
    print('------------------');
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
            AppFileSystem.soundLibrariesFolder));

    if (folderSoundLibraries != null) {
      folderSoundLibraries =
          AppFileSystem.filterFilesList(folderSoundLibraries, ['sf2']);

      for (var element in folderSoundLibraries) {
        _settings.soundLibraries.add(SoundLibrary(
            name: AppFileSystem.getFilenameWithoutExtension(element.path),
            selected: false,
            path: element.path,
            url: '',
            defaultLibrary: false));
      }
    }

    // notify listeners to rebuild affected components
    notifyListeners();
  }

  void selectSoundLibrary(SoundLibrary selectedSoundLibrary) {
    for (var soundLibrary in _settings.soundLibraries) {
      soundLibrary.selected = false;
    }

    selectedSoundLibrary.selected = true;

    // load the selected sound library
    Piano.loadLibrary(
        selectedSoundLibrary.path,
        _settings.audioVolume.soundLibrary,
        selectedSoundLibrary.defaultLibrary);

    AppSharedPreferences.saveData(settings: _settings);
    notifyListeners();
  }

  Future<void> resetBasePath() async {
    await updateBasePath(await AppFileSystem.getBasePath());
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

      AppSharedPreferences.saveData(settings: _settings);
      notifyListeners();
    }
  }

  void setAudioVolumeSoundLibrary(double value) {
    int intValue = value.toInt();

    if (_settings.audioVolume.soundLibrary != intValue) {
      _settings.audioVolume.soundLibrary = intValue;
      notifyListeners();
    }
  }

  void setAudioVolumeAudioPlayback(double value) {
    int intValue = value.toInt();

    if (_settings.audioVolume.audioPlayback != intValue) {
      _settings.audioVolume.audioPlayback = intValue;
      notifyListeners();
    }
  }

  void setIntroDisplayed(bool value) {
    _settings.introDisplayed = value;
    AppSharedPreferences.saveData(settings: _settings);
  }
}
