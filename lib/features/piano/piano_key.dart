import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:virkey/common_widgets/app_text.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/fonts.dart';
import 'package:virkey/constants/radius.dart';

class PianoKeys {
  // C D E F G A B

  // C# D# F# G# A#
  // Db Eb Gb Ab Bb

  static const List<String> white = ['C', 'D', 'E', 'F', 'G', 'A', 'B'];

  static const String wC = 'C';
  static const String wD = 'D';
  static const String wE = 'E';
  static const String wF = 'F';
  static const String wG = 'G';
  static const String wA = 'A';
  static const String wB = 'B';

  static const Set<String> bC = {'C#', 'Db'};
  static const Set<String> bD = {'D#', 'Eb'};
  static const Set<String> bF = {'F#', 'Gb'};
  static const Set<String> bG = {'G#', 'Ab'};
  static const Set<String> bA = {'A#', 'Bb'};
}

class PianoKey extends StatelessWidget {
  const PianoKey({Key? key, this.black = false, required this.name}) : super(key: key);

  final bool black;
  final String name;

  @override
  Widget build(BuildContext context) {
    final player = AudioPlayer();
    player.setPlayerMode(PlayerMode.lowLatency);

    return Container(
      margin: const EdgeInsets.fromLTRB(5, 0, 5, 5),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: black ? AppColors.white : AppColors.dark,
          backgroundColor: black ? AppColors.dark : AppColors.white,
          padding: const EdgeInsets.symmetric(
              //vertical: 200,
              //horizontal: 50,
              ),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
            bottomLeft: AppRadius.radius,
            bottomRight: AppRadius.radius,
          )),
        ),
        onPressed: () async => {
          await player.setSource(
              AssetSource('audio/mixkit-arcade-retro-game-over-213.wav')),
          await player.resume()
        },
        child: Container(
          alignment: Alignment.bottomCenter,
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 25),
          child: AppText(
            text: name,
            size: 45,
            color: black ? AppColors.secondary : AppColors.dark,
            family: AppFonts.secondary,
          ),
        ),
      ),
    );
  }
}
