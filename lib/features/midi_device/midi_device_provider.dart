import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:virkey/features/piano/piano.dart';
import 'package:virkey/features/piano/piano_provider.dart';
import 'package:virkey/routing/router.dart';

class MidiDeviceProvider extends ChangeNotifier {
  final MidiCommand _midiCommand = MidiCommand();

  String setupData = '';
  List<MidiDevice>? midiDevices;
  bool connected = false;
  String? connectedDeviceName;

  StreamSubscription<MidiPacket>? _midiDataReceiveStream;

  List<Uint8List> midiEvents = [];

  MidiDeviceProvider(this._pianoProvider) {
    initialLoad();
  }

  PianoProvider _pianoProvider;

  setPianoProvider(PianoProvider pP) {
    _pianoProvider = pP;
    notifyListeners();
  }

  // name of the Firmware for Arduino under which the MIDI-device will be listed
  // https://github.com/kuwatay/mocolufa, 14.02.2023
  static const _deviceName = 'MocoLUFA';
  static const _deviceNameAndroid = 'kuwatay@nifty.com MocoLUFA';

  Future<void> initialLoad() async {
    // lookup connected midi devices (at the app startup)
    _midiCommand.devices.then((List<MidiDevice>? mD) {
      midiDevices = mD;

      if (midiDevices == null) {
        disconnectDevice();
      }

      if (!connected && midiDevices != null) {
        connectToDevice();
      }

      notifyListeners();
    });

    // listen for changes in the future
    _midiCommand.onMidiSetupChanged?.listen((data) async {
      // print("setup changed $data");
      setupData = data;
      midiDevices = await _midiCommand.devices;

      if (midiDevice == null) {
        disconnectDevice();
      }

      if (!connected && midiDevices != null) {
        connectToDevice();
      }

      notifyListeners();
    });
  }

  MidiDevice? get midiDevice {
    if (midiDevices == null) {
      return null;
    }

    Iterable<MidiDevice>? devices = midiDevices?.where((MidiDevice mD) =>
        mD.name == _deviceName || mD.name == _deviceNameAndroid);
    if (devices == null) {
      return null;
    } else {
      if (devices.isNotEmpty) {
        return devices.first;
      }
    }
    return null;
  }

  Future<void> connectToDevice() async {
    if (midiDevice == null) {
      return;
    }

    _midiCommand.disconnectDevice(midiDevice!);
    _midiDataReceiveStream?.cancel();

    await _midiCommand.connectToDevice(midiDevice!).whenComplete(() {
      print('--> Connected to MidiDevice ${midiDevices?.first.name}');
      connected = true;
      connectedDeviceName = midiDevices?.first.name;

      _midiDataReceiveStream =
          _midiCommand.onMidiDataReceived?.listen((MidiPacket event) {
        print(event.data);

        midiEvents.insert(0, event.data);
        notifyListeners();

        if (AppRouter.router.location != '/piano') {
          return;
        }

        // if event id not NoteOn or NoteOff -> return
        if (event.data[0] != 144 && event.data[0] != 128) {
          return;
        }

        int octaveIndex = Piano.getOctaveIndexFromMidiNote(event.data[1]);

        int playedPianoKeyWhite =
            Piano.getPianoKeyWhiteIndex(event.data[1], octaveIndex);

        int playedPianoKeyBlack =
            Piano.getPianoKeyBlackIndex(event.data[1], octaveIndex);

        // if element at third position at Uint8List is zero => NoteOff
        // -> only NoteOn-Events are being used
        if (event.data[2] == 0) {
          if (playedPianoKeyWhite >= 0) {
            _pianoProvider.pianoKeysWhite[playedPianoKeyWhite][1] = false;
            _pianoProvider.notify();
          }

          if (playedPianoKeyBlack >= 0) {
            _pianoProvider.pianoKeysBlack[playedPianoKeyBlack][1] = false;
            _pianoProvider.notify();
          }
        } else {
          if (playedPianoKeyWhite >= 0 || playedPianoKeyBlack >= 0) {
            _pianoProvider.currentOctaveIndex = octaveIndex;
          }

          if (playedPianoKeyWhite >= 0) {
            _pianoProvider.pianoKeysWhite[playedPianoKeyWhite][1] = true;
            if (_pianoProvider.isRecording) {
              _pianoProvider.recordingAddNote(
                  _pianoProvider.currentOctaveIndex, event.data[1]);
            }
            _pianoProvider.notify();
            Piano.playPianoNote(octaveIndex, playedPianoKeyWhite);
          }

          if (playedPianoKeyBlack >= 0) {
            _pianoProvider.pianoKeysBlack[playedPianoKeyBlack][1] = true;
            if (_pianoProvider.isRecording) {
              _pianoProvider.recordingAddNote(
                  _pianoProvider.currentOctaveIndex, event.data[1]);
            }
            _pianoProvider.notify();
            Piano.playPianoNote(octaveIndex, playedPianoKeyBlack, true);
          }
        }
      });
    });
  }

  void disconnectDevice() {
    connected = false;
    connectedDeviceName = null;
    _midiDataReceiveStream?.cancel();
    if (midiDevice != null) {
      _midiCommand.disconnectDevice(midiDevice!);
    }
  }
}
