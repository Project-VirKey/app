import 'package:flutter/material.dart';

class IntroductionProvider extends ChangeNotifier {
  int _currentSlideIndex = 0;

  int get currentSlideIndex => _currentSlideIndex;

  void setNewSlideIndex(int newSlideIndex) {
    _currentSlideIndex = newSlideIndex;
  }
}
