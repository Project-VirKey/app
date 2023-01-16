import 'dart:convert';
import 'dart:io';

import 'package:dart_melty_soundfont/dart_melty_soundfont.dart';
import 'package:dart_midi/dart_midi.dart';
import 'package:ffmpeg_cli/ffmpeg_cli.dart' hide Stream;
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

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

  static void loadLibrary(String path, [bool isAsset = false]) async {
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
      white[wK][2] = loadPianoKeyPcm(white[wK][1] + midiOffset);
      white[wK][3] = AudioPlayer();
      white[wK][3].setAudioSource(
          MyCustomSource(wrapAudioDataInWavFileFormat(white[wK][2])));
    }

    for (var bK = 0; bK < black.length; bK++) {
      if (black[bK].isEmpty) {
        continue;
      }
      black[bK][2] = loadPianoKeyPcm(black[bK][1] + midiOffset);
      black[bK][3] = AudioPlayer();
      black[bK][3].setAudioSource(
          MyCustomSource(wrapAudioDataInWavFileFormat(black[bK][2])));
    }
  }

  static Uint8List loadPianoKeyPcm(int midiNote) {
    synth.reset();
    synth.noteOn(channel: 0, key: midiNote, velocity: 120);

    // Render the waveform (3 seconds)
    ArrayInt16 buf16 = ArrayInt16.zeros(numShorts: sampleRate * seconds);
    synth.renderMonoInt16(buf16);

    return buf16.bytes.buffer.asUint8List();
  }

  static Uint8List wrapAudioDataInWavFileFormat(Uint8List pcmData) {
    List<int> wavDataIntList = [];
    int dataBytesCount = pcmData.buffer.asInt8List().length;

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
    wavDataIntList.addAll(pcmData.buffer.asInt8List());

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

  static Future<void> midiToWav(
      MidiFile midiFile, String destinationPath) async {
    String tempDirPath = (await getTemporaryDirectory()).path;
    print(tempDirPath);

    List<String> tempFilePaths = [];

    if (midiFile.tracks.length < 2) {
      // TODO: no tracks
    }

    List<NoteOnEvent> noteOnEvents =
        midiFile.tracks[1].whereType<NoteOnEvent>().toList();
    int previousDeltaTime = 0;
    int index = 0;
    for (NoteOnEvent noteOnEvent in noteOnEvents) {
      int playedPianoKeyWhite = Piano.white.indexWhere((pianoKeyWhite) =>
          pianoKeyWhite[1] + Piano.midiOffset == noteOnEvent.noteNumber);

      int playedPianoKeyBlack = Piano.black.indexWhere((pianoKeyBlack) {
        if (pianoKeyBlack.isEmpty) {
          return false;
        }
        return (pianoKeyBlack[1] + Piano.midiOffset) == noteOnEvent.noteNumber;
      });

      if (playedPianoKeyWhite >= 0 || playedPianoKeyBlack >= 0) {
        previousDeltaTime += noteOnEvent.deltaTime;
        index++;
      }

      print(
          'deltaSum - ${(sampleRate * 2 * (previousDeltaTime / 1000)).round()}');
      int neededEmptyBytes =
          (sampleRate * 2 * (previousDeltaTime / 1000)).round();
      if (neededEmptyBytes.isOdd) {
        neededEmptyBytes--;
      }
      List<int> emptyBytes = List.filled(neededEmptyBytes, 0);

      if (playedPianoKeyWhite >= 0) {
        File wavFile =
            File('$tempDirPath${Platform.pathSeparator}temp_white_$index.wav');
        wavFile.writeAsBytesSync(wrapAudioDataInWavFileFormat(
            Uint8List.fromList(
                [...emptyBytes, ...white[playedPianoKeyWhite][2]])));
        tempFilePaths.add(wavFile.path);
      }

      if (playedPianoKeyBlack >= 0) {
        File wavFile =
            File('$tempDirPath${Platform.pathSeparator}temp_black_$index.wav');
        wavFile.writeAsBytesSync(wrapAudioDataInWavFileFormat(
            Uint8List.fromList(
                [...emptyBytes, ...black[playedPianoKeyBlack][2]])));
        tempFilePaths.add(wavFile.path);
      }
    }

    print(destinationPath);
    combineAudioFiles(destinationPath, tempFilePaths);
  }

  static Future<void> combineAudioFiles(
      String outputFilepath, List<String> inputFilePaths) async {
    final FfmpegCommand ffmpegCommand = FfmpegCommand(
      inputs: [],
      args: [
        for (final arg in inputFilePaths) ...[CliArg(name: 'i', value: arg)],
      ],
      filterGraph: FilterGraph(chains: [
        FilterChain(
            inputs: [],
            filters: [CustomAMixFilter(inputCount: inputFilePaths.length)],
            outputs: [])
      ]),
      outputFilepath: outputFilepath,
    );

    print(ffmpegCommand.toCli());
    await Ffmpeg().run(ffmpegCommand);
  }
}

class CustomAMixFilter implements Filter {
  const CustomAMixFilter({
    required this.inputCount,
  });

  final int inputCount;

  @override
  String toCli() {
    return 'amix=inputs=$inputCount:duration=longest';
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