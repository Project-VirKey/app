import 'package:flutter/material.dart';
import 'package:virkey/common_widgets/app_play_pause_button.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/shadows.dart';

class RecordingsListPlayPauseButton extends StatelessWidget {
  const RecordingsListPlayPauseButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {},
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  boxShadow: const [AppShadows.boxShadow],
                  color: AppColors.secondary,
                  border: Border.all(color: AppColors.dark),
                  borderRadius: BorderRadius.circular(100.0),
                ),
              ),
              AppPlayPauseButton(onPressed: () {})
            ],
          ),
        ),
      ),
    );
  }
}
