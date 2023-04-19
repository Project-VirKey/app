import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:virkey/features/cloud_synchronisation/cloud_storage.dart';
import 'package:virkey/features/cloud_synchronisation/firestore.dart';
import 'package:virkey/features/piano/piano.dart';
import 'package:virkey/features/recordings/recordings_provider.dart';
import 'package:virkey/features/settings/settings_model.dart' as settings_model;
import 'package:virkey/features/settings/settings_provider.dart';
import 'package:virkey/features/settings/settings_shared_preferences.dart';
import 'package:virkey/firebase_options.dart';
import 'package:virkey/utils/file_system.dart';

class CloudProvider extends ChangeNotifier {
  final Cloud _cloud = Cloud(loggedIn: false);

  Cloud get cloud => _cloud;

  bool get loggedIn => _cloud.loggedIn;

  CloudProvider(this._settingsProvider, this._recordingsProvider) {
    initialLoad();
  }

  Future<void> initialLoad() async {
    // cloud-synchronization
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // reload authentication on start-up
    try {
      await FirebaseAuth.instance.currentUser?.reload();
    } catch (e) {
      print(e);
    }

    checkAuthStatus();

    // load firestore document
    await AppFirestore.initialLoad();

    // load storage reference
    await AppCloudStorage.initialLoad();

    test();
  }

  SettingsProvider _settingsProvider;
  RecordingsProvider _recordingsProvider;

  setSettingsProvider(SettingsProvider sP) {
    _settingsProvider = sP;
    notifyListeners();
  }

  setRecordingsProvider(RecordingsProvider rP) {
    _recordingsProvider = rP;
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
    await AppFirestore.initialLoad();
    await test();
    notifyListeners();
  }

  bool isLocalLatest(int localTimestamp, int cloudTimestamp) {
    return localTimestamp > cloudTimestamp;
  }

  Future<void> test() async {
    print(_settingsProvider.settings.toJson());

    // sync settings (key-value pairs)
    if (AppFirestore.remoteDocument == null ||
        AppFirestore.remoteDocument!['lastUpdated'] == null) {
      print('upload to cloud 01');
      // upload to cloud
      AppFirestore.setDocument(createCloudJson());
    } else {
      print('check most recent Update');

      print(
          '----- local: ${_settingsProvider.lastUpdated} * remote: ${AppFirestore.remoteDocument!['lastUpdated']} => ${isLocalLatest(_settingsProvider.lastUpdated, AppFirestore.remoteDocument!['lastUpdated'])} -----');

      if (_settingsProvider.lastUpdated !=
          AppFirestore.remoteDocument!['lastUpdated']) {
        if (isLocalLatest(_settingsProvider.lastUpdated,
            AppFirestore.remoteDocument!['lastUpdated'])) {
          print('upload to cloud 02');
          // upload local version
          AppFirestore.setDocument(createCloudJson());
        } else {
          print('download from cloud');
          // download remote version
          setSettingsFromCloud();
        }
      }
    }

    // sync files
    await syncSoundFonts();

    // setCorrectSoundFont();

    // await syncRecordings();

    print(createCloudJson());
  }

  Future<void> setCorrectSoundFont() async {
    // TODO: does not work :(
    // compare Piano.path and current soundfont path

    /*
    settings_model.SoundLibrary soundLibrary = _settingsProvider
        .settings.soundLibraries
        .where((soundLibrary) => soundLibrary.selected)
        .first;
    Piano.loadLibrary(
        soundLibrary.path,
        _settingsProvider.settings.audioVolume.soundLibrary,
        soundLibrary.defaultLibrary);
     */

    settings_model.SoundLibrary? selectedLibrary;

    selectedLibrary = _settingsProvider.settings.soundLibraries
        .where((soundLibrary) => soundLibrary.selected)
        .first;

    print(selectedLibrary);
    print(selectedLibrary.path);
    print(Piano.loadedLibraryPath);

    if (selectedLibrary != null) {
      print('selected SF2 - ${selectedLibrary.name}');
    } else {
      print('no sound library is active');
    }
  }

