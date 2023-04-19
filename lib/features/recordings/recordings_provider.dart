import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dart_midi/dart_midi.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/features/piano/piano.dart';
import 'package:virkey/features/settings/settings_provider.dart';
import 'package:virkey/features/settings/settings_shared_preferences.dart';
import 'package:virkey/utils/file_system.dart';
import 'package:virkey/utils/timestamp.dart';

class RecordingsProvider extends ChangeNotifier {
  final List<Recording> _recordings = [];

  static const Duration expandDuration = Duration(milliseconds: 200);
  final recordingsListKey = GlobalKey<AnimatedListState>();
  bool listExpanded = false;
  bool expandedItem = false;
  bool recordingTitleTextFieldVisible = false;

  bool isRecordingPlaying = false;
  AudioPlayer _playbackPlayer = AudioPlayer();
  MidiFile? _parsedRecordingMidi;
  final List<List<int>> _noteOnEvents = [];
  int _midiMilliSecondsDuration = 0;
  double relativePlayingPosition = 0;
  Timer? _playingPositionTimer;
  int _startTimeStamp = 0;
  Duration playingDuration = const Duration();

  int get _currentPosition =>
      (relativePlayingPosition * .01 * playingDuration.inMilliseconds).round();

  int get _elapsedTime => AppTimestamp.now - _startTimeStamp;

  static List<FileSystemEntity> _recordingsFolderFiles = [];

  List<Recording> get recordings => _recordings;

  RecordingsProvider(this._settingsProvider) {
    refreshRecordingsFolderFiles();
  }

  SettingsProvider _settingsProvider;

  setSettingsProvider(SettingsProvider sP) {
    _settingsProvider = sP;
    setPlaybackVolume(_settingsProvider.settings.audioVolume.audioPlayback);
    notifyListeners();
  }

  void notify() {
    notifyListeners();
  }

  Future<void> refreshRecordingsFolderFiles() async {
    await loadRecordingsFolderFiles();
    await loadRecordings();
    // TODO: call function to reload from shared preferences
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
      // TODO: get recording url from local storage
      Recording recording = Recording(
        title: AppFileSystem.getFilenameWithoutExtension(recordingFile.path),
        path: recordingFile.path,
        url: '',
      );

      addRecordingItem(recording);
      await loadPlayback(recording);
    }

