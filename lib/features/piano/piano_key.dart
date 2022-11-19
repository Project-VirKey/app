import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:virkey/common_widgets/app_text.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/fonts.dart';
import 'package:virkey/constants/radius.dart';

class PianoKeys extends StatelessWidget {
  const PianoKeys({Key? key}) : super(key: key);

  // C D E F G A B

  // C# D# F# G# A#
  // Db Eb Gb Ab Bb

  static const List<String> white = ['C', 'D', 'E', 'F', 'G', 'A', 'B'];

  static const List<List<String>> black = [
    [],
    ['C#', 'Db'],
    ['D#', 'Eb'],
    [],
    ['F#', 'Gb'],
    ['G#', 'Ab'],
    ['A#', 'Bb']
  ];

  static List<Widget> get keys {
    List<PianoKey> pianoKeys = [];
    white.asMap().forEach((index, name) {
      pianoKeys.insert(
          index,
          PianoKey(
            name: name,
            blackKey: PianoKeys.black.elementAt(index),
          ));
    });

    return pianoKeys;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [...keys],
    );
  }
}

class PianoKey extends StatelessWidget {
  const PianoKey(
      {Key? key,
      this.blackKey = const [],
      required this.name,
      this.secondName = ''})
      : super(key: key);

  final List<String> blackKey;
  final String name;
  final String secondName;

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
            margin: const EdgeInsets.fromLTRB(5, 0, 5, 5),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: AppColors.dark,
                backgroundColor: AppColors.white,
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
                  AssetSource('audio/mixkit-arcade-retro-game-over-213.wav'),
                ),
                await player.resume()
              },
              child: Container(
                alignment: Alignment.bottomCenter,
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 25),
                child: AppText(
                  text: name,
                  size: 45,
                  color: AppColors.dark,
                  family: AppFonts.secondary,
                ),
              ),
            ),
          ),
          if (blackKey.isNotEmpty)
            Positioned(
              top: 0,
              right: MediaQuery.of(context).size.width * .095,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * .095,
                height: MediaQuery.of(context).size.height * .55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppColors.white,
                    backgroundColor: AppColors.dark,
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
                      AssetSource(
                          'audio/mixkit-arcade-retro-game-over-213.wav'),
                    ),
                    await player.resume()
                  },
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AppText(
                          text: blackKey[0],
                          size: 35,
                          color: AppColors.secondary,
                          family: AppFonts.secondary,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        AppText(
                          text: blackKey[1],
                          size: 28,
                          color: AppColors.secondary,
                          family: AppFonts.secondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}
