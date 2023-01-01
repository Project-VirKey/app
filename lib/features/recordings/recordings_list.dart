import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virkey/features/recordings/recordings_list_item.dart';
import 'package:virkey/features/recordings/recordings_provider.dart';
import 'package:virkey/utils/platform_helper.dart';

class RecordingsList extends StatefulWidget {
  const RecordingsList({
    Key? key,
  }) : super(key: key);

  @override
  State<RecordingsList> createState() => _RecordingsListState();
}

class _RecordingsListState extends State<RecordingsList>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Consumer<RecordingsProvider>(
      builder: (BuildContext context, RecordingsProvider recordingsProvider,
              Widget? child) =>
          NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels > 0.0) {
            // if the list has been scrolled past y position 0
            recordingsProvider.expandRecordingsList();
          } else if (notification.metrics.pixels <= 0 &&
              !recordingsProvider.expandedItem) {
            // if the list has been scrolled above/equal y 0 (negative value)
            // inactive when detailed view of a recording is open (!expandedItem)
            recordingsProvider.contractRecordingsList();
          }
          return true;
        },
        child: AnimatedList(
          padding: EdgeInsets.only(
              top: PlatformHelper.isDesktop ? 30 : 0, bottom: 30),
          key: recordingsProvider.recordingsListKey,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          initialItemCount: recordingsProvider.recordings.length,
          itemBuilder: (context, index, animation) {
            return SizeTransition(
                key: UniqueKey(),
                sizeFactor: animation,
                child: RecordingsListItem(
                  recording: recordingsProvider.recordings[index],
                  vsync: this,
                  recordingsProvider: recordingsProvider,
                ));
          },
        ),
      ),
    );
  }
}