    notifyListeners();
  }

  void loadRecordingsFromSharedPreferences() {
    if (AppSharedPreferences.loadedSharedPreferences == null) {
      AppSharedPreferences.saveData();
    } else {
      AppSharedPreferences.loadedSharedPreferences?['recordings'];
    }

    // TODO: check difference between shared-preferences and existing files
    // AppSharedPreferences.saveData(recordings: _recordings);
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
    pauseRecording();
    removeAllRecordingItems();
    for (var element
        in AppFileSystem.filterFilesList(_recordingsFolderFiles, ['mid'])
            .reversed) {
      // TODO: get recording url from local storage
      Recording recording = Recording(
        title: AppFileSystem.getFilenameWithoutExtension(element.path),
        path: element.path,
        url: '',
      );
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

  void setRelativePlayingPosition(double value) {
    int intValue = value.toInt();

    if (relativePlayingPosition.round() != intValue) {
      relativePlayingPosition = value;
      notifyListeners();
    }
  }

  String getFormattedTime(Duration duration) {
    int minutes = duration.inMinutes;
    int seconds = duration.inSeconds - (minutes * 60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Duration _playingDuration() {
    Duration midiDuration = Duration(milliseconds: _midiMilliSecondsDuration);

    if (_playbackPlayer.duration == null) {
      return midiDuration;
    } else {
      if (_midiMilliSecondsDuration >
          _playbackPlayer.duration!.inMilliseconds) {
        return midiDuration;
      } else {
        return _playbackPlayer.duration!;
      }
    }
  }

  String get formattedPlayingDuration => getFormattedTime(playingDuration);

  String get formattedPlayingPosition =>
      getFormattedTime(Duration(milliseconds: _currentPosition));

  Future<void> setupRecordingPlayer(Recording recording) async {
    _playbackPlayer = AudioPlayer();
    setPlaybackVolume(_settingsProvider.settings.audioVolume.audioPlayback);

    if (recording.playbackActive && recording.playbackPath != null) {
      await _playbackPlayer
          .setAudioSource(AudioSource.file(recording.playbackPath!));
    }

    _parsedRecordingMidi = AppFileSystem.midiFileFromRecording(recording.path);
    _noteOnEvents.clear();

    for (List<MidiEvent> track in _parsedRecordingMidi!.tracks) {
      int absolutePosition = 0;
      for (int i = 0; i < track.length; i++) {
        MidiEvent midiEvent = track[i];

        if (midiEvent is! NoteOnEvent) {
          continue;
        }

        absolutePosition += midiEvent.deltaTime + midiEvent.duration;

        _noteOnEvents.add([
          midiEvent.noteNumber,
          (absolutePosition - midiEvent.duration) ~/ 2,
          midiEvent.deltaTime,
          midiEvent.duration
        ]);
      }
    }

    _midiMilliSecondsDuration = getMidiMilliSecondsDuration();
    relativePlayingPosition = 0;
    playingDuration = _playingDuration();

    notifyListeners();
  }

  int getMidiMilliSecondsDuration() {
    int milliSeconds = 0;

    for (List<MidiEvent> track in _parsedRecordingMidi!.tracks) {
      milliSeconds += track
          .map((MidiEvent midiEvent) => midiEvent is NoteOnEvent
              ? midiEvent.deltaTime + midiEvent.duration
              : 0)
          .sum;
    }

    return milliSeconds ~/ 2;
  }

  void setPlaybackVolume(int volume) => _playbackPlayer.setVolume(volume / 100);

  Future<void> playRecording(Recording recording) async {
    if (_parsedRecordingMidi == null) {
      return;
    }

    if (relativePlayingPosition == 100) {
      relativePlayingPosition = 0;
    }

    _startTimeStamp = AppTimestamp.now - _currentPosition;

    if (recording.playbackActive && recording.playbackPath != null) {
      _playbackPlayer.seek(Duration(milliseconds: _currentPosition));
      _playbackPlayer.play();
    }

    _playingPositionTimer =
        Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (isRecordingPlaying && relativePlayingPosition < 100) {
        double newRelativePlayingPosition =
            ((_elapsedTime / playingDuration.inMilliseconds) * 100);
        if (newRelativePlayingPosition >= 100) {
          // check if targeted value is over 100
          // if true then set value manually to 100
          // otherwise the slider cannot accept the value (slider max value is 100)
          relativePlayingPosition = 100;
        } else {
          relativePlayingPosition = newRelativePlayingPosition;
        }
      } else {
        pauseRecording();
      }
      notifyListeners();
    });

    // ----

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

    // Standard MIDI-File Format Spec. 1.1
    // https://www.cs.cmu.edu/~music/cmsip/readings/Standard-MIDI-file-format-updated.pdf, 30.01.2023
    // description of chunks, chunk types (MThd -> Header, MTrk -> Track)
    // SetTempoEvent -> 0x FF 51 03 -> Tempo of MIDI Track

    // dart_midi: SetTempoEvent
    // https://pub.dev/documentation/dart_midi/latest/midi/SetTempoEvent-class.html, 30.01.2023

    for (int i = 0; i < _noteOnEvents.length; i++) {
      if (!isRecordingPlaying) {
        // if playing is set to false during midi playback -> break out of the complete loop
        break;
      }

      if (_currentPosition > _noteOnEvents[i][1]) {
        continue;
      } else {
        await Future.delayed(
            Duration(milliseconds: _noteOnEvents[i][1] - _currentPosition));
      }

      int octaveIndex = Piano.getOctaveIndexFromMidiNote(_noteOnEvents[i][0]);

      int playedPianoKeyWhite =
          Piano.getPianoKeyWhiteIndex(_noteOnEvents[i][0], octaveIndex);

      int playedPianoKeyBlack =
          Piano.getPianoKeyBlackIndex(_noteOnEvents[i][0], octaveIndex);

      if (playedPianoKeyWhite >= 0) {
        Piano.playPianoNote(octaveIndex, playedPianoKeyWhite);
      }

      if (playedPianoKeyBlack >= 0) {
        Piano.playPianoNote(octaveIndex, playedPianoKeyBlack, true);
      }
    }
  }

  void pauseRecording() {
    isRecordingPlaying = false;
    _playbackPlayer.pause();
    _playingPositionTimer?.cancel();
  }
}

class Recording {
  Recording(
      {required this.title,
      required this.path,
      required this.url,
      this.playbackPath,
      this.playbackTitle});

  String title;
  String path;
  String url;
  String? playbackPath;
  String? playbackTitle;
  bool playbackActive = true;
}
