import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';
import 'package:virkey/common_widgets/app_icon.dart';
import 'package:virkey/common_widgets/app_play_pause_button.dart';
import 'package:virkey/common_widgets/app_properties_description_title.dart';
import 'package:virkey/common_widgets/app_shadow.dart';
import 'package:virkey/common_widgets/app_slider.dart';
import 'package:virkey/common_widgets/app_switch.dart';
import 'package:virkey/common_widgets/app_text.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/fonts.dart';
import 'package:virkey/constants/radius.dart';
import 'package:virkey/features/settings/settings_overlay.dart';
import 'package:virkey/common_widgets/app_property_description_action_combination.dart';
import 'package:virkey/utils/confirm_overlay.dart';
import 'package:virkey/utils/textfield_overlay.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // https://medium.flutterdevs.com/implemented-overlay-in-flutter-fe60d2b33a04
  late final SettingsOverlay _settingsOverlay =
      SettingsOverlay(context: context, vsync: this);

  static const _itemsRep = [
    'Rec1',
    'Rec2',
    'Rec3',
    'Rec4',
    'Rec5',
    'Rec6',
    'Rec7',
    'Rec8',
    'Rec9',
    'Rec10',
    'Rec11',
    'Rec12',
    'Rec13',
    'Rec14',
    'Rec15',
    'Rec16',
    'Rec17',
    'Rec18',
    'Rec19',
    'Rec20',
    'Rec21',
    'Rec22',
  ];

  final recordingsList = List.of(_itemsRep);
  final recordingsListKey = GlobalKey<AnimatedListState>();
  bool expandedItem = false;

  void _addRecordingItem(String value) {
    recordingsList.insert(0, value);
    recordingsListKey.currentState!
        .insertItem(0, duration: const Duration(milliseconds: 150));
  }

  void _removeRecordingItem(int index) {
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
    recordingsList.removeAt(index);
  }

  void _removeAllRecordingItems() {
    for (var i = 0; i <= recordingsList.length - 1; i++) {
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
    recordingsList.clear();
  }

  void _expandRecordingItem(int index) {
    String item = recordingsList[index];
    _removeAllRecordingItems();
    _addRecordingItem(item);
    expandedItem = true;
  }

  void _contractRecordingItem() {
    _removeAllRecordingItems();
    for (var element in _itemsRep.reversed) {
      _addRecordingItem(element);
    }
    expandedItem = false;
  }

  void _expandRecordingsList() {
    // if the list is not fully expanded
    if (!_listExpanded) {
      setState(() {
        _recordingsAnimationController.reverse();
        _listExpanded = true;
        _appTitleSize = 40;
      });
    }
  }

  void _contractRecordingsList() {
    // if the list is fully expanded
    if (_listExpanded) {
      setState(() {
        _recordingsAnimationController.forward();
        _listExpanded = false;
        _appTitleSize = 45;
      });
    }
  }

  bool _listExpanded = false;
  double _appTitleSize = 45;
  late final Duration _expandDuration = const Duration(milliseconds: 250);

  late final AnimationController _recordingsAnimationController =
      AnimationController(vsync: this, duration: _expandDuration)..forward();
  late final BorderRadiusTween _borderRadiusTween = BorderRadiusTween(
      begin: const BorderRadius.all(AppRadius.radius), end: BorderRadius.zero);
  late final EdgeInsetsTween _edgeInsetsTween = EdgeInsetsTween(
      begin: const EdgeInsets.symmetric(horizontal: 15), end: EdgeInsets.zero);

  late final AppConfirmOverlay _deletePlaybackConfirmOverlay =
      AppConfirmOverlay(
    context: context,
    vsync: this,
    displayText: 'Delete playback "File1.mp3"?',
    confirmButtonText: 'Delete',
    onConfirm: () => {print('Deleted playback "File1.mp3"')},
  );

  late final AppConfirmOverlay _deleteRecordingConfirmOverlay =
      AppConfirmOverlay(
    context: context,
    vsync: this,
    displayText: 'Delete recording "Recording #3"?',
    confirmButtonText: 'Delete',
    onConfirm: () => {print('Deleted recording #3')},
  );

  late final AppTextFieldOverlay _editRecordingTitleOverlay =
      AppTextFieldOverlay(
    context: context,
    value: 'Recording #x',
    vsync: this,
    onConfirm: () => {print('Deleted recording #3')},
  );

  bool _recordingTitleTextFieldVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ignore resizing due to system-ui elements (e.g. on-screen keyboard)
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.secondary,
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppIcon(
                  icon: HeroIcons.cog6Tooth,
                  color: AppColors.dark,
                  onPressed: () => _settingsOverlay.open(),
                  size: 30,
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: AppShadow(
                      child: AnimatedDefaultTextStyle(
                        style: TextStyle(fontSize: _appTitleSize),
                        duration: const Duration(milliseconds: 250),
                        child: const Text(
                          'ViRKEY',
                          style: TextStyle(
                              fontFamily: AppFonts.secondary,
                              letterSpacing: 4,
                              color: AppColors.dark),
                        ),
                      ),
                    ),
                  ),
                ),
                AppIcon(
                  icon: HeroIcons.arrowPathRoundedSquare,
                  color: AppColors.dark,
                  onPressed: () => {},
                  size: 30,
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          AnimatedCrossFade(
            // https://www.geeksforgeeks.org/flutter-animatedcrossfade-widget
            crossFadeState: _listExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 250),
            firstChild: const SizedBox(
              width: 150,
              height: 0,
            ),
            secondChild: Column(
              children: [
                const SizedBox(
                  height: 40,
                ),
                AppShadow(
                  child: SizedBox(
                    width: 150,
                    height: 150,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.dark,
                        foregroundColor: AppColors.tertiary,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(AppRadius.radius)),
                      ),
                      onPressed: () => context.go('/piano'),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SvgPicture.asset(
                            'assets/images/VIK_Logo_v2.svg',
                            height: 73,
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 7.5),
                            child: AppText(
                              text: 'Play',
                              family: AppFonts.secondary,
                              color: AppColors.secondary,
                              letterSpacing: 6,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                const AppText(
                  text: 'Find Device ...',
                  size: 20,
                  weight: AppFonts.weightLight,
                  letterSpacing: 3,
                ),
                const SizedBox(
                  height: 60,
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: AppShadow(
                  child: GestureDetector(
                    onVerticalDragUpdate: (DragUpdateDetails details) => {
                      if (details.delta.dy < 0)
                        // if the title has been dragged above y position 0
                        _expandRecordingsList()
                      else if (details.delta.dy > 0)
                        // if the title has been dragged below y position 0
                        _contractRecordingsList()
                    },
                    child: Container(
                      margin: _listExpanded
                          ? EdgeInsets.zero
                          : _edgeInsetsTween
                              .evaluate(_recordingsAnimationController),
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: AppColors.dark,
                          borderRadius: _listExpanded
                              ? BorderRadius.zero
                              : _borderRadiusTween.evaluate(CurvedAnimation(
                                  parent: _recordingsAnimationController,
                                  curve: Curves.ease))),
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
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.metrics.pixels > 0.0) {
                  // if the list has been scrolled past y position 0
                  _expandRecordingsList();
                } else if (notification.metrics.pixels <= 0 && !expandedItem) {
                  // if the list has been scrolled above/equal y 0 (negative value)
                  // inactive when detailed view of a recording is open (!expandedItem)
                  _contractRecordingsList();
                }
                return true;
              },
              child: AnimatedList(
                key: recordingsListKey,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                initialItemCount: recordingsList.length,
                itemBuilder: (context, index, animation) {
                  return SizeTransition(
                    key: UniqueKey(),
                    sizeFactor: animation,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 30),
                                child: TextButton(
                                  onPressed: () => {
                                    if (expandedItem)
                                      {_contractRecordingItem()}
                                    else
                                      {_expandRecordingItem(index)}
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: AppColors.dark,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 14),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      AppShadow(
                                        child: AppText(
                                          text: recordingsList[index],
                                          size: 18,
                                          letterSpacing: 3,
                                        ),
                                      ),
                                      AppIcon(
                                        icon: expandedItem
                                            ? HeroIcons.chevronUp
                                            : HeroIcons.chevronDown,
                                        color: AppColors.dark,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                height: 5,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 30),
                                decoration: const BoxDecoration(
                                    color: AppColors.tertiary,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(50))),
                              ),
                              if (expandedItem)
                                Container(
                                  margin: const EdgeInsets.only(
                                    left: 50,
                                    right: 50,
                                    top: 15,
                                    bottom: 35,
                                  ),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 5,
                                        ),
                                        child: Stack(
                                          alignment: Alignment.bottomCenter,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: const [
                                                AppText(
                                                  text: '0:12',
                                                  size: 18,
                                                  letterSpacing: 3,
                                                ),
                                                AppText(
                                                  text: '4:23',
                                                  size: 18,
                                                  letterSpacing: 3,
                                                ),
                                              ],
                                            ),
                                            Positioned(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 7),
                                                child: AppPlayPauseButton(
                                                  onChanged: (val) => {},
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      AppSlider(
                                        value: 20,
                                        onChanged: (val) => {print(val)},
                                      ),
                                      PropertyDescriptionActionCombination(
                                        title: '',
                                        child: Expanded(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Expanded(
                                                child: TextFormField(
                                                  onFieldSubmitted: (value) => {
                                                    recordingsList[index] = value,
                                                    setState(() {
                                                      _recordingTitleTextFieldVisible =
                                                          false;
                                                    }),
                                                  },
                                                  focusNode: FocusNode(),
                                                  autofocus: true,
                                                  initialValue:
                                                      recordingsList[index],
                                                  enabled:
                                                      _recordingTitleTextFieldVisible,
                                                  maxLines: 1,
                                                  minLines: 1,
                                                  style: const TextStyle(
                                                      letterSpacing: 3,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          AppFonts.weightLight),
                                                  decoration:
                                                      const InputDecoration(
                                                    isDense: true,
                                                    border: InputBorder.none,
                                                  ),
                                                ),
                                              ),
                                              if (_recordingTitleTextFieldVisible)
                                                AppIcon(
                                                  icon: HeroIcons.check,
                                                  color: AppColors.dark,
                                                  onPressed: () =>
                                                  {
                                                    // TODO: set title value from text field
                                                    setState(() {
                                                      _recordingTitleTextFieldVisible =
                                                          false;
                                                    })
                                                  },
                                                ),
                                              if (!_recordingTitleTextFieldVisible)
                                                AppIcon(
                                                  icon: HeroIcons.pencilSquare,
                                                  color: AppColors.dark,
                                                  onPressed: () => {
                                                    setState(() {
                                                      _recordingTitleTextFieldVisible =
                                                          true;
                                                    }),
                                                    print(_listExpanded),
                                                    _expandRecordingsList()
                                                  },
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const PropertiesDescriptionTitle(
                                          title: 'Audio-Playback'),
                                      const PropertyDescriptionActionCombination(
                                        title: 'Audio',
                                        child: AppIcon(
                                          icon: HeroIcons.arrowDownTray,
                                          color: AppColors.dark,
                                        ),
                                      ),
                                      PropertyDescriptionActionCombination(
                                        title: 'File1.mp3',
                                        child: Row(
                                          children: [
                                            AppSwitch(
                                              value: false,
                                              onChanged: (bool val) =>
                                                  {print(val)},
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            AppIcon(
                                              icon: HeroIcons.trash,
                                              color: AppColors.dark,
                                              onPressed: () =>
                                                  _deletePlaybackConfirmOverlay
                                                      .open(),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const PropertiesDescriptionTitle(
                                          title: 'Export'),
                                      const PropertyDescriptionActionCombination(
                                        title: 'Audio',
                                        child: AppIcon(
                                          icon: HeroIcons.arrowUpTray,
                                          color: AppColors.dark,
                                        ),
                                      ),
                                      const PropertyDescriptionActionCombination(
                                        title: 'MIDI',
                                        child: AppIcon(
                                          icon: HeroIcons.arrowUpTray,
                                          color: AppColors.dark,
                                        ),
                                      ),
                                      const PropertyDescriptionActionCombination(
                                        title: 'Audio & MIDI',
                                        child: AppIcon(
                                          icon: HeroIcons.arrowUpTray,
                                          color: AppColors.dark,
                                        ),
                                      ),
                                      const PropertiesDescriptionTitle(
                                        title: 'Delete',
                                      ),
                                      PropertyDescriptionActionCombination(
                                        title: 'Delete Recording',
                                        child: AppIcon(
                                          icon: HeroIcons.trash,
                                          color: AppColors.dark,
                                          onPressed: () =>
                                              _deleteRecordingConfirmOverlay
                                                  .open(),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
