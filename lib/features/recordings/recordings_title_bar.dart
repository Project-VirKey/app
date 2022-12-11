import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virkey/common_widgets/app_text.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/fonts.dart';
import 'package:virkey/constants/radius.dart';
import 'package:virkey/constants/shadows.dart';
import 'package:virkey/features/recordings/recordings_provider.dart';

class RecordingsTitleBar extends StatelessWidget {
  const RecordingsTitleBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<RecordingsProvider>(
      builder: (BuildContext context, RecordingsProvider recordingsProvider,
              Widget? child) =>
          Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            // fit: _listExpanded ? FlexFit.tight : FlexFit.loose,
            fit: FlexFit.loose,
            child: AnimatedContainer(
              width: recordingsProvider.listExpanded
                  ? MediaQuery.of(context).size.width
                  : 1100,
              duration: RecordingsProvider.expandDuration,
              child: GestureDetector(
                onVerticalDragUpdate: (DragUpdateDetails details) => {
                  if (details.delta.dy < 0)
                    // if the title has been dragged above y position 0
                    recordingsProvider.expandRecordingsList()
                  else if (details.delta.dy > 0)
                    // if the title has been dragged below y position 0
                    recordingsProvider.contractRecordingsList()
                },
                child: AnimatedContainer(
                  margin: recordingsProvider.listExpanded
                      ? EdgeInsets.zero
                      : const EdgeInsets.symmetric(horizontal: 15),
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      boxShadow: const [AppShadows.boxShadow],
                      color: AppColors.dark,
                      borderRadius: recordingsProvider.listExpanded
                          ? BorderRadius.zero
                          : const BorderRadius.all(AppRadius.radius)),
                  duration: RecordingsProvider.expandDuration,
                  child: const AppText(
                    text: 'Recordings',
                    color: AppColors.secondary,
                    size: 26,
                    letterSpacing: 3,
                    weight: AppFonts.weightLight,
                    textAlign: TextAlign.center,
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
