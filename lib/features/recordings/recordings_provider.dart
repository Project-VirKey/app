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
        (await AppSharedPreferences.loadData())?['settings']
            ?.defaultFolder
            .path;
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

    isRecordingPlaying = true;

    // with MIDI files generated through the app:
    // parsedRecordingMidi!.header.ticksPerBeat -> value is not null
    // and contains ticks per quarter-note

    // Converting MIDI ticks to actual playback seconds
    // https://stackoverflow.com/a/54754549/17399214, 30.01.2023
    // ticks_per_quarter = <PPQ from the header>
    // µs_per_quarter = <Tempo in latest Set Tempo event>
    // µs_per_tick = µs_per_quarter / ticks_per_quarter
    // seconds_per_tick = µs_per_tick / 1.000.000
    // seconds = ticks * seconds_per_tick

    // milliSeconds = ticks * milliSecondsPerTick
    // deltaTime -> ticks per quarter-note
    // conclusion: dart_midi provides an actual deltaTime in milliseconds,
    // but when calculating manually -> the milliseconds value is slightly higher
    int ticksPerQuarter = parsedRecordingMidi!.header.ticksPerBeat as int;
    int microSecondsPerQuarter = 0;
    double microSecondsPerTick = 0;
    double milliSecondsPerTick = 0;

    // Standard MIDI-File Format Spec. 1.1
    // https://www.cs.cmu.edu/~music/cmsip/readings/Standard-MIDI-file-format-updated.pdf, 30.01.2023
    // description of chunks, chunk types (MThd -> Header, MTrk -> Track)
    // SetTempoEvent -> 0x FF 51 03 -> Tempo of MIDI Track

    midiEventTrackLoop:
    for (List<MidiEvent> track in parsedRecordingMidi!.tracks) {
      for (int i = 0; i < track.length; i++) {
        MidiEvent midiEvent = track[i];

        if (!isRecordingPlaying) {
          // if playing is set to false during midi playback -> break out of the complete loop
          break midiEventTrackLoop;
        }

        // dart_midi: SetTempoEvent
        // https://pub.dev/documentation/dart_midi/latest/midi/SetTempoEvent-class.html, 30.01.2023
        if (midiEvent is SetTempoEvent) {
          microSecondsPerQuarter = midiEvent.microsecondsPerBeat;
          microSecondsPerTick = microSecondsPerQuarter / ticksPerQuarter;
          milliSecondsPerTick = microSecondsPerTick / 1000;
        }

        if (midiEvent is! NoteOnEvent ||
            (midiPlayCurrentEventPos ?? -1) + 1 > i) {
          continue;
        }

        midiPlayCurrentEventPos = i;

        int octaveIndex =
            Piano.getOctaveIndexFromMidiNote(midiEvent.noteNumber);

        int playedPianoKeyWhite = Piano.white.indexWhere((pianoKeyWhite) =>
            pianoKeyWhite[1] +
                Piano.midiOffset +
                (octaveIndex * Piano.keysPerOctave) ==
            midiEvent.noteNumber);

        int playedPianoKeyBlack = Piano.black.indexWhere((pianoKeyBlack) {
          if (pianoKeyBlack.isEmpty) {
            return false;
          }
          return (pianoKeyBlack[1] +
                  Piano.midiOffset +
                  (octaveIndex * Piano.keysPerOctave)) ==
              midiEvent.noteNumber;
        });

        int milliSeconds = (midiEvent.deltaTime * milliSecondsPerTick).round();

        await Future.delayed(Duration(milliseconds: milliSeconds));

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
