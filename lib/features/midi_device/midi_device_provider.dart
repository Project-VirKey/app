import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';

class MidiDeviceProvider extends ChangeNotifier {
  MidiDeviceProvider() {
    // print(MidiCommand().devices);
  }
}

class AppMidiTest {
  static Future<void> test() async {
    MidiCommand midiCommand = MidiCommand();

    List<MidiDevice>? midiDevices = await midiCommand.devices;
    if (midiDevices != null && midiDevices.isNotEmpty) {
      midiCommand.disconnectDevice(midiDevices.first);

      print('--> ${midiDevices.length}');
      print('--> ${midiDevices.first.inputPorts.first.type.name}');

      await midiCommand.connectToDevice(midiDevices.first).whenComplete(() {
        midiCommand.onMidiSetupChanged?.listen((data) async {
          print("setup changed $data");
        });

        print('--> Connected to MidiDevice ${midiDevices.first.name}');

        // TODO: listen to midi input does not work
        midiCommand.onMidiDataReceived?.listen((MidiPacket event) {
          print(event.device.name);
          print(event.timestamp);
          print(event.data);
        });
      });
    }
  }
}
