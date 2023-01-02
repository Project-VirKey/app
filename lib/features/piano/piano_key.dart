import 'package:audioplayers/audioplayers.dart';
import 'package:dart_melty_soundfont/dart_melty_soundfont.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mp_audio_stream/mp_audio_stream.dart';
import 'package:provider/provider.dart';
import 'package:virkey/common_widgets/app_text.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/fonts.dart';
import 'package:virkey/constants/radius.dart';
import 'package:virkey/features/piano/piano_provider.dart';
import 'package:virkey/utils/platform_helper.dart';

class PianoKeys {
  // C D E F G A B

  // C# D# F# G# A#
  // Db Eb Gb Ab Bb

  // C5
  static const midiOffset = 72;

  static List white = [
    ['C', 0, getAudioStream()],
    ['D', 2, getAudioStream()],
    ['E', 4, getAudioStream()],
    ['F', 5, getAudioStream()],
    ['G', 7, getAudioStream()],
    ['A', 9, getAudioStream()],
    ['B', 11, getAudioStream()]
  ];

  static const List black = [
    ['C#', 'Db', 1],
    ['D#', 'Eb', 3],
    [],
    ['F#', 'Gb', 6],
    ['G#', 'Ab', 8],
    ['A#', 'Bb', 10]
  ];

  static late ByteData bytes;
  static late Synthesizer synth;
  static final AudioStream audioStream = getAudioStream();

  void loadLibrary(String asset) async {
    // Create the synthesizer.
    bytes = await rootBundle.load(asset);

    synth = Synthesizer.loadByteData(
        bytes,
        SynthesizerSettings(
          sampleRate: 44100,
          blockSize: 64,
          maximumPolyphony: 64,
          enableReverbAndChorus: true,
        ));

    white[0][2].init();
  }
}

class PianoKeysWhite extends StatelessWidget {
  const PianoKeysWhite({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size mediaQuerySize = MediaQuery.of(context).size;
    double maxWidthDesktop = 1450;
    double maxHeightDesktop = 560;

    List<PianoKeyWhite> pianoKeys = [];
    PianoKeys.white.asMap().forEach((index, pianoKeyInfo) {
      pianoKeys.insert(
          index,
          PianoKeyWhite(
            name: pianoKeyInfo[0],
            midiNoteNumber: pianoKeyInfo[1] + PianoKeys.midiOffset,
            audioStream: pianoKeyInfo[2],
            parentWidth: maxWidthDesktop,
            topLeft:
                index == 0 && (mediaQuerySize.height * .9 >= maxHeightDesktop)
                    ? AppRadius.radius
                    : Radius.zero,
            topRight:
                index == 6 && (mediaQuerySize.height * .9 >= maxHeightDesktop)
                    ? AppRadius.radius
                    : Radius.zero,
          ));
    });

    return ConstrainedBox(
      constraints: BoxConstraints(
          maxWidth: mediaQuerySize.width >= maxWidthDesktop
              ? maxWidthDesktop
              : mediaQuerySize.width,
          maxHeight: mediaQuerySize.height >= maxHeightDesktop
              ? maxHeightDesktop
              : mediaQuerySize.height),
      child: Row(
        children: [...pianoKeys],
      ),
    );
  }
}

class PianoKeysBlack extends StatelessWidget {
  const PianoKeysBlack({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size mediaQuerySize = MediaQuery.of(context).size;
    double maxWidthDesktop = 1450;
    double maxHeightDesktop = 560;

    double parentWidth = mediaQuerySize.width >= maxWidthDesktop
        ? maxWidthDesktop
        : mediaQuerySize.width;
    double parentHeight = mediaQuerySize.height >= maxHeightDesktop
        ? maxHeightDesktop
        : mediaQuerySize.height;

    const double multiplierSpacer = .42;
    const double multiplierNoKey = 1.2;

    List<PianoKeyBlack> pianoKeys = [];

    pianoKeys.add(PianoKeyBlack(
      name: '',
      widthMultiplier: multiplierSpacer * multiplierNoKey,
      parentWidth: parentWidth,
      parentHeight: parentHeight,
    ));

    PianoKeys.black.asMap().forEach((index, pianoKey) {
      pianoKeys.add(PianoKeyBlack(
        name: '',
        widthMultiplier: multiplierSpacer,
        parentWidth: parentWidth,
        parentHeight: parentHeight,
      ));

      if (pianoKey.isEmpty) {
        pianoKeys.add(PianoKeyBlack(
          name: '',
          secondName: '',
          parentWidth: parentWidth,
          parentHeight: parentHeight,
        ));
      } else {
        pianoKeys.add(PianoKeyBlack(
          name: pianoKey[0],
          secondName: pianoKey[1],
          midiNoteNumber: pianoKey[2] + PianoKeys.midiOffset,
          parentWidth: parentWidth,
          parentHeight: parentHeight,
        ));
      }
    });

    pianoKeys.add(PianoKeyBlack(
      name: '',
      widthMultiplier: multiplierSpacer,
      parentWidth: parentWidth,
      parentHeight: parentHeight,
    ));

    pianoKeys.add(PianoKeyBlack(
      name: '',
      widthMultiplier: multiplierSpacer * multiplierNoKey,
      parentWidth: parentWidth,
      parentHeight: parentHeight,
    ));

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [...pianoKeys],
    );
  }
}

class PianoKeyWhite extends StatelessWidget {
  const PianoKeyWhite({
    Key? key,
    required this.name,
    required this.parentWidth,
    required this.topLeft,
    required this.topRight,
    required this.midiNoteNumber,
    required this.audioStream,
  }) : super(key: key);

