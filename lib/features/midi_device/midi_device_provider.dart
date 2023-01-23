import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:libserialport/libserialport.dart';

class MidiDeviceProvider extends ChangeNotifier {
  MidiCommand midiCommand = MidiCommand();

  String setupData = '';
  List<MidiDevice>? midiDevices;
  bool connected = false;
  String? connectedDeviceName;

  StreamSubscription<String>? midiSetupStream;
  StreamSubscription<MidiPacket>? midiDataReceiveStream;

  List<MidiPacket> midiEvents = [];

  MidiDeviceProvider() {
    // initialLoad();
    initialLoad1();
  }

  Future<void> initialLoad1() async {
    final ports = SerialPort.availablePorts;
    print(ports);
    final name = ports.first;
    final port = SerialPort(name);

    if (!port.openReadWrite()) {
      print(SerialPort.lastError);
      return;
    }

    final reader = SerialPortReader(port);
    reader.stream.listen((data) {
      print('received: $data');
    });
  }

  Future<void> initialLoad() async {
    midiSetupStream = midiCommand.onMidiSetupChanged?.listen((data) async {
      print("setup changed $data");
      setupData = data;
      midiDevices = await midiCommand.devices;

      notifyListeners();
    });
  }

  Future<void> connectToFirstDevice() async {
    if (midiDevices != null) {
      if (midiDevices!.isNotEmpty) {
        midiCommand.disconnectDevice(midiDevices!.first);
      } else {
        connected = false;
        connectedDeviceName = null;
      }
      midiDataReceiveStream?.cancel();

      print('--> ${midiDevices?.length}');
      print('--> ${midiDevices?.first.inputPorts.first.type.name}');

      await midiCommand.connectToDevice(midiDevices!.first).whenComplete(() {
        print('--> Connected to MidiDevice ${midiDevices?.first.name}');
        connected = true;
        connectedDeviceName = midiDevices?.first.name;

        // TODO: listen to midi input does not work
        midiDataReceiveStream =
            midiCommand.onMidiDataReceived?.listen((MidiPacket event) {
          print(event.device.name);
          print(event.timestamp);
          print(event.data);

          midiEvents.insert(0, event);

          notifyListeners();
        });
      });
    }
  }

  void disconnectDevice() {
    connected = false;
    connectedDeviceName = null;
    midiDataReceiveStream?.cancel();
    if (midiDevices != null) {
      if (midiDevices!.isNotEmpty) {
        midiCommand.disconnectDevice(midiDevices!.first);
      }
    }
  }
}
