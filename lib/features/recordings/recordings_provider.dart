import 'dart:io';

import 'package:dart_midi/dart_midi.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/features/piano/piano.dart';
import 'package:virkey/features/settings/settings_shared_preferences.dart';
import 'package:virkey/utils/file_system.dart';

class RecordingsProvider extends ChangeNotifier {
  final List<Recording> _recordings = [];

  static const Duration expandDuration = Duration(milliseconds: 200);
  final recordingsListKey = GlobalKey<AnimatedListState>();
  bool listExpanded = false;
  bool expandedItem = false;
  bool recordingTitleTextFieldVisible = false;

  bool isRecordingPlaying = false;
  AudioPlayer playbackPlayer = AudioPlayer();
  int? midiPlayCurrentEventPos;
  bool isRecordingSliderModeManual = false;
  MidiFile? parsedRecordingMidi;

  static List<FileSystemEntity> _recordingsFolderFiles = [];

  List<Recording> get recordings => _recordings;

  RecordingsProvider() {
    refreshRecordingsFolderFiles();
  }

  void notify() {
    notifyListeners();
  }

  Future<void> refreshRecordingsFolderFiles() async {
    await loadRecordingsFolderFiles();
    loadRecordings();
  }

  Future<void> loadRecordingsFolderFiles() async {
    List<FileSystemEntity>? recordingsFolderFiles =
        (await AppFileSystem.listFilesInFolder(AppFileSystem.recordingsFolder));

    if (recordingsFolderFiles != null) {
      _recordingsFolderFiles = recordingsFolderFiles;
    }
  }

