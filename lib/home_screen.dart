import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';
import 'package:virkey/common_widgets/app_icon.dart';
import 'package:virkey/common_widgets/app_play_pause_button.dart';
import 'package:virkey/common_widgets/app_properties_description_title.dart';
import 'package:virkey/common_widgets/app_slider.dart';
import 'package:virkey/common_widgets/app_switch.dart';
import 'package:virkey/common_widgets/app_text.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/fonts.dart';
import 'package:virkey/constants/radius.dart';
import 'package:virkey/constants/shadows.dart';
import 'package:virkey/features/settings/settings_overlay.dart';
import 'package:virkey/common_widgets/app_property_description_action_combination.dart';
import 'package:virkey/utils/confirm_overlay.dart';
import 'package:virkey/utils/platform_helper.dart';

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
    if (!_listExpanded) {
      setState(() {
        _listExpanded = true;
        _appTitleSize = 40;
      });
    }
  }

  void _contractRecordingsList() {
    if (_listExpanded) {
      setState(() {
        _listExpanded = false;
        _appTitleSize = 45;
      });
    }
  }

  bool _listExpanded = false;
  double _appTitleSize = 45;
  final Duration _expandDuration = const Duration(milliseconds: 200);

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

  bool _recordingTitleTextFieldVisible = false;

  @override
  void initState() {
    _settingsOverlay.loadData();
    setState(() {});
    super.initState();
  }

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
                    child: Row(
                      children: [
                        if (PlatformHelper.isDesktop)
                          AnimatedCrossFade(
                            crossFadeState: _listExpanded
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                            duration: _expandDuration,
                            firstChild: const SizedBox(
                              width: 0,
                              height: 65,
                            ),
                            secondChild: Container(
                              height: 65,
                              margin: const EdgeInsets.only(right: 35),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.dark,
                                  foregroundColor: AppColors.tertiary,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(AppRadius.radius)),
                                ),
                                onPressed: () => context.go('/piano'),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    SvgPicture.asset(
                                      'assets/images/VIK_Logo_v2.svg',
                                      height: 45,
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(left: 7.5),
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
                        AnimatedDefaultTextStyle(
                          style: TextStyle(fontSize: _appTitleSize),
                          duration: _expandDuration,
                          child: const Text(
                            'ViRKEY',
                            style: TextStyle(
                              fontFamily: AppFonts.secondary,
                              letterSpacing: 4,
                              color: AppColors.dark,
                              shadows: [AppShadows.title],
                            ),
                          ),
                        ),
                      ],
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
            duration: _expandDuration,
            firstChild: const SizedBox(
              width: 150,
              height: 0,
            ),
            secondChild: Column(
              children: [
                const SizedBox(
                  height: 40,
                ),
                SizedBox(
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                // fit: _listExpanded ? FlexFit.tight : FlexFit.loose,
                fit: FlexFit.loose,
                child: AnimatedContainer(
                  width:
                      _listExpanded ? MediaQuery.of(context).size.width : 1100,
                  duration: _expandDuration,
                  child: GestureDetector(
                    onVerticalDragUpdate: (DragUpdateDetails details) => {
                      if (details.delta.dy < 0)
                        // if the title has been dragged above y position 0
                        _expandRecordingsList()
                      else if (details.delta.dy > 0)
                        // if the title has been dragged below y position 0
                        _contractRecordingsList()
                    },
                    child: AnimatedContainer(
                      margin: _listExpanded
                          ? EdgeInsets.zero
                          : const EdgeInsets.symmetric(horizontal: 15),
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          boxShadow: const [AppShadows.boxShadow],
                          color: AppColors.dark,
                          borderRadius: _listExpanded
                              ? BorderRadius.zero
                              : const BorderRadius.all(AppRadius.radius)),
                      duration: _expandDuration,
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
                padding: EdgeInsets.only(
                    top: PlatformHelper.isDesktop ? 30 : 0, bottom: 30),
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
                        Flexible(
                          fit: FlexFit.loose,
                          child: SizedBox(
                            width: 1060,
                            child: Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 30,
                                  ),
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
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: PlatformHelper.isDesktop
                                              ? 18
                                              : 14),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        AppText(
                                          text: recordingsList[index],
                                          size: 18,
                                          letterSpacing: 3,
                                          shadows: const [AppShadows.text],
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
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 30),
                                  decoration: const BoxDecoration(
                                      color: AppColors.tertiary,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(50))),
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
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 7),
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
                                                    onFieldSubmitted: (value) =>
                                                        {
                                                      recordingsList[index] =
                                                          value,
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
                                                        fontWeight: AppFonts
                                                            .weightLight),
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
                                                    onPressed: () => {
                                                      // TODO: set title value from text field
                                                      setState(() {
                                                        _recordingTitleTextFieldVisible =
                                                            false;
                                                      })
                                                    },
                                                  ),
                                                if (!_recordingTitleTextFieldVisible)
                                                  AppIcon(
                                                    icon:
                                                        HeroIcons.pencilSquare,
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
