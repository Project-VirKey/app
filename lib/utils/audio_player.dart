import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:virkey/common_widgets/app_button.dart';
import 'package:virkey/common_widgets/app_text.dart';

/*
not in use
 */

class AppAudioPlayer extends StatefulWidget {
  const AppAudioPlayer({Key? key}) : super(key: key);

  @override
  State<AppAudioPlayer> createState() => _AppAudioPlayerState();
}

class _AppAudioPlayerState extends State<AppAudioPlayer> {
  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();

    // https://github.com/bluefireteam/audioplayers/blob/main/getting_started.md#player-mode
    // player.setPlayerMode(PlayerMode.lowLatency);
  }

  @override
  Widget build(BuildContext context) {
    return AppButton(
      appText: const AppText(
        text: 'Play',
      ),
      onPressed: () async => {
        await player.setAudioSource(
            AudioSource.asset('audio/mixkit-arcade-retro-game-over-213.wav')),
        player.play()
      },
    );
  }
}
