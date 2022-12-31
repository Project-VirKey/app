import 'dart:io';

import 'package:flutter/material.dart';
import 'package:midi_util/midi_util.dart';
import 'package:virkey/utils/file_system.dart';

class PianoProvider extends ChangeNotifier {
  final List _recordedNotes = [];
  bool _isRecording = false;
  late int _startTimeStamp;

  List get recordedNotes => _recordedNotes;

  bool get isRecording => _isRecording;

  int get _millisecondsSinceEpoch => DateTime.now().millisecondsSinceEpoch;

  void startRecording() {
    _isRecording = true;
    _recordedNotes.clear();
    _startTimeStamp = _millisecondsSinceEpoch;
  }

  void stopRecording() {
    _isRecording = false;
    createMidiFile();
  }

  void toggleRecording() {
    if (_isRecording) {
      stopRecording();
    } else {
      startRecording();
    }

    print(_isRecording);

    notifyListeners();
  }

  void recordingAddNote(int midiNote) {
    _recordedNotes.add([midiNote, _millisecondsSinceEpoch]);
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
          time: (_recordedNotes[i][1] - _startTimeStamp) / 1000,
          duration: duration,
          volume: volume);
    });

    var outputFile = File(
        '${AppFileSystem.basePath}${Platform.pathSeparator}Recordings${Platform.pathSeparator}test.mid');

    midiFile.writeFile(outputFile);
  }
}
