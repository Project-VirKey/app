import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:midi_util/midi_util.dart';
import 'package:virkey/utils/file_system.dart';

class PianoProvider extends ChangeNotifier {
  final List _recordedNotes = [];
  bool _isRecording = false;
  int _startTimeStamp = 0;

  String recordingTitle = '';

  String displayTime = '';
  Timer? _displayTimeTimer;

  final int _recordingDelaySeconds = 3;

  List get recordedNotes => _recordedNotes;

  bool get isRecording => _isRecording;

  int get _millisecondsSinceEpoch => DateTime.now().millisecondsSinceEpoch;

  int get _elapsedTime => _millisecondsSinceEpoch - _startTimeStamp;

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
    _startTimeStamp = _millisecondsSinceEpoch + _recordingDelaySeconds * 1000;

    _displayTimeTimer =
        Timer.periodic(const Duration(milliseconds: 20), (timer) {
      displayTime = formattedElapsedTime;
      notifyListeners();
    });

    await Future.delayed(Duration(seconds: _recordingDelaySeconds));

    _isRecording = true;
    _recordedNotes.clear();
  }

  void stopRecording() {
    _isRecording = false;
    _displayTimeTimer?.cancel();
    displayTime = _resetDisplayTime;
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

  void recordingAddNote(int midiNote) {
    _recordedNotes.add([midiNote, _elapsedTime]);
  }

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

    var outputFile = File(
        '${AppFileSystem.basePath}${Platform.pathSeparator}${AppFileSystem.recordingsFolder}${Platform.pathSeparator}$recordingTitle.mid');

    midiFile.writeFile(outputFile);
  }
}
