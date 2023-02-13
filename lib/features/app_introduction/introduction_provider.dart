import 'package:flutter/material.dart';

class IntroductionProvider extends ChangeNotifier {
  int currentSlideIndex = 0;

  void notify() {
    notifyListeners();
  }
}
