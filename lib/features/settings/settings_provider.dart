import 'dart:io';

import 'package:flutter/material.dart';
import 'package:virkey/features/piano/piano.dart';
import 'package:virkey/features/settings/settings_model.dart';
import 'package:virkey/features/settings/settings_shared_preferences.dart';
import 'package:virkey/utils/file_system.dart';
import 'package:virkey/utils/platform_helper.dart';
import 'package:virkey/utils/timestamp.dart';

class SettingsProvider extends ChangeNotifier {
  final Settings _settings = Settings(
    audioVolume: AudioVolume(soundLibrary: 0, audioPlayback: 0),
    defaultFolder: DefaultFolder(path: AppFileSystem.basePath ?? ''),
    defaultSavedFiles: DefaultSavedFiles(wav: false, wavAndPlayback: false),
    soundLibraries: [],
    lastUpdated: AppTimestamp.now,
  );

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
      _settings.defaultSavedFiles.wav = loadedSettings.defaultSavedFiles.wav;
      _settings.defaultSavedFiles.wavAndPlayback =
          loadedSettings.defaultSavedFiles.wavAndPlayback;

      SoundLibrary? selectedLibrary = loadedSettings.soundLibraries
          .where((soundLibrary) => soundLibrary.selected)
          .first;

      for (var soundLibrary in _settings.soundLibraries) {
        soundLibrary.selected = soundLibrary.name == selectedLibrary.name;
      }
    }

    // load the selected sound library
    SoundLibrary soundLibrary = _settings.soundLibraries
        .where((soundLibrary) => soundLibrary.selected)
        .first;
    Piano.loadLibrary(soundLibrary.path, soundLibrary.defaultLibrary);
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

  Settings get settings => _settings;

  void selectSoundLibrary(SoundLibrary selectedSoundLibrary) {
    for (var soundLibrary in _settings.soundLibraries) {
      soundLibrary.selected = false;
    }

    selectedSoundLibrary.selected = true;

    // load the selected sound library
    Piano.loadLibrary(
        selectedSoundLibrary.path, selectedSoundLibrary.defaultLibrary);

    AppSharedPreferences.saveData(_settings);
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

      AppSharedPreferences.saveData(_settings);
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
}
