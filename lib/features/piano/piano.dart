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

  //   0 = 48 => C3
  // +12 = 60 => C4
  // +12 = 72 => C5
  static const midiOffset = 48;
  static const keysPerOctave = 12;

  // list of 3 entries for each octave
  // each containing a list of two entries for the audio data & audio player
  static List whiteKeyData = [];
  static List whiteKeyPlayer = [];

  static List blackKeyData = [];
  static List blackKeyPlayer = [];

  static const List white = [
    [
      ['C'],
      0
    ],
    [
      ['D'],
      2
    ],
    [
      ['E'],
      4
    ],
    [
      ['F'],
      5
    ],
    [
      ['G'],
      7
    ],
    [
      ['A'],
      9
    ],
    [
      ['B'],
      11
    ]
  ];

  static const List black = [
    [
      ['C#', 'Db'],
      1
    ],
    [
      ['D#', 'Eb'],
      3
    ],
    [],
    [
      ['F#', 'Gb'],
      6
    ],
    [
      ['G#', 'Ab'],
      8
    ],
    [
      ['A#', 'Bb'],
      10
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

    whiteKeyData.clear();
    blackKeyData.clear();
    whiteKeyPlayer.clear();
    blackKeyPlayer.clear();

    for (int o = 0; o < 3; o++) {
      whiteKeyData.add([]);
      whiteKeyPlayer.add([]);

      for (var wK = 0; wK < white.length; wK++) {
        whiteKeyData[o].add(
            loadPianoKeyPcm(white[wK][1] + midiOffset + (o * keysPerOctave)));
        whiteKeyPlayer[o].add(AudioPlayer());
        whiteKeyPlayer[o][wK].setAudioSource(
            MyCustomSource(wrapAudioDataInWavFileFormat(whiteKeyData[o][wK])));
      }

      blackKeyData.add([]);
      blackKeyPlayer.add([]);

      for (var bK = 0; bK < black.length; bK++) {
        if (black[bK].isEmpty) {
          blackKeyData[o].add(null);
          blackKeyPlayer[o].add(null);
          continue;
        }

        blackKeyData[o].add(
            loadPianoKeyPcm(black[bK][1] + midiOffset + (o * keysPerOctave)));
        blackKeyPlayer[o].add(AudioPlayer());
        blackKeyPlayer[o][bK].setAudioSource(
            MyCustomSource(wrapAudioDataInWavFileFormat(blackKeyData[o][bK])));
      }
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

  static void playPianoNote(int octaveIndex, int arIndex,
      [bool isBlackKey = false]) {
    // initiate AudioPlayer and use WAV-File-Byte-Data as source

    if (isBlackKey) {
      blackKeyPlayer[octaveIndex][arIndex].seek(const Duration(seconds: 0));
      blackKeyPlayer[octaveIndex][arIndex].play();
    } else {
      whiteKeyPlayer[octaveIndex][arIndex].seek(const Duration(seconds: 0));
      whiteKeyPlayer[octaveIndex][arIndex].play();
    }
  }

  static int getOctaveIndexFromMidiNote(int midiNote) {
    if (midiNote >= Piano.midiOffset &&
        midiNote < (Piano.midiOffset + Piano.keysPerOctave)) {
      return 0;
    } else if (midiNote + Piano.keysPerOctave >= Piano.midiOffset &&
        midiNote < (Piano.midiOffset + 2 * Piano.keysPerOctave)) {
      return 1;
    } else if (midiNote + 2 * Piano.keysPerOctave >= Piano.midiOffset &&
        midiNote < (Piano.midiOffset + 3 * Piano.keysPerOctave)) {
      return 2;
    } else {
      return 1;
    }
  }

  static MidiParser midiParser = MidiParser();

  static Future<void> midiToWav(
      String midiFilePath, String destinationPath) async {
    MidiFile midiFile = midiParser.parseMidiFromFile(File(midiFilePath));

    String tempDirPath = (await getTemporaryDirectory()).path;

    List<String> tempFilePaths = [];

    if (midiFile.tracks.length < 2 || midiFile.header.ticksPerBeat == null) {
      return;
    }

    List<NoteOnEvent> noteOnEvents =
        midiFile.tracks[1].whereType<NoteOnEvent>().toList();
    int previousDeltaTime = 0;
    int index = 0;

    int ticksPerQuarter = midiFile.header.ticksPerBeat as int;
    int microSecondsPerQuarter = 0;
    double microSecondsPerTick = 0;
    double milliSecondsPerTick = 0;
    // loop for midiEvent

    for (int i = 0; i < midiFile.tracks[1].length; i++) {
      MidiEvent midiEvent = midiFile.tracks[1][i];

      if (midiEvent is SetTempoEvent) {
        microSecondsPerQuarter = midiEvent.microsecondsPerBeat;
        microSecondsPerTick = microSecondsPerQuarter / ticksPerQuarter;
        milliSecondsPerTick = microSecondsPerTick / 1000;
      }

      if (midiEvent is! NoteOnEvent) {
        continue;
      }

      int octaveIndex = Piano.getOctaveIndexFromMidiNote(midiEvent.noteNumber);

      int playedPianoKeyWhite = Piano.white.indexWhere((pianoKeyWhite) =>
          pianoKeyWhite[1] +
              Piano.midiOffset +
              (octaveIndex * Piano.keysPerOctave) ==
          midiEvent.noteNumber);

      int playedPianoKeyBlack = Piano.black.indexWhere((pianoKeyBlack) {
        if (pianoKeyBlack.isEmpty) {
          return false;
        }
        return (pianoKeyBlack[1] +
                Piano.midiOffset +
                (octaveIndex * Piano.keysPerOctave)) ==
            midiEvent.noteNumber;
      });

      if (playedPianoKeyWhite >= 0 || playedPianoKeyBlack >= 0) {
        previousDeltaTime +=
            (midiEvent.deltaTime * milliSecondsPerTick).round();
        index++;
      }

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
            Uint8List.fromList([
          ...emptyBytes,
          ...whiteKeyData[octaveIndex][playedPianoKeyWhite]
        ])));
        tempFilePaths.add(wavFile.path);
      }

      if (playedPianoKeyBlack >= 0) {
        File wavFile =
            File('$tempDirPath${Platform.pathSeparator}temp_black_$index.wav');
        wavFile.writeAsBytesSync(wrapAudioDataInWavFileFormat(
            Uint8List.fromList([
          ...emptyBytes,
          ...blackKeyData[octaveIndex][playedPianoKeyBlack]
        ])));
        tempFilePaths.add(wavFile.path);
      }
    }

    print(destinationPath);
    await combineAudioFiles(destinationPath, tempFilePaths);
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
    // FFMPEG amix filter volume issue with inputs of different duration
    // https://stackoverflow.com/a/38714779/17399214, 31.01.2023
    // solution: add dynaudnorm filter after the amix filter
    // ffmpeg dynaudnorm filter (Dynamic Audio Normalizer)
    // https://ffmpeg.org/ffmpeg-filters.html#dynaudnorm, 31.01.2023
    // TODO: test dynaudnorm filter

    // ffmpeg amix filter: for combining all generated audio files to one
    // duration=longest -> resulting audio file has the length of the longest audio file
    // normalize -> is active by default: normalizes the audio inputs
    // https://ffmpeg.org/ffmpeg-filters.html#amix, 30.01.2023
    return 'amix=inputs=$inputCount:duration=longest,dynaudnorm';
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
