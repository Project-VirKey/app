import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:provider/provider.dart';
import 'package:virkey/common_widgets/app_button.dart';
import 'package:virkey/common_widgets/app_text.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/fonts.dart';
import 'package:virkey/features/midi_device/midi_device_provider.dart';

class TempMidiStatus extends StatelessWidget {
  const TempMidiStatus({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(
          color: AppColors.dark,
          thickness: 5,
        ),
        Consumer<MidiDeviceProvider>(
          builder: (BuildContext context, MidiDeviceProvider midiDeviceProvider,
                  Widget? child) =>
              Column(
            children: [
              AppButton(
                  appText: const AppText(text: 'Connect First Device'),
                  onPressed: () {
                    midiDeviceProvider.connectToFirstDevice();
                  }),
              AppButton(
                  appText: const AppText(text: 'Disconnect'),
                  onPressed: () {
                    midiDeviceProvider.disconnectDevice();
                  }),
              const AppText(
                text: 'Device Setup',
                weight: AppFonts.weightMedium,
              ),
              AppText(text: midiDeviceProvider.setupData),
              const AppText(
                text: 'Devices',
                weight: AppFonts.weightMedium,
              ),
              AppText(
                  text: midiDeviceProvider.midiDevices
                          ?.map((e) => e.name)
                          .toString() ??
                      '()'),
              const AppText(
                text: 'Connected Device',
                weight: AppFonts.weightMedium,
              ),
              AppText(text: 'Status: ${midiDeviceProvider.connected}'),
              AppText(
                  text:
                      'Device Name: ${midiDeviceProvider.connectedDeviceName}'),
              const AppText(
                text: 'Received Data',
                weight: AppFonts.weightMedium,
              ),
              SingleChildScrollView(
                child: Column(
                  children: [
                    for (MidiPacket midiPacket in midiDeviceProvider.midiEvents)
                      AppText(
                          text:
                              'Timestamp: ${midiPacket.timestamp} | Device Name: ${midiPacket.device.name} | Data: ${midiPacket.data.toString()}'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(
          color: AppColors.dark,
          thickness: 5,
        ),
      ],
    );
  }
}
