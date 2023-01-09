import 'dart:convert';
import 'dart:io';

import 'package:dart_melty_soundfont/dart_melty_soundfont.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:virkey/common_widgets/app_text.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/fonts.dart';
import 'package:virkey/constants/radius.dart';
import 'package:virkey/features/piano/piano_provider.dart';
import 'package:virkey/utils/platform_helper.dart';
import 'package:virkey/utils/timestamp.dart';

class Piano {
  // C D E F G A B

  // C# D# F# G# A#
  // Db Eb Gb Ab Bb

  // C5
  static const midiOffset = 72;

  static List white = [
    [
      ['C'],
      0,
      null,
      null
    ],
    [
      ['D'],
      2,
      null,
      null
    ],
    [
      ['E'],
      4,
      null,
      null
    ],
    [
      ['F'],
      5,
      null,
      null
    ],
    [
      ['G'],
      7,
      null,
      null
    ],
    [
      ['A'],
      9,
      null,
      null
    ],
    [
      ['B'],
      11,
      null,
      null
    ]
  ];

  static List black = [
    [
      ['C#', 'Db'],
      1,
      null,
      null
    ],
    [
      ['D#', 'Eb'],
      3,
      null,
      null
    ],
    [],
    [
      ['F#', 'Gb'],
      6,
      null,
      null
    ],
    [
      ['G#', 'Ab'],
      8,
      null,
      null
    ],
    [
      ['A#', 'Bb'],
      10,
      null,
      null
    ]
  ];

  static const int sampleRate = 44100;
  static const int channels = 1;
  static const int bitsPerSample = 16;
  static const int seconds = 3;

  static late ByteData bytes;
  static late Synthesizer synth;

  void loadLibrary(String path, [bool isAsset = false]) async {
    if (isAsset) {
      bytes = await rootBundle.load(path);
    } else {
      bytes = File(path).readAsBytesSync().buffer.asByteData();
    }

    // Create the synthesizer
    synth = Synthesizer.loadByteData(
        bytes,
        SynthesizerSettings(
          sampleRate: sampleRate,
          blockSize: 64,
          maximumPolyphony: 64,
          enableReverbAndChorus: true,
        ));

    for (var wK = 0; wK < white.length; wK++) {
      white[wK][2] = loadPianoKeyWAV(white[wK][1] + midiOffset);
      white[wK][3] = AudioPlayer();
      white[wK][3].setAudioSource(MyCustomSource(white[wK][2]));
    }

    for (var bK = 0; bK < black.length; bK++) {
      if (black[bK].isEmpty) {
        continue;
      }
      black[bK][2] = loadPianoKeyWAV(black[bK][1] + midiOffset);
      black[bK][3] = AudioPlayer();
      black[bK][3].setAudioSource(MyCustomSource(black[bK][2]));
    }
  }

  static Uint8List loadPianoKeyWAV(int midiNote) {
    synth.reset();
    synth.noteOn(channel: 0, key: midiNote, velocity: 120);

    // Render the waveform (3 seconds)
    ArrayInt16 buf16 = ArrayInt16.zeros(numShorts: sampleRate * seconds);
    synth.renderMonoInt16(buf16);

    int dataBytesCount = buf16.bytes.buffer.asInt8List().length;

    List<int> wavDataIntList = [];

    // WAV - Data Structure Documentation (Wav file format)
    // https://sites.google.com/site/musicgapi/technical-documents/wav-file-format, 07.01.2022

    // Write a WAV file from scratch - C++ Audio Programming
    // https://youtu.be/qqjvB_VxMRM?t=1333, 07.01.2022

    // WAV Files: File Structure, Case Analysis and PCM Explained
    // https://www.videoproc.com/resource/wav-file.htm, 07.01.2022

    // WAV - Example Data & Documentation
    // http://www.topherlee.com/software/pcm-tut-wavformat.html, 07.01.2022

    // Wave File Header - RIFF Type Chunk
    // ChunkID: "RIFF"
    wavDataIntList.addAll(stringToUint8ListToList('RIFF'));
    // Chunk Data Size: length of waveform + 36 (size of header minus 8 (size of file header))
    wavDataIntList
        .addAll(int8ToInt32ToUint8ListWith4BytesToList(dataBytesCount + 36));
    // ChunkID: "WAVE"
    wavDataIntList.addAll(stringToUint8ListToList('WAVE'));

    // Format Chunk - fmt
    // ChunkID: "fmt "
    wavDataIntList.addAll(stringToUint8ListToList('fmt '));
    // Chunk Data Size: 16 Bytes
    wavDataIntList.addAll(int8ToUint8ListWith4BytesToList(16));
    // Compression Code: 1 (= PCM - Pulse Code Modulation)
    wavDataIntList.addAll(int8ToUint8ListWith2BytesToList(1));
    // Number of Channels: 1 (mono)
    wavDataIntList.addAll(int8ToUint8ListWith2BytesToList(channels));
    // Sample Rate: 44100 Hz
    wavDataIntList.addAll(int8ToInt32ToUint8ListWith4BytesToList(sampleRate));
    // Average Bytes per Second
    wavDataIntList.addAll(int8ToInt32ToUint8ListWith4BytesToList(
        (sampleRate * bitsPerSample * channels) ~/ 8));
    // Block Align: number of bytes per sample slice
    wavDataIntList.addAll(
        int8ToUint8ListWith2BytesToList((bitsPerSample * channels) ~/ 8));
    // Significant Bits per Sample: 16 Bit
    wavDataIntList.addAll(int8ToUint8ListWith2BytesToList(bitsPerSample));

    // Data Chunk - data
    // ChunkID: "data"
    wavDataIntList.addAll(stringToUint8ListToList('data'));
    // Chunk Data Size: length of waveform
    wavDataIntList
        .addAll(int8ToInt32ToUint8ListWith4BytesToList(dataBytesCount));
    // sample data: PCM data
    wavDataIntList.addAll(buf16.bytes.buffer.asInt8List());

    return Uint8List.fromList(wavDataIntList);
  }

