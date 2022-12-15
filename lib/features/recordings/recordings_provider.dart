import 'dart:io';

import 'package:flutter/material.dart';
import 'package:virkey/constants/colors.dart';

class RecordingsProvider extends ChangeNotifier {
  final List<Recording> _recordings = [];

  static const Duration expandDuration = Duration(milliseconds: 200);
  final recordingsListKey = GlobalKey<AnimatedListState>();
  bool listExpanded = false;
  bool expandedItem = false;
  bool recordingTitleTextFieldVisible = false;

  static const _itemsRep = [
    'Recording #1',
    'Recording #2',
    'Recording #3',
    'Recording #4',
    'Recording #5',
    'Recording #6',
    'Recording #7',
    'Recording #8',
    'Recording #9',
    'Recording #10',
    'Recording #11',
    'Recording #12',
    'Recording #13',
    'Recording #14',
    'Recording #15',
    'Recording #16',
    'Recording #17',
    'Recording #18',
    'Recording #19',
    'Recording #20',
    'Recording #21',
    'Recording #22',
  ];

  List<Recording> get recordings => _recordings;

  RecordingsProvider() {
    for (var title in _itemsRep) {
      _recordings.add(Recording(title: title));
    }
  }

  void addRecordingItem(Recording recording) {
    recordings.insert(0, recording);
    recordingsListKey.currentState!
        .insertItem(0, duration: const Duration(milliseconds: 150));
    notifyListeners();
  }

  void removeRecordingItem(int index) {
    recordingsListKey.currentState!.removeItem(0, (context, animation) {
      return SizeTransition(
        sizeFactor: animation,
        child: Card(
            color: AppColors.secondary,
            child: Container(
              height: 20,
            )),
      );
    }, duration: const Duration(milliseconds: 150));
    recordings.removeAt(index);
    notifyListeners();
  }

  void removeAllRecordingItems() {
    for (var i = 0; i <= recordings.length - 1; i++) {
      recordingsListKey.currentState?.removeItem(0,
          (BuildContext context, Animation<double> animation) {
        return SizeTransition(
          sizeFactor: animation,
          child: Card(
              color: AppColors.secondary,
              child: Container(
                height: 20,
              )),
        );
      }, duration: const Duration(milliseconds: 150));
    }
    recordings.clear();
    notifyListeners();
  }

  void expandRecordingItem(int index) {
    Recording item = recordings[index];
    removeAllRecordingItems();
    addRecordingItem(item);
    expandedItem = true;
    notifyListeners();
  }

  void contractRecordingItem() {
    removeAllRecordingItems();
    for (var element in _itemsRep.reversed) {
      addRecordingItem(Recording(title: element));
    }
    expandedItem = false;
    notifyListeners();
  }

  void expandRecordingsList() {
    if (!listExpanded) {
      listExpanded = true;
    }
    notifyListeners();
  }

  void contractRecordingsList() {
    if (listExpanded) {
      listExpanded = false;
    }
    notifyListeners();
  }
}

class Recording {
  Recording({required this.title});

  String title;
  File? playback;
  String? playbackTitle;
}
