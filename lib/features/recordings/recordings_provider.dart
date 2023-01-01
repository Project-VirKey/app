import 'dart:io';

import 'package:flutter/material.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/features/settings/settings_shared_preferences.dart';
import 'package:virkey/utils/file_system.dart';

class RecordingsProvider extends ChangeNotifier {
  final List<Recording> _recordings = [];

  static const Duration expandDuration = Duration(milliseconds: 200);
  final recordingsListKey = GlobalKey<AnimatedListState>();
  bool listExpanded = false;
  bool expandedItem = false;
  bool recordingTitleTextFieldVisible = false;

  static List<FileSystemEntity> _recordingsFileList = [];

  List<Recording> get recordings => _recordings;

  RecordingsProvider() {
    loadRecordings();
  }

  void notifyProviderListeners() {
    notifyListeners();
  }

  Future<void> loadRecordings() async {
    AppFileSystem.basePath =
        (await AppSharedPreferences.loadData())?.defaultFolder.path;
    if (AppFileSystem.basePath == null || AppFileSystem.basePath == '') {
      await AppFileSystem.loadBasePath();
    }

    // get files in recordings folder & filter (with where) for only recordings
    List<FileSystemEntity>? recordingsFileList =
        (await AppFileSystem.listFilesInFolder(
            AppFileSystem.recordingsFolder, ['mid']));

    // print(recordingsFileList);

    _recordingsFileList = recordingsFileList!;
    removeAllRecordingItems();

    // add files recordings list as Recording objects
    for (var recordingFile in recordingsFileList.reversed) {
      Recording recording = Recording(
        title: AppFileSystem.getFilenameWithoutExtension(recordingFile.path),
        path: recordingFile.path,
      );

      addRecordingItem(recording);
      loadPlayback(recording);
    }

    notifyListeners();
  }

  void addRecordingItem(Recording recording) {
    recordings.insert(0, recording);
    if (recordingsListKey.currentState != null) {
      recordingsListKey.currentState!
          .insertItem(0, duration: const Duration(milliseconds: 150));
    }
    notifyListeners();
  }

  void removeRecordingItem(int index) {
    recordingsListKey.currentState!.removeItem(0, (context, animation) {
      return SizeTransition(
        sizeFactor: animation,
        child: Card(
            color: AppColors.secondary,
            child: Container(
              height: 20,
            )),
      );
    }, duration: const Duration(milliseconds: 150));
    recordings.removeAt(index);
    notifyListeners();
  }

  void removeAllRecordingItems() {
    for (var i = 0; i <= recordings.length - 1; i++) {
      recordingsListKey.currentState?.removeItem(0,
          (BuildContext context, Animation<double> animation) {
        return SizeTransition(
          sizeFactor: animation,
          child: Card(
              color: AppColors.secondary,
              child: Container(
                height: 20,
              )),
        );
      }, duration: const Duration(milliseconds: 150));
    }
    recordings.clear();
    notifyListeners();
  }

  void expandRecordingItem(Recording recording) {
    removeAllRecordingItems();
    addRecordingItem(recording);
    expandedItem = true;
    notifyListeners();
  }

  void contractRecordingItem() {
    removeAllRecordingItems();
    for (var element in _recordingsFileList.reversed) {
      addRecordingItem(
        Recording(
            title: AppFileSystem.getFilenameWithoutExtension(element.path),
            path: element.path),
      );
    }
    expandedItem = false;
    notifyListeners();
  }

  void expandRecordingsList() {
    if (!listExpanded) {
      listExpanded = true;
      notifyListeners();
    }
  }

  void contractRecordingsList() {
    if (listExpanded) {
      listExpanded = false;
      notifyListeners();
    }
  }

  void disableRecordingTitleTextField() {
    recordingTitleTextFieldVisible = false;
    notifyListeners();
  }

  Future<void> updateRecordingTitle(Recording recording, String title) async {
    recording.title = title;

    recording.path = await AppFileSystem.renameFile(recording.path, title)
        .whenComplete(() async {
      if (recording.playbackPath != null) {
        recording.playbackPath = await AppFileSystem.renameFile(
            recording.playbackPath as String,
            '${title}_${recording.playbackTitle}_Playback');
      }
    });

    loadRecordings();
  }

  Future<void> loadPlayback(Recording recording) async {
    // load playback for recording
    List? playbackAndTitle =
        (await AppFileSystem.getPlaybackFromRecording(recording.title));

    if (playbackAndTitle == null) {
      recording.playbackPath = null;
      recording.playbackTitle = null;
    } else {
      recording.playbackPath = playbackAndTitle[0];
      recording.playbackTitle = playbackAndTitle[1];
    }

    notifyListeners();
  }

  void setPlaybackStatus(Recording recording, bool status) {
    recording.playbackActive = status;
  }

  Future<void> deleteRecording(Recording recording) async {
    await File(recording.path).delete().whenComplete(() {
      notifyListeners();
    });
  }
}

class Recording {
  Recording(
      {required this.title,
      required this.path,
      this.playbackPath,
      this.playbackTitle});

  String title;
  String path;
  String? playbackPath;
  String? playbackTitle;
  bool playbackActive = true;
}
