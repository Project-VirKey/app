import 'dart:io';

import 'package:flutter/material.dart';
import 'package:virkey/constants/colors.dart';
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

  Future<void> loadRecordings() async {
    await AppFileSystem.loadBasePath();

    // get files in recordings folder & filter (with where) for only recordings
    List<FileSystemEntity>? recordingsFileList =
        (await AppFileSystem.listFilesInFolder(AppFileSystem.recordingsFolder))
            ?.where((file) =>
                AppFileSystem.getFileExtensionFromPath(file.path) == 'mid')
            .toList();

    print(recordingsFileList);

    _recordingsFileList = recordingsFileList!;

    // add files recordings list as Recording objects
    for (var recordingFile in recordingsFileList.reversed) {
      addRecordingItem(
        Recording(
          title:
              AppFileSystem.getFilenameWithoutExtension(recordingFile.path) ??
                  '',
          recording: recordingFile as File,
        ),
      );
    }

    notifyListeners();
  }

  void addRecordingItem(Recording recording) {
    recordings.insert(0, recording);
    recordingsListKey.currentState!
        .insertItem(0, duration: const Duration(milliseconds: 150));
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

  void expandRecordingItem(int index) {
    Recording item = recordings[index];
    removeAllRecordingItems();
    addRecordingItem(item);
    expandedItem = true;
    notifyListeners();
  }

  void contractRecordingItem() {
    removeAllRecordingItems();
    for (var element in _recordingsFileList.reversed) {
      addRecordingItem(Recording(
          title:
              AppFileSystem.getFilenameWithoutExtension(element.path) ?? ''));
    }
    expandedItem = false;
    notifyListeners();
  }

  void expandRecordingsList() {
    if (!listExpanded) {
      listExpanded = true;
    }
    notifyListeners();
  }

  void contractRecordingsList() {
    if (listExpanded) {
      listExpanded = false;
    }
    notifyListeners();
  }

  void disableRecordingTitleTextField() {
    recordingTitleTextFieldVisible = false;
    notifyListeners();
  }

  void updateRecordingTitle(Recording recording, String title) {
    if (recording.recording == null) {
      return;
    }
    recording.title = title;
    AppFileSystem.renameFile(recording.recording as File, title);
    if (recording.playback != null) {
      AppFileSystem.renameFile(recording.playback as File,
          '${title}_${recording.playbackTitle}_Playback');
    }
    notifyListeners();
  }

  Future<void> loadPlayback(Recording recording) async {
    // load playback for recording
    List? playbackAndTitle =
        (await AppFileSystem.getPlaybackFromRecording(recording.title));

    if (playbackAndTitle == null) {
      recording.playback = null;
      recording.playbackTitle = null;
    } else {
      recording.playback = playbackAndTitle[0];
      recording.playbackTitle = playbackAndTitle[1];
    }

    notifyListeners();
  }

  void setPlaybackStatus(Recording recording, bool status) {
    recording.playbackActive = status;
  }

  Future<void> deleteRecording(Recording recording) async {
    if (recording.recording != null) {
      print(await FileStat.stat(recording.recording?.path as String));
    }

    await recording.recording?.delete().whenComplete(() {
      notifyListeners();
    });
  }
}

class Recording {
  Recording(
      {required this.title, this.recording, this.playback, this.playbackTitle});

  String title;
  File? recording;
  File? playback;
  String? playbackTitle;
  bool playbackActive = true;
}
