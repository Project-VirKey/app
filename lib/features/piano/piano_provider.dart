import 'dart:async';
import 'dart:io';

import 'package:dart_midi/dart_midi.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:midi_util/midi_util.dart';
import 'package:virkey/utils/file_system.dart';

class PianoProvider extends ChangeNotifier {
  int midiOffset = 72;

  // name, note (minus offset), background color
  List pianoKeysWhite = [
    ['C', 0, false],
    ['D', 2, false],
    ['E', 4, false],
    ['F', 5, false],
    ['G', 7, false],
    ['A', 9, false],
    ['B', 11, false]
  ];

  List pianoKeysBlack = [
    ['C#', 'Db', 1, false],
    ['D#', 'Eb', 3, false],
    [],
    ['F#', 'Gb', 6, false],
    ['G#', 'Ab', 8, false],
    ['A#', 'Bb', 10, false]
  ];

  final List _recordedNotes = [];
  bool _isRecording = false;
  int _startTimeStamp = 0;
  String recordingTitle = '';

  String displayTime = '';
  final String _resetDisplayTime = '00:00:000';
  Timer? _displayTimeTimer;
  final int _recordingDelaySeconds = 3;
  int? _previousElapsedTime;

  // optional playback while recording/playing
  bool isPlaybackActive = false;

  bool isPlaybackPlaying = false;
  String? playbackPath;
  String? playbackFileName;
  AudioPlayer playbackPlayer = AudioPlayer();

  // optional midi file for displaying notes on piano keys
  bool isVisualizeMidiActive = false;
  bool isVisualizeMidiPlaying = false;
  String? visualizeMidiPath;
  String? visualizeMidiFileName;
  int? visualizeMidiCurrentEventPos;

  List get recordedNotes => _recordedNotes;

  bool get isRecording => _isRecording;

  int get millisecondsSinceEpoch => DateTime.now().millisecondsSinceEpoch;

  int get _elapsedTime => millisecondsSinceEpoch - _startTimeStamp;

  bool get isSomethingPlaying => isPlaybackPlaying || isVisualizeMidiPlaying;

  PianoProvider() {
    displayTime = _resetDisplayTime;
  }

  // ----------------------------------------------------------------

  void playPause() {
    togglePlayback();

    if (isVisualizeMidiPlaying) {
      pauseVisualizeMidi();
    } else {
      startVisualizeMidi();
    }

    // print('---');
    // print(isPlaybackPlaying);
    // print(isVisualizeMidiPlaying);
    // print(isRecording);
    // print('---');
    if (!isRecording) {
      if (_displayTimeTimer == null) {
        if (isPlaybackPlaying || isVisualizeMidiPlaying) {
          setStartTimeStamp();
          startDisplayTimeTimer();
        }
      } else {
        if (_displayTimeTimer!.isActive) {
          pauseDisplayTimeTimer();
        } else {
          if (isPlaybackPlaying || isVisualizeMidiPlaying) {
            setStartTimeStamp();
            startDisplayTimeTimer();
          }
        }
      }
    }

    if (isRecording) {
    } else {}

    notifyListeners();
  }

  void stop() {
    if (!isRecording) {
      stopDisplayTimeTimer();
    }

    isVisualizeMidiPlaying = false;
    visualizeMidiCurrentEventPos = null;

    stopPlayback();
    playbackPlayer.seek(const Duration(seconds: 0));

    notifyListeners();
  }

  // ----------------------------------------------------------------

  String get formattedElapsedTime {
    Duration timeDifferenceObj = Duration(
        milliseconds: _elapsedTime.abs() + (_previousElapsedTime ?? 0));

    int minutes = timeDifferenceObj.inMinutes;
    int seconds = timeDifferenceObj.inSeconds - (minutes * 60);
    int milliseconds = timeDifferenceObj.inMilliseconds -
        (minutes * 60 * 1000) -
        (seconds * 1000);

    return '${_elapsedTime.isNegative ? '- ' : ''}${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}:${milliseconds.toString().padLeft(3, '0')}';
  }

  void setStartTimeStamp([bool delay = false]) {
    _startTimeStamp =
        millisecondsSinceEpoch + (delay ? (_recordingDelaySeconds * 1000) : 0);
  }

  void startDisplayTimeTimer() {
    _displayTimeTimer =
        Timer.periodic(const Duration(milliseconds: 20), (timer) {
      displayTime = formattedElapsedTime;
      notifyListeners();
    });
  }

  void stopDisplayTimeTimer() {
    _displayTimeTimer?.cancel();
    displayTime = _resetDisplayTime;
    _previousElapsedTime = null;
    print('stopped timer');
  }

  void pauseDisplayTimeTimer() {
    _previousElapsedTime = _elapsedTime + (_previousElapsedTime ?? 0);
    setStartTimeStamp();

    _displayTimeTimer?.cancel();
  }

  // ----------------------------------------------------------------

  void togglePlayback() {
    if (isPlaybackPlaying) {
      stopPlayback();
    } else {
      startPlayback();
    }
  }

  void stopPlayback() {
    if (isPlaybackActive && playbackPath != null) {
      playbackPlayer.stop();
      isPlaybackPlaying = false;
    }
  }

  void startPlayback() {
    if (isPlaybackActive && playbackPath != null) {
      playbackPlayer.play();
      isPlaybackPlaying = true;
    }
  }

  // ----------------------------------------------------------------

  void toggleRecording() {
    if (_isRecording) {
      stopRecording();
      stopPlayback();
      stopVisualizeMidi();
      stopDisplayTimeTimer();
    } else {
      _previousElapsedTime = null;
      startRecording();
    }

    notifyListeners();
  }

