import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:virkey/common_widgets/app_button.dart';
import 'package:virkey/common_widgets/app_text.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/features/piano/import_overlay.dart';

class PianoScreen extends StatefulWidget {
  const PianoScreen({Key? key}) : super(key: key);

  @override
  State<PianoScreen> createState() => _PianoScreenState();
}

class _PianoScreenState extends State<PianoScreen> {
  _showImportOverlay(BuildContext context) {
    OverlayState? pianoOverlayState = Overlay.of(context);

    pianoOverlayState?.insertAll([importOverlay]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: Center(
        child: Column(
          children: [
            const AppText(text: 'Piano Screen', size: 45),
            AppButton(
                appText: const AppText(text: 'Home'),
                onPressed: () => context.go('/')),
            AppButton(
                appText: const AppText(
                  text: 'Import Overlay',
                ),
                onPressed: () => _showImportOverlay(context))
          ],
        ),
      ),
    );
  }
}
