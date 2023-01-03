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
  Timer? _displayTimeTimer;

  final int _recordingDelaySeconds = 3;

  // optional playback while recording/playing
  bool isPlaybackPlaying = false;
  String? playbackPath;
  String? playbackFileName;
  AudioPlayer playbackPlayer = AudioPlayer();

  // optional midi file for displaying notes on piano keys
  bool isVisualizeMidiPlaying = false;
  String? visualizeMidiPath;
  String? visualizeMidiFileName;

  List get recordedNotes => _recordedNotes;

  bool get isRecording => _isRecording;

  int get millisecondsSinceEpoch => DateTime.now().millisecondsSinceEpoch;

  int get _elapsedTime => millisecondsSinceEpoch - _startTimeStamp;

  PianoProvider() {
    displayTime = _resetDisplayTime;
  }

  String get formattedElapsedTime {
    Duration timeDifferenceObj = Duration(milliseconds: _elapsedTime.abs());

    int minutes = timeDifferenceObj.inMinutes;
    int seconds = timeDifferenceObj.inSeconds - (minutes * 60);
    int milliseconds = timeDifferenceObj.inMilliseconds -
        (minutes * 60 * 1000) -
        (seconds * 1000);

    return '${_elapsedTime.isNegative ? '- ' : ''}${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}:${milliseconds.toString().padLeft(3, '0')}';
  }

  String get _resetDisplayTime => '00:00:000';

  Future<void> startRecording() async {
    _startTimeStamp = millisecondsSinceEpoch + _recordingDelaySeconds * 1000;

    _displayTimeTimer =
        Timer.periodic(const Duration(milliseconds: 20), (timer) {
      displayTime = formattedElapsedTime;
      notifyListeners();
    });

    await Future.delayed(Duration(seconds: _recordingDelaySeconds));

    _isRecording = true;
    _recordedNotes.clear();

    if (isPlaybackPlaying && playbackPath != null) {
      playbackPlayer.seek(const Duration(seconds: 0));
      playbackPlayer.play();
    }

    if (isVisualizeMidiPlaying && visualizeMidiPath != null) {
      MidiFile parsedMidi =
          AppFileSystem.midiFileFromRecording(visualizeMidiPath!);

      for (List<MidiEvent> track in parsedMidi.tracks) {
        for (MidiEvent midiEvent in track) {
          if (midiEvent is NoteOnEvent) {
            int playedPianoKeyWhite = pianoKeysWhite.indexWhere(
                (pianoKeyWhite) =>
                    pianoKeyWhite[1] + midiOffset == midiEvent.noteNumber);
            int playedPianoKeyBlack =
                pianoKeysBlack.indexWhere((pianoKeyBlack) {
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

            print('n: ${midiEvent.noteNumber}');
            print('t: ${midiEvent.deltaTime}');
            print('d: ${midiEvent.duration}');
          }
        }
      }
    }
  }

  Future<void> stopRecording() async {
    _isRecording = false;
    _displayTimeTimer?.cancel();
    displayTime = _resetDisplayTime;

    if (playbackPath != null) {
      if (isPlaybackPlaying) {
        playbackPlayer.stop();
      }
      AppFileSystem.savePlaybackFile(File(playbackPath!), recordingTitle);
    }

    createMidiFile();
  }

  void toggleRecording() {
    if (_isRecording) {
      stopRecording();
    } else {
      startRecording();
    }

    notifyListeners();
  }

  void recordingAddNote(int midiNote, [double duration = 500]) {
    _recordedNotes.add([midiNote, _elapsedTime, duration]);
  }

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

    var outputFile = File(
        '${AppFileSystem.basePath}${Platform.pathSeparator}${AppFileSystem.recordingsFolder}${Platform.pathSeparator}$recordingTitle.mid');

    midiFile.writeFile(outputFile);
  }

  void setPlayback(String path) {
    playbackPath = path;
    playbackFileName = AppFileSystem.getFilenameFromPath(path);
    isPlaybackPlaying = true;
    playbackPlayer.setAudioSource(AudioSource.file(playbackPath!));

    notifyListeners();
  }

  void removePlayback() {
    isPlaybackPlaying = false;
    playbackPath = null;

    notifyListeners();
  }

  Future<void> setVisualizeMidi(String path) async {
    visualizeMidiPath = path;
    visualizeMidiFileName = AppFileSystem.getFilenameFromPath(path);
    isVisualizeMidiPlaying = true;

    notifyListeners();
  }

  void removeVisualizeMidi() {
    isVisualizeMidiPlaying = false;
    visualizeMidiPath = null;

    notifyListeners();
  }
}