  Future<void> syncRecordings() async {
    print(_recordingsProvider.recordings);

    // -------

    for (var remoteRecording in AppFirestore.remoteDocument?['settings']
        ['recordings']) {
      int localRecordingIndex = _recordingsProvider.recordings.indexWhere(
          (Recording recording) => remoteRecording['title'] == recording.title);

      if (remoteRecording['deleted'] != null) {
        print('continue on recording');
        continue;
      }

      String localRecordingUrl = localRecordingIndex == -1
          ? ''
          : _recordingsProvider.recordings[localRecordingIndex].url;

      bool localRecordingAvailable = localRecordingIndex != -1;
      bool remoteUrlSet = remoteRecording['url'].isNotEmpty;

      if (remoteUrlSet && !localRecordingAvailable) {
        print('download recording');
        bool downloadSuccess = await AppCloudStorage.downloadFile(
            '${remoteRecording['title'].mid}',
            AppFileSystem.recordingsFolderPath);

        if (downloadSuccess) {
          _recordingsProvider.addRecordingItem(Recording(
              title: AppFileSystem.getFilenameWithoutExtension(
                  '${AppFileSystem.recordingsFolderPath}${remoteRecording['title'].mid}'),
              path:
                  '${AppFileSystem.recordingsFolderPath}${remoteRecording['title'].mid}',
              url: remoteRecording['url']));
        }
        // else:
        // if download was not successful -> sound-font will not be added to local recordings
        // when uploading back to cloud the recording will be removed
      }

      if (!remoteUrlSet && !localRecordingAvailable) {
        print('delete online entry');
        // to delete online entry -> nothing has to be done when it is locally not available
      }

      if (remoteUrlSet && localRecordingAvailable) {
        if (localRecordingUrl.isEmpty) {
          _recordingsProvider.recordings[localRecordingIndex].url =
              remoteRecording['url'];
        }
      }

      if (!remoteUrlSet && localRecordingAvailable) {
        String? cloudUrl = await AppCloudStorage.uploadFromFile(
            _recordingsProvider.recordings[localRecordingIndex].path);
        if (cloudUrl != null) {
          _recordingsProvider.recordings[localRecordingIndex].url = cloudUrl;
        }
      }
    }

    for (var localRecording in _recordingsProvider.recordings) {
      int remoteRecordingIndex =
          AppFirestore.remoteDocument?['settings']['recordings'].indexWhere(
              (var recording) => recording['title'] == localRecording.title);

      if (remoteRecordingIndex == -1) {
        print('$remoteRecordingIndex - ${localRecording.title}');

        String? cloudUrl =
            await AppCloudStorage.uploadFromFile(localRecording.path);
        if (cloudUrl != null) {
          localRecording.url = cloudUrl;
        }
      }
    }

    AppFirestore.setDocument(createCloudJson());
  }

