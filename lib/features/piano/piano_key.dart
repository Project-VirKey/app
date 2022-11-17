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

  static const List<List<String>> black = [
    ['C#', 'Db'],
    ['D#', 'Eb'],
    ['h', 'a'],
    ['F#', 'Gb'],
    ['G#', 'Ab'],
    ['A#', 'Bb']
  ];
}

class PianoKey extends StatelessWidget {
  const PianoKey(
      {Key? key, this.black = false, required this.name, this.secondName = ''})
      : super(key: key);

  final bool black;
  final String name;
  final String secondName;

  @override
  Widget build(BuildContext context) {
    final player = AudioPlayer();
    player.setPlayerMode(PlayerMode.lowLatency);

    return Container(
      margin: black
          ? const EdgeInsets.fromLTRB(15, 0, 15, 5)
          : const EdgeInsets.fromLTRB(5, 0, 5, 5),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: black ? AppColors.white : AppColors.dark,
          backgroundColor: black ? AppColors.dark : AppColors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: AppRadius.radius,
              bottomRight: AppRadius.radius,
            ),
          ),
        ),
        onPressed: () async => {
          await player.stop(),
          await player.setSource(
              AssetSource('audio/mixkit-arcade-retro-game-over-213.wav')),
          await player.resume()
        },
        child: Container(
          height: black ? MediaQuery.of(context).size.height * .6 : null,
          alignment: Alignment.bottomCenter,
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 25),
          child: AppText(
            text: name,
            size: black ? 35 : 45,
            color: black ? AppColors.secondary : AppColors.dark,
            family: AppFonts.secondary,
          ),
        ),
      ),
    );
  }
}