  Future<void> startRecording() async {
    setStartTimeStamp(true);
    startDisplayTimeTimer();

    stopPlayback();

    await Future.delayed(Duration(seconds: _recordingDelaySeconds));

    _isRecording = true;
    _recordedNotes.clear();

    playbackPlayer.seek(const Duration(seconds: 0));
    startPlayback();

    stopVisualizeMidi();
    startVisualizeMidi();
  }

  Future<void> stopRecording() async {
    _isRecording = false;

    if (playbackPath != null) {
      AppFileSystem.savePlaybackFile(File(playbackPath!), recordingTitle);
    }

    createMidiFile();
  }

  void recordingAddNote(int midiNote, [double duration = 500]) {
    print(midiNote);

    _recordedNotes.add([midiNote, _elapsedTime, duration]);
  }

  // ----------------------------------------------------------------

  Future<void> startVisualizeMidi() async {
    if (!isVisualizeMidiActive || visualizeMidiPath == null) {
      return;
    }

    isVisualizeMidiPlaying = true;
    MidiFile parsedMidi =
        AppFileSystem.midiFileFromRecording(visualizeMidiPath!);

    midiEventTrackLoop:
    for (List<MidiEvent> track in parsedMidi.tracks) {
      for (int i = 0; i < track.length; i++) {
        MidiEvent midiEvent = track[i];

        if (!isVisualizeMidiPlaying) {
          // if playing is set to false during midi visualization -> break out of the complete loop
          break midiEventTrackLoop;
        }

        print(visualizeMidiCurrentEventPos);
        if (midiEvent is! NoteOnEvent ||
            (visualizeMidiCurrentEventPos ?? -1) > i) {
          continue;
        }

        visualizeMidiCurrentEventPos = i;

        int playedPianoKeyWhite = pianoKeysWhite.indexWhere((pianoKeyWhite) =>
            pianoKeyWhite[1] + midiOffset == midiEvent.noteNumber);

        int playedPianoKeyBlack = pianoKeysBlack.indexWhere((pianoKeyBlack) {
          if (pianoKeyBlack.isEmpty) {
            return false;
          }
          return (pianoKeyBlack[2] + midiOffset) == midiEvent.noteNumber;
        });

        await Future.delayed(Duration(milliseconds: midiEvent.deltaTime));

        if (playedPianoKeyWhite >= 0) {
          pianoKeysWhite[playedPianoKeyWhite][2] = true;
          notifyListeners();
          Future.delayed(Duration(milliseconds: midiEvent.duration), () {
            pianoKeysWhite[playedPianoKeyWhite][2] = false;
            notifyListeners();
          });
        }

        if (playedPianoKeyBlack >= 0) {
          pianoKeysBlack[playedPianoKeyBlack][3] = true;
          notifyListeners();
          Future.delayed(Duration(milliseconds: midiEvent.duration), () {
            pianoKeysBlack[playedPianoKeyBlack][3] = false;
            notifyListeners();
          });
        }

        // print('n: ${midiEvent.noteNumber}');
        // print('t: ${midiEvent.deltaTime}');
        // print('d: ${midiEvent.duration}');
      }
    }
  }

  void stopVisualizeMidi() {
    isVisualizeMidiPlaying = false;
    visualizeMidiCurrentEventPos = null;
  }

  void pauseVisualizeMidi() {
    isVisualizeMidiPlaying = false;
  }

  // ----------------------------------------------------------------

  void createMidiFile() {
    int track = 0;
    int channel = 0;
    num time = 0; //    # In beats
    // double duration = 0.5; //    # In beats
    int tempo = 60; //   # In BPM
    int volume = 100; //  # 0-127, as per the MIDI standard

    MIDIFile midiFile = MIDIFile(numTracks: 1);
    midiFile.addTempo(
      track: track,
      time: time,
      tempo: tempo,
    );

    midiFile.addKeySignature(
      track: track,
      time: time,
      no_of_accidentals: 0,
      accidental_mode: AccidentalMode.MAJOR,
      accidental_type: AccidentalType.SHARPS,
    );

    List.generate(_recordedNotes.length, (i) {
      midiFile.addNote(
          track: track,
          channel: channel,
          pitch: _recordedNotes[i][0],
          time: _recordedNotes[i][1] / 1000,
          duration: _recordedNotes[i][2] / 1000,
          volume: volume);
    });

    File outputFile = File(
        '${AppFileSystem.basePath}${Platform.pathSeparator}${AppFileSystem.recordingsFolder}${Platform.pathSeparator}$recordingTitle.mid');

    midiFile.writeFile(outputFile);
  }

  // ----------------------------------------------------------------

  void setPlayback(String path) {
    playbackPath = path;
    playbackFileName = AppFileSystem.getFilenameFromPath(path);
    isPlaybackActive = true;
    playbackPlayer.setAudioSource(AudioSource.file(playbackPath!));

    notifyListeners();
  }

  void removePlayback() {
    isPlaybackActive = false;
    playbackPath = null;

    notifyListeners();
  }

  Future<void> setVisualizeMidi(String path) async {
    visualizeMidiPath = path;
    visualizeMidiFileName = AppFileSystem.getFilenameFromPath(path);
    isVisualizeMidiActive = true;

    notifyListeners();
  }

  void removeVisualizeMidi() {
    isVisualizeMidiActive = false;
    visualizeMidiPath = null;

    notifyListeners();
  }
}
