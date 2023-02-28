import 'dart:convert';
import 'dart:io';

import 'package:dart_melty_soundfont/dart_melty_soundfont.dart';
import 'package:dart_midi/dart_midi.dart';
import 'package:ffmpeg_kit_flutter_min/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_min/return_code.dart';
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
  static final List _whiteKeyData = [];
  static final List _whiteKeyPlayer = [];

  static final List _blackKeyData = [];
  static final List _blackKeyPlayer = [];

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

  static const int _sampleRate = 44100;
  static const int _channels = 1;
  static const int _bitsPerSample = 16;
  static const int _seconds = 3;

  static late ByteData _bytes;
  static late Synthesizer _synth;
  static late String loadedLibraryPath;

  static void loadLibrary(String path, int volume,
      [bool isAsset = false]) async {
    loadedLibraryPath = path;
    double soundLibraryVolume = volume / 100;

    if (isAsset) {
      _bytes = await rootBundle.load(path);
    } else {
      _bytes = File(path).readAsBytesSync().buffer.asByteData();
    }

    // Create the synthesizer
    _synth = Synthesizer.loadByteData(
        _bytes,
        SynthesizerSettings(
          sampleRate: _sampleRate,
          blockSize: 64,
          maximumPolyphony: 64,
          enableReverbAndChorus: true,
        ));

    _whiteKeyData.clear();
    _blackKeyData.clear();
    _whiteKeyPlayer.clear();
    _blackKeyPlayer.clear();

    for (int o = 0; o < 3; o++) {
      _whiteKeyData.add([]);
      _whiteKeyPlayer.add([]);

      for (var wK = 0; wK < white.length; wK++) {
        _whiteKeyData[o].add(
            _loadPianoKeyPcm(white[wK][1] + midiOffset + (o * keysPerOctave)));
        _whiteKeyPlayer[o].add(AudioPlayer()..setVolume(soundLibraryVolume));
        _whiteKeyPlayer[o][wK].setAudioSource(_MyCustomSource(
            _wrapAudioDataInWavFileFormat(_whiteKeyData[o][wK])));
      }

      _blackKeyData.add([]);
      _blackKeyPlayer.add([]);

      for (var bK = 0; bK < black.length; bK++) {
        if (black[bK].isEmpty) {
          _blackKeyData[o].add(null);
          _blackKeyPlayer[o].add(null);
          continue;
        }

        _blackKeyData[o].add(
            _loadPianoKeyPcm(black[bK][1] + midiOffset + (o * keysPerOctave)));
        _blackKeyPlayer[o].add(AudioPlayer()..setVolume(soundLibraryVolume));
        _blackKeyPlayer[o][bK].setAudioSource(_MyCustomSource(
            _wrapAudioDataInWavFileFormat(_blackKeyData[o][bK])));
      }
    }
  }

  static Uint8List _loadPianoKeyPcm(int midiNote) {
    _synth.reset();
    _synth.noteOn(channel: 0, key: midiNote, velocity: 120);

    // Render the waveform (3 seconds)
    ArrayInt16 buf16 = ArrayInt16.zeros(numShorts: _sampleRate * _seconds);
    _synth.renderMonoInt16(buf16);

    return buf16.bytes.buffer.asUint8List();
  }

  static Uint8List _wrapAudioDataInWavFileFormat(Uint8List pcmData) {
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
    wavDataIntList.addAll(_stringToUint8ListToList('RIFF'));
    // Chunk Data Size: length of waveform + 36 (size of header minus 8 (size of file header))
    wavDataIntList
        .addAll(_int8ToInt32ToUint8ListWith4BytesToList(dataBytesCount + 36));
    // ChunkID: "WAVE"
    wavDataIntList.addAll(_stringToUint8ListToList('WAVE'));

    // Format Chunk - fmt
    // ChunkID: "fmt "
    wavDataIntList.addAll(_stringToUint8ListToList('fmt '));
    // Chunk Data Size: 16 Bytes
    wavDataIntList.addAll(_int8ToUint8ListWith4BytesToList(16));
    // Compression Code: 1 (= PCM - Pulse Code Modulation)
    wavDataIntList.addAll(_int8ToUint8ListWith2BytesToList(1));
    // Number of Channels: 1 (mono)
    wavDataIntList.addAll(_int8ToUint8ListWith2BytesToList(_channels));
    // Sample Rate: 44100 Hz
    wavDataIntList.addAll(_int8ToInt32ToUint8ListWith4BytesToList(_sampleRate));
    // Average Bytes per Second
    wavDataIntList.addAll(_int8ToInt32ToUint8ListWith4BytesToList(
        (_sampleRate * _bitsPerSample * _channels) ~/ 8));
    // Block Align: number of bytes per sample slice
    wavDataIntList.addAll(
        _int8ToUint8ListWith2BytesToList((_bitsPerSample * _channels) ~/ 8));
    // Significant Bits per Sample: 16 Bit
    wavDataIntList.addAll(_int8ToUint8ListWith2BytesToList(_bitsPerSample));

    // Data Chunk - data
    // ChunkID: "data"
    wavDataIntList.addAll(_stringToUint8ListToList('data'));
    // Chunk Data Size: length of waveform
    wavDataIntList
        .addAll(_int8ToInt32ToUint8ListWith4BytesToList(dataBytesCount));
    // sample data: PCM data
    wavDataIntList.addAll(pcmData.buffer.asInt8List());

    return Uint8List.fromList(wavDataIntList);
  }

  static List<int> _stringToUint8ListToList(String input) =>
      ascii.encode(input).toList();

  static List<int> _int8ToUint8ListWith2BytesToList(int input) =>
      (Uint8List(2)..buffer.asByteData().setInt8(0, input));

  static List<int> _int8ToUint8ListWith4BytesToList(int input) =>
      (Uint8List(4)..buffer.asByteData().setUint8(0, input));

  static List<int> _int8ToInt32ToUint8ListWith4BytesToList(int input) =>
      (Uint8List(4)..buffer.asByteData().setInt32(0, input, Endian.big))
          .reversed
          .toList();

  static void playPianoNote(int octaveIndex, int arIndex,
      [bool isBlackKey = false]) {
    // initiate AudioPlayer and use WAV-File-Byte-Data as source

    if (isBlackKey) {
      _blackKeyPlayer[octaveIndex][arIndex].seek(const Duration(seconds: 0));
      _blackKeyPlayer[octaveIndex][arIndex].play();
    } else {
      _whiteKeyPlayer[octaveIndex][arIndex].seek(const Duration(seconds: 0));
      _whiteKeyPlayer[octaveIndex][arIndex].play();
    }
  }

  static void changeNotePlayerVolume(int volume) {
    double soundLibraryVolume = volume / 100;

    for (List octave in _whiteKeyPlayer) {
      for (AudioPlayer keyPlayer in octave) {
        keyPlayer.setVolume(soundLibraryVolume);
      }
    }

    for (List octave in _blackKeyPlayer) {
      for (AudioPlayer? keyPlayer in octave) {
        keyPlayer?.setVolume(soundLibraryVolume);
      }
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

  static int getPianoKeyWhiteIndex(int midiNote, [int octaveIndex = -1]) {
    if (octaveIndex == -1) {
      octaveIndex = getOctaveIndexFromMidiNote(midiNote);
    }

    return white.indexWhere((pianoKeyWhite) =>
        pianoKeyWhite[1] + midiOffset + (octaveIndex * keysPerOctave) ==
        midiNote);
  }

  static int getPianoKeyBlackIndex(int midiNote, [int octaveIndex = -1]) {
    if (octaveIndex == -1) {
      octaveIndex = getOctaveIndexFromMidiNote(midiNote);
    }

    return black.indexWhere((pianoKeyBlack) {
      if (pianoKeyBlack.isEmpty) {
        return false;
      }
      return (pianoKeyBlack[1] + midiOffset + (octaveIndex * keysPerOctave)) ==
          midiNote;
    });
  }

  static final MidiParser _midiParser = MidiParser();

  static Future<void> midiToWav(String midiFilePath, String destinationPath,
      [String? playbackPath,
      int? soundLibraryVolume,
      int? audioPlaybackVolume]) async {
    MidiFile midiFile = _midiParser.parseMidiFromFile(File(midiFilePath));

    String tempDirPath = (await getTemporaryDirectory()).path;

    List<String> tempFilePaths = [];
    List<double> weights = [];

    if (midiFile.tracks.length < 2 || midiFile.header.ticksPerBeat == null) {
      return;
    }

    int previousDeltaTime = 0;
    int index = 0;

    for (List<MidiEvent> track in midiFile.tracks) {
      for (int i = 0; i < track.length; i++) {
        MidiEvent midiEvent = track[i];

        if (midiEvent is! NoteOnEvent) {
          continue;
        }

        int octaveIndex =
            Piano.getOctaveIndexFromMidiNote(midiEvent.noteNumber);

        int playedPianoKeyWhite =
            getPianoKeyWhiteIndex(midiEvent.noteNumber, octaveIndex);

        int playedPianoKeyBlack =
            getPianoKeyBlackIndex(midiEvent.noteNumber, octaveIndex);

        if (playedPianoKeyWhite >= 0 || playedPianoKeyBlack >= 0) {
          previousDeltaTime += midiEvent.deltaTime;
          index++;
        }

        int neededEmptyBytes =
            (_sampleRate * (previousDeltaTime / 1000)).round();
        if (neededEmptyBytes.isOdd) {
          neededEmptyBytes--;
        }

        if (playedPianoKeyWhite >= 0 || playedPianoKeyBlack >= 0) {
          // deltaTime + duration => time position of the NoteOffEvent
          previousDeltaTime += midiEvent.duration;
        }

        List<int> emptyBytes = List.filled(neededEmptyBytes, 0);

        if (playedPianoKeyWhite >= 0) {
          File wavFile = File(
              '$tempDirPath${Platform.pathSeparator}temp_white_$index.wav');
          wavFile.writeAsBytesSync(_wrapAudioDataInWavFileFormat(
              Uint8List.fromList([
            ...emptyBytes,
            ..._whiteKeyData[octaveIndex][playedPianoKeyWhite]
          ])));
          tempFilePaths.add(wavFile.path);
        }

        if (playedPianoKeyBlack >= 0) {
          File wavFile = File(
              '$tempDirPath${Platform.pathSeparator}temp_black_$index.wav');
          wavFile.writeAsBytesSync(_wrapAudioDataInWavFileFormat(
              Uint8List.fromList([
            ...emptyBytes,
            ..._blackKeyData[octaveIndex][playedPianoKeyBlack]
          ])));
          tempFilePaths.add(wavFile.path);
        }
      }
    }

    if (playbackPath != null &&
        soundLibraryVolume != null &&
        audioPlaybackVolume != null) {
      tempFilePaths.add(playbackPath);

      List<double> wavWeights = _getKeyboardAndPlaybackWeight(
          soundLibraryVolume, audioPlaybackVolume);

      weights = [
        // number of tempFilePaths (stored notes) subtracted by 1 (-1), because playback path is added
        ...List.filled(tempFilePaths.length - 1, wavWeights[0]),
        wavWeights[1]
      ];
    } else {
      weights = List.filled(tempFilePaths.length, 1);
    }

    await _combineAudioFiles(destinationPath, tempFilePaths, weights);
  }

  static List<double> _getKeyboardAndPlaybackWeight(
      int soundLibraryVolume, int playbackVolume) {
    int volumeDifference = soundLibraryVolume - playbackVolume;
    if (volumeDifference.isNegative) {
      return [soundLibraryVolume / playbackVolume, 1];
    } else {
      return [1, playbackVolume / soundLibraryVolume];
    }
  }

  static Future<void> _combineAudioFiles(String outputFilepath,
      List<String> inputFilePaths, List<double> weights) async {
    File outputFile = File(outputFilepath);
    if (await outputFile.exists()) {
      await outputFile.delete();
    }

    FFmpegKit.executeAsync(
            '-i "${inputFilePaths.join('" -i "')}" -filter_complex amix=inputs=${inputFilePaths.length}:duration=longest:normalize=0:weights="${weights.join(' ')}" "$outputFilepath"')
        .then((dynamic session) async {
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        // SUCCESS
        print('FFMPEG yay');
      } else if (ReturnCode.isCancel(returnCode)) {
        // CANCEL
        print('FFMPEG cancel');
      } else {
        // ERROR
        // on android simulator error is produces (returnCode is null), but export still works (19.02.2023)
        print('FFMPEG error - $returnCode');
      }
    });
  }
}

// Feed your own stream of bytes into the player
class _MyCustomSource extends StreamAudioSource {
  final List<int> _bytes;

  _MyCustomSource(this._bytes);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= _bytes.length;
    return StreamAudioResponse(
      sourceLength: _bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(_bytes.sublist(start, end)),
      contentType: 'audio/mpeg',
    );
  }
}
