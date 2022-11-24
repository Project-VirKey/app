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
    [],
    ['F#', 'Gb'],
    ['G#', 'Ab'],
    ['A#', 'Bb']
  ];
}

class PianoKeysWhite extends StatelessWidget {
  const PianoKeysWhite({Key? key}) : super(key: key);

  static List<PianoKeyWhite> get keys {
    List<PianoKeyWhite> pianoKeys = [];
    PianoKeys.white.asMap().forEach((index, name) {
      pianoKeys.insert(index, PianoKeyWhite(name: name));
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

class PianoKeysBlack extends StatelessWidget {
  const PianoKeysBlack({Key? key}) : super(key: key);

  static List<PianoKeyBlack> get keys {
    const double multiplierSpacer = .42;
    const double multiplierNoKey = 1.2;

    List<PianoKeyBlack> pianoKeys = [];

    pianoKeys.add(const PianoKeyBlack(
      name: '',
      widthMultiplier: multiplierSpacer * multiplierNoKey,
    ));

    PianoKeys.black.asMap().forEach((index, pianoKey) {
      pianoKeys.add(const PianoKeyBlack(
        name: '',
        widthMultiplier: multiplierSpacer,
      ));

      if (pianoKey.isEmpty) {
        pianoKeys.add(const PianoKeyBlack(
          name: '',
          secondName: '',
        ));
      } else {
        pianoKeys.add(PianoKeyBlack(
          name: pianoKey[0],
          secondName: pianoKey[1],
        ));
      }
    });

    pianoKeys.add(const PianoKeyBlack(
      name: '',
      widthMultiplier: multiplierSpacer,
    ));

    pianoKeys.add(const PianoKeyBlack(
      name: '',
      widthMultiplier: multiplierSpacer * multiplierNoKey,
    ));

    return pianoKeys;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [...keys],
    );
  }
}

class PianoKeyWhite extends StatelessWidget {
  const PianoKeyWhite({
    Key? key,
    required this.name,
  }) : super(key: key);

  final String name;

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
                padding: const EdgeInsets.only(bottom: 25),
                child: AppText(
                  text: name,
                  size: 45,
                  color: AppColors.dark,
                  family: AppFonts.secondary,
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
  const PianoKeyBlack(
      {Key? key,
      required this.name,
      this.secondName = '',
      this.widthMultiplier = 1})
      : super(key: key);

  final String name;
  final String secondName;
  final double widthMultiplier;

  @override
  Widget build(BuildContext context) {
    final player = AudioPlayer();
    player.setPlayerMode(PlayerMode.lowLatency);

    if (name.isEmpty) {
      return Container(
        width: MediaQuery.of(context).size.width * .1 * widthMultiplier,
      );
    } else {
      return SizedBox(
        width: MediaQuery.of(context).size.width * .1,
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
              AssetSource('audio/mixkit-arcade-retro-game-over-213.wav'),
            ),
            await player.resume()
          },
          child: Container(
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppText(
                  text: name,
                  size: MediaQuery.of(context).size.width * .04,
                  color: AppColors.secondary,
                  family: AppFonts.secondary,
                ),
                const SizedBox(
                  height: 10,
                ),
                AppText(
                  text: secondName,
                  size: MediaQuery.of(context).size.width * .033,
                  color: AppColors.secondary,
                  family: AppFonts.secondary,
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