  final String name;
  final double parentWidth;
  final Radius topLeft;
  final Radius topRight;
  final int midiNoteNumber;
  final AudioStream audioStream;

  @override
  Widget build(BuildContext context) {
    final player = AudioPlayer();
    player.setPlayerMode(PlayerMode.lowLatency);

    return Expanded(
      child: Stack(
        alignment: Alignment.centerRight,
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: const EdgeInsets.only(left: 5, right: 5, bottom: 5),
            child: Consumer<PianoProvider>(
              builder: (BuildContext context, PianoProvider pianoProvider,
                      Widget? child) =>
                  ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: AppColors.dark,
                  backgroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: AppRadius.radius,
                      bottomRight: AppRadius.radius,
                      topLeft: topLeft,
                      topRight: topRight,
                    ),
                  ),
                ),
                onPressed: () async {
                  if (pianoProvider.isRecording) {
                    pianoProvider.recordingAddNote(midiNoteNumber);
                  }

                  print(midiNoteNumber);

                  PianoKeys.synth.reset();
                  PianoKeys.synth
                      .noteOn(channel: 0, key: midiNoteNumber, velocity: 120);

                  // Render the waveform (3 seconds)
                  List<double> wave = List.filled(44100 * 3, 0);
                  PianoKeys.synth.renderMono(wave);

                  try {
                    PianoKeys.audioStream.uninit();
                  } catch (e) {
                    print(e);
                  }
                  PianoKeys.audioStream.init();

                  audioStream.push(Float32List.fromList(wave));
                },
                child: Container(
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.only(bottom: 25),
                  child: AppText(
                    text: name,
                    size: parentWidth * .04,
                    color: AppColors.dark,
                    family: AppFonts.secondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PianoKeyBlack extends StatelessWidget {
  const PianoKeyBlack({
    Key? key,
    required this.name,
    this.midiNoteNumber = 0,
    this.secondName = '',
    this.widthMultiplier = 1,
    required this.parentWidth,
    required this.parentHeight,
  }) : super(key: key);

  final String name;
  final int midiNoteNumber;
  final String secondName;
  final double widthMultiplier;
  final double parentWidth;
  final double parentHeight;

  @override
  Widget build(BuildContext context) {
    if (name.isEmpty) {
      return Container(
        width: parentWidth * .1 * widthMultiplier,
      );
    } else {
      return SizedBox(
        width: parentWidth * .1,
        height: PlatformHelper.isDesktop
            ? (parentHeight * .6)
            : (parentHeight * .54),
        child: Consumer<PianoProvider>(
          builder: (BuildContext context, PianoProvider pianoProvider,
                  Widget? child) =>
              ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              foregroundColor: AppColors.white,
              backgroundColor: AppColors.dark,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: AppRadius.radius,
                  bottomRight: AppRadius.radius,
                ),
              ),
            ),
            // onPressed: () => FlutterMidi().playMidiNote(midi: midiNoteNumber),
            onPressed: () {
              if (pianoProvider.isRecording) {
                pianoProvider.recordingAddNote(midiNoteNumber);
              }
            },
            child: Container(
              alignment: Alignment.bottomCenter,
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppText(
                    text: name,
                    size: parentWidth * .045,
                    color: AppColors.secondary,
                    family: AppFonts.secondary,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  AppText(
                    text: secondName,
                    size: parentWidth * .033,
                    color: AppColors.secondary,
                    family: AppFonts.secondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}
