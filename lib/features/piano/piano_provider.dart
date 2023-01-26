import 'dart:async';
import 'dart:io';

import 'package:dart_midi/dart_midi.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:midi_util/midi_util.dart';
import 'package:virkey/features/piano/piano.dart';
import 'package:virkey/utils/file_system.dart';
import 'package:virkey/utils/timestamp.dart';

class PianoProvider extends ChangeNotifier {
  // background color
  List pianoKeysWhite = [
    [false],
    [false],
    [false],
    [false],
    [false],
    [false],
    [false]
  ];

  List pianoKeysBlack = [
    [false],
    [false],
    [],
    [false],
    [false],
    [false]
  ];

  int currentOctaveIndex = 1;

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

  int get _elapsedTime => AppTimestamp.now - _startTimeStamp;

  bool get isSomethingPlaying => isPlaybackPlaying || isVisualizeMidiPlaying;

  PianoProvider() {
    displayTime = _resetDisplayTime;
  }

  void notify() {
    notifyListeners();
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
        AppTimestamp.now + (delay ? (_recordingDelaySeconds * 1000) : 0);
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
    stopDisplayTimeTimer();
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

  void recordingAddNote(int octaveIndex, int midiNote) {
    _recordedNotes
        .add([midiNote + (octaveIndex * Piano.keysPerOctave), _elapsedTime]);
  }

  // ----------------------------------------------------------------

  Future<void> startVisualizeMidi() async {
    // TODO: fix for displaying on the correct keys & the correct octave
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

        if (midiEvent is! NoteOnEvent ||
            (visualizeMidiCurrentEventPos ?? -1) + 1 > i) {
          continue;
        }

        visualizeMidiCurrentEventPos = i;

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

        // TODO: fix visual playback
        print(playedPianoKeyWhite);

        await Future.delayed(Duration(milliseconds: midiEvent.deltaTime));

        if (playedPianoKeyWhite >= 0) {
          pianoKeysWhite[playedPianoKeyWhite][0] = true;
          notifyListeners();
          Future.delayed(Duration(milliseconds: midiEvent.duration), () {
            pianoKeysWhite[playedPianoKeyWhite][0] = false;
            notifyListeners();
          });
        }

        if (playedPianoKeyBlack >= 0) {
          pianoKeysBlack[playedPianoKeyBlack][0] = true;
          notifyListeners();
          Future.delayed(Duration(milliseconds: midiEvent.duration), () {
            pianoKeysBlack[playedPianoKeyBlack][0] = false;
            notifyListeners();
          });
        }
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
    double duration = 0.5; //    # In beats
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
          duration: duration,
          volume: volume);
    });

    File outputFile =
        File('${AppFileSystem.recordingsFolderPath}$recordingTitle.mid');

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
