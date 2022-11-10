import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppKeyboardShortcut extends StatelessWidget {
  // https://api.flutter.dev/flutter/services/PhysicalKeyboardKey-class.html

  const AppKeyboardShortcut({
    Key? key,
    required this.child,
    required this.shortcuts,
  }) : super(key: key);

  final Widget child;
  final Map<PhysicalKeyboardKey, dynamic> shortcuts;

  @override
  Widget build(BuildContext context) {
    final FocusNode focusNode = FocusNode();
    FocusScope.of(context).requestFocus(focusNode);

    return Focus(
      autofocus: true,
      focusNode: focusNode,
      onKey: (FocusNode node, RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          shortcuts.forEach((key, value) {
            if (event.physicalKey == key) {
              value();
            }
          });
        }

        return event.physicalKey == PhysicalKeyboardKey.escape
            ? KeyEventResult.handled
            : KeyEventResult.ignored;
      },
      child: child,
    );
  }
}