  static List<int> stringToUint8ListToList(String input) =>
      ascii.encode(input).toList();

  static List<int> int8ToUint8ListWith2BytesToList(int input) =>
      (Uint8List(2)..buffer.asByteData().setInt8(0, input));

  static List<int> int8ToUint8ListWith4BytesToList(int input) =>
      (Uint8List(4)..buffer.asByteData().setUint8(0, input));

  static List<int> int8ToInt32ToUint8ListWith4BytesToList(int input) =>
      (Uint8List(4)..buffer.asByteData().setInt32(0, input, Endian.big))
          .reversed
          .toList();

  static AudioPlayer notePlayer = AudioPlayer();

  static void playPianoNote(int arIndex, [bool isBlackKey = false]) {
    // initiate AudioPlayer and use WAV-File-Byte-Data as source

    if (isBlackKey) {
      black[arIndex][3].seek(const Duration(seconds: 0));
      black[arIndex][3].play();
    } else {
      white[arIndex][3].seek(const Duration(seconds: 0));
      white[arIndex][3].play();
    }
  }
}

// Feed your own stream of bytes into the player
class MyCustomSource extends StreamAudioSource {
  final List<int> bytes;

  MyCustomSource(this.bytes);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= bytes.length;
    return StreamAudioResponse(
      sourceLength: bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(bytes.sublist(start, end)),
      contentType: 'audio/mpeg',
    );
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
    Piano.white.asMap().forEach((index, pianoKeyInfo) {
      pianoKeys.insert(
          index,
          PianoKeyWhite(
            name: pianoKeyInfo[0][0],
            index: index,
            midiNoteNumber: pianoKeyInfo[1] + Piano.midiOffset,
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

    Piano.black.asMap().forEach((index, pianoKey) {
      pianoKeys.add(PianoKeyBlack(
        name: '',
        widthMultiplier: multiplierSpacer,
        parentWidth: parentWidth,
        parentHeight: parentHeight,
      ));

      int position = index;
      if (pianoKey.isEmpty) {
        position -= 1;
        pianoKeys.add(PianoKeyBlack(
          name: '',
          secondName: '',
          parentWidth: parentWidth,
          parentHeight: parentHeight,
        ));
      } else {
        pianoKeys.add(PianoKeyBlack(
          name: pianoKey[0][0],
          secondName: pianoKey[0][1],
          index: position,
          midiNoteNumber: pianoKey[1] + Piano.midiOffset,
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
    required this.index,
    required this.midiNoteNumber,
  }) : super(key: key);

  final String name;
  final double parentWidth;
  final Radius topLeft;
  final Radius topRight;
  final int index;
  final int midiNoteNumber;

  @override
  Widget build(BuildContext context) {
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
                  GestureDetector(
                onTapDown: (details) {},
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppColors.dark,
                    backgroundColor: AppColors.white,
                    // backgroundColor: longPress
                    //     ? const Color(0xffdedede)
                    //     : (pianoProvider.pianoKeysWhite[widget.index][2]
                    //         ? AppColors.primary
                    //         : AppColors.white),
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

                    Piano.playPianoNote(index);
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
    this.index = 0,
    this.midiNoteNumber = 0,
    this.secondName = '',
    this.widthMultiplier = 1,
    required this.parentWidth,
    required this.parentHeight,
  }) : super(key: key);

  final String name;
  final int index;
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
              GestureDetector(
            onTapDown: (details) {
            },
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                foregroundColor: AppColors.white,
                backgroundColor: AppColors.dark,
                // backgroundColor: longPress
                //     ? const Color(0xff454545)
                //     : (pianoProvider.pianoKeysBlack[widget.index][3]
                //         ? AppColors.primary
                //         : AppColors.dark),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: AppRadius.radius,
                    bottomRight: AppRadius.radius,
                  ),
                ),
              ),
              onPressed: () {
                if (pianoProvider.isRecording) {
                  pianoProvider.recordingAddNote(midiNoteNumber);
                }

                Piano.playPianoNote(index, true);
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
        ),
      );
    }
  }
}
