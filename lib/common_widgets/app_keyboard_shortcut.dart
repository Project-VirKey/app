import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppKeyboardShortcut extends StatefulWidget {
  const AppKeyboardShortcut({
    Key? key,
    required this.child,
    required this.shortcuts,
    required this.focusNode,
  }) : super(key: key);

  final Widget child;
  final Map<PhysicalKeyboardKey, dynamic> shortcuts;
  final FocusNode focusNode;

  @override
  State<AppKeyboardShortcut> createState() => _AppKeyboardShortcutState();
}

class _AppKeyboardShortcutState extends State<AppKeyboardShortcut> {
  bool _focusSet = false;

  @override
  Widget build(BuildContext context) {
    // only request(/set) focus on the first build
    // otherwise each time the widget is build -> the focus would be requested
    // (this would result in other widgets not being able to request focus -> )
    if (!_focusSet) {
      // set focus on this widget to be able to detect/listen to onKey-event
      // (from the whole screen)
      FocusScope.of(context).requestFocus(widget.focusNode);
      _focusSet = true;
    }

    return Focus(
      autofocus: true,
      focusNode: widget.focusNode,
      onKey: (FocusNode node, RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          widget.shortcuts.forEach((key, value) {
            if (event.physicalKey == key) {
              value();
            }
          });
        }

        return event.physicalKey == PhysicalKeyboardKey.escape
            ? KeyEventResult.handled
            : KeyEventResult.ignored;
      },
      child: widget.child,
    );
  }
}