  Future<void> syncSoundFonts() async {
    bool changes = false;

    // sync sound-libraries
    for (var remoteSoundLibrary in AppFirestore.remoteDocument?['settings']
        ['soundLibraries']) {
      int localSoundLibraryIndex = _settingsProvider.settings.soundLibraries
          .indexWhere((settings_model.SoundLibrary localSoundLibrary) =>
              remoteSoundLibrary['name'] == localSoundLibrary.name);

      if (remoteSoundLibrary['defaultLibrary']) {
        print('continue on default soundfont');
        continue;
      }

      if (remoteSoundLibrary['deleted'] != null) {
        if (remoteSoundLibrary['deleted']) {
          print('continue on deleted soundfont');
          // TODO: implement way to re-upload sound-font marked as deleted
          continue;
        } else if (localSoundLibraryIndex == -1) {
          // TODO: delete remote file
          AppCloudStorage.deleteFile(remoteSoundLibrary['url']);
          continue;
        }
      }

      String localSoundLibraryUrl = localSoundLibraryIndex == -1
          ? ''
          : _settingsProvider
              .settings.soundLibraries[localSoundLibraryIndex].url;

      bool localSoundLibraryAvailable = localSoundLibraryIndex != -1;
      bool remoteUrlSet = remoteSoundLibrary['url'].isNotEmpty;

      if (remoteUrlSet && !localSoundLibraryAvailable) {
        print('download SoundFont');
        bool downloadSuccess = await AppCloudStorage.downloadFile(
            '${remoteSoundLibrary['name']}.sf2',
            AppFileSystem.soundLibrariesFolderPath);

        if (downloadSuccess) {
          _settingsProvider.settings.soundLibraries.add(settings_model.SoundLibrary(
              name: AppFileSystem.getFilenameWithoutExtension(
                  '${AppFileSystem.soundLibrariesFolderPath}${remoteSoundLibrary['name']}.sf2'),
              selected: false,
              path:
                  '${AppFileSystem.soundLibrariesFolderPath}${remoteSoundLibrary['name']}.sf2',
              url: remoteSoundLibrary['url'],
              defaultLibrary: false));
          changes = true;
        }
        // else:
        // if download was not successful -> sound-font will not be added to local sound-fonts
        // when uploading back to cloud the sound-font will be removed
      }

      if (!remoteUrlSet && !localSoundLibraryAvailable) {
        print('delete online entry');
        // to delete online entry -> nothing has to be done when it is locally not available
      }

      if (remoteUrlSet && localSoundLibraryAvailable) {
        if (localSoundLibraryUrl.isEmpty) {
          _settingsProvider.settings.soundLibraries[localSoundLibraryIndex]
              .url = remoteSoundLibrary['url'];
          changes = true;
        }
      }

      print(
          'SF Name ${_settingsProvider.settings.soundLibraries[localSoundLibraryIndex].name}');

      if (!remoteUrlSet && localSoundLibraryAvailable) {
        String? cloudUrl = await AppCloudStorage.uploadFromFile(
            _settingsProvider
                .settings.soundLibraries[localSoundLibraryIndex].path);
        if (cloudUrl != null) {
          _settingsProvider
              .settings.soundLibraries[localSoundLibraryIndex].url = cloudUrl;
          changes = true;
        }
      }
    }

    for (var localSoundLibrary in _settingsProvider.settings.soundLibraries) {
      int remoteSoundLibraryIndex = AppFirestore.remoteDocument?['settings']
              ['soundLibraries']
          .indexWhere((var soundLibrary) =>
              soundLibrary['name'] == localSoundLibrary.name);

      if (remoteSoundLibraryIndex == -1) {
        print('$remoteSoundLibraryIndex - ${localSoundLibrary.name}');

        String? cloudUrl =
            await AppCloudStorage.uploadFromFile(localSoundLibrary.path);
        if (cloudUrl != null) {
          localSoundLibrary.url = cloudUrl;
          changes = true;
        }
      }
    }

    if (changes) {
      print('upload to cloud 03');
      AppFirestore.setDocument(createCloudJson(), ignoreLastUpdated: true);
    }
  }

  Future<void> setSettingsFromCloud() async {
    _settingsProvider.lastUpdated = AppFirestore.remoteDocument?['lastUpdated'];

    _settingsProvider.settings.audioVolume = settings_model.AudioVolume(
        soundLibrary: AppFirestore.remoteDocument?['settings']['audioVolume']
            ['soundLibrary'],
        audioPlayback: AppFirestore.remoteDocument?['settings']['audioVolume']
            ['audioPlayback']);

    _settingsProvider.settings.defaultSavedFiles =
        settings_model.DefaultSavedFiles(
            wav: AppFirestore.remoteDocument?['settings']
                ['defaultSavedFiles']['wav'],
            wavAndPlayback: AppFirestore.remoteDocument?['settings']
                ['defaultSavedFiles']['wavAndPlayback']);

    print('#########');
    print(_settingsProvider.settings.toJson());
    print('#########');
    // AppFirestore.setDocument(createCloudJson());

    AppSharedPreferences.saveData(settings: _settingsProvider.settings);

    print(AppSharedPreferences.loadData());

    notifyListeners();
  }

  Map<String, dynamic> createCloudJson() {
    Map<String, dynamic> settings = _settingsProvider.settings.toJson();
    print(settings);
    settings.remove('defaultFolder');
    int lastUpdated = _settingsProvider.lastUpdated;
    settings.remove('lastUpdated');
    settings.remove('introDisplayed');
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