  Future<void> loadRecordings() async {
    AppFileSystem.basePath =
        (await AppSharedPreferences.loadData())?['settings']?.defaultFolder.path;
    if (AppFileSystem.basePath == null || AppFileSystem.basePath == '') {
      await AppFileSystem.loadBasePath();
    }

    removeAllRecordingItems();

    // add files recordings list as Recording objects
    for (var recordingFile
        in AppFileSystem.filterFilesList(_recordingsFolderFiles, ['mid'])
            .reversed) {
      Recording recording = Recording(
        title: AppFileSystem.getFilenameWithoutExtension(recordingFile.path),
        path: recordingFile.path,
      );

      addRecordingItem(recording);
      await loadPlayback(recording);
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
    setupRecordingPlayer(recording);
    notifyListeners();
  }

  Future<void> contractRecordingItem() async {
    removeAllRecordingItems();
    for (var element
        in AppFileSystem.filterFilesList(_recordingsFolderFiles, ['mid'])
            .reversed) {
      Recording recording = Recording(
          title: AppFileSystem.getFilenameWithoutExtension(element.path),
          path: element.path);
      addRecordingItem(recording);
      await loadPlayback(recording);
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

    await loadRecordingsFolderFiles();
  }

  Future<void> loadPlayback(Recording recording) async {
    // load playback for recording
    List? playbackAndTitle = (await AppFileSystem.getPlaybackFromRecording(
        _recordingsFolderFiles, recording.title));

    if (playbackAndTitle == null) {
      recording.playbackPath = null;
      recording.playbackTitle = null;
    } else {
      recording.playbackPath = playbackAndTitle[0];
      recording.playbackTitle = playbackAndTitle[1];
    }
  }

  void setPlaybackStatus(Recording recording, bool status) {
    recording.playbackActive = status;
    notifyListeners();
  }

  Future<void> deleteRecording(Recording recording) async {
    await File(recording.path).delete().whenComplete(() {
      notifyListeners();
    });
  }

  // ----------------------------------------------------------------

  String getFormattedTime(Duration duration) {
    int minutes = duration.inMinutes;
    int seconds = duration.inSeconds - (minutes * 60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedPlayingLength {
    if (playbackPlayer.duration == null) {
      return '00:00';
    } else {
      return getFormattedTime(playbackPlayer.duration!);
    }
  }

  String get formattedPlayingPosition {
    return getFormattedTime(playbackPlayer.position);
  }

  double get relativePlayingPosition {
    if (playbackPlayer.duration == null) {
      return 0;
    } else {
      return ((playbackPlayer.position.inSeconds /
              playbackPlayer.duration!.inSeconds) *
          100);
    }
  }

  Future<void> setupRecordingPlayer(Recording recording) async {
    if (recording.playbackActive && recording.playbackPath != null) {
      // await playbackPlayer.dispose();
      // playbackPlayer.seek(const Duration(seconds: 0));
      playbackPlayer.setAudioSource(AudioSource.file(recording.playbackPath!));
    }

    midiPlayCurrentEventPos = null;
    parsedRecordingMidi = AppFileSystem.midiFileFromRecording(recording.path);
  }

  Future<void> playRecording(Recording recording) async {
    if (recording.playbackActive && recording.playbackPath != null) {
      playbackPlayer.play();
      print(playbackPlayer.duration?.inSeconds);
      playbackPlayer
          .createPositionStream(
              minPeriod: const Duration(milliseconds: 500),
              maxPeriod: const Duration(seconds: 1))
          .listen((event) {
        print(event.inMilliseconds);
        notifyListeners();
      });
    }

    if (parsedRecordingMidi == null) {
      return;
    }

    List<MidiEvent>? midiTrack = parsedRecordingMidi?.tracks
        .reduce((a, b) => a.length > b.length ? a : b);
    // TODO: don't reduce by length of tracks, but instead by the highest sum of deltaTime
    if (midiTrack == null) {
      return;
    } else {
      // TODO: convert deltaTime to milliSeconds
      // midiTrack.retainWhere((MidiEvent midiEvent) => midiEvent is NoteOnEvent);
      // print('---');
      // print(parsedRecordingMidi?.header.ticksPerBeat * midiTrack[0].deltaTime);
      // print('---');
      // print(midiTrack.map((e) => e.deltaTime).reduce((int a, int b) => a + b));
    }

    isRecordingPlaying = true;

    midiEventTrackLoop:
    for (List<MidiEvent> track in parsedRecordingMidi!.tracks) {
      for (int i = 0; i < track.length; i++) {
        MidiEvent midiEvent = track[i];

        if (!isRecordingPlaying) {
          // if playing is set to false during midi playback -> break out of the complete loop
          break midiEventTrackLoop;
        }

        // print(midiPlayCurrentEventPos);
        if (midiEvent is! NoteOnEvent ||
            (midiPlayCurrentEventPos ?? -1) + 1 > i) {
          continue;
        }

        midiPlayCurrentEventPos = i;

        int playedPianoKeyWhite = Piano.white.indexWhere((pianoKeyWhite) =>
            pianoKeyWhite[1] + Piano.midiOffset == midiEvent.noteNumber);

        int playedPianoKeyBlack = Piano.black.indexWhere((pianoKeyBlack) {
          if (pianoKeyBlack.isEmpty) {
            return false;
          }
          return (pianoKeyBlack[1] + Piano.midiOffset) == midiEvent.noteNumber;
        });

        int octaveIndex = 0;
        if (midiEvent.noteNumber >= Piano.midiOffset && midiEvent.noteNumber < (Piano.midiOffset + Piano.keysPerOctave)) {
          octaveIndex = 0;
        } else if (midiEvent.noteNumber + Piano.keysPerOctave >= Piano.midiOffset && midiEvent.noteNumber < (Piano.midiOffset + 2 * Piano.keysPerOctave)) {
          octaveIndex = 1;
        } else if (midiEvent.noteNumber + 2 * Piano.keysPerOctave >= Piano.midiOffset && midiEvent.noteNumber < (Piano.midiOffset + 3 * Piano.keysPerOctave)) {
          octaveIndex = 2;
        }

        print(midiEvent.deltaTime);

        await Future.delayed(Duration(milliseconds: midiEvent.deltaTime));

        if (playedPianoKeyWhite >= 0) {
          Piano.playPianoNote(octaveIndex, playedPianoKeyWhite);
        }

        if (playedPianoKeyBlack >= 0) {
          Piano.playPianoNote(octaveIndex, playedPianoKeyBlack, true);
        }
      }
    }
  }

  void pauseRecording() {
    isRecordingPlaying = false;
    playbackPlayer.pause();
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
