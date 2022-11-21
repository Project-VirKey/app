import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';
import 'package:virkey/common_widgets/app_button.dart';
import 'package:virkey/common_widgets/app_icon.dart';
import 'package:virkey/common_widgets/app_shadow.dart';
import 'package:virkey/common_widgets/app_text.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/fonts.dart';
import 'package:virkey/constants/radius.dart';
import 'package:virkey/features/settings/settings_overlay.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool _listExpanded = false;

  double _virkeyTitleSize = 45;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // https://medium.flutterdevs.com/implemented-overlay-in-flutter-fe60d2b33a04
    SettingsOverlay settingsOverlay =
        SettingsOverlay(context: context, vsync: this);

    const itemsRep = [
      'Rec1',
      'Rec2',
      'Rec3',
      'Rec4',
      'Rec5',
      'Rec6',
      'Rec7',
      'Rec8',
      'Rec9'
    ];
    final items = List.of(itemsRep);
    final recordingsListKey = GlobalKey<AnimatedListState>();
    bool expandedItem = false;

    void addItem(String value) {
      items.insert(0, value);
      recordingsListKey.currentState!
          .insertItem(0, duration: const Duration(milliseconds: 150));
    }

    void removeItem(int index) {
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
      items.removeAt(index);
    }

    void removeAllItems() {
      for (var i = 0; i <= items.length - 1; i++) {
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
      items.clear();
    }

    void expandItem(int index) {
      String item = items[index];
      removeAllItems();
      addItem(item);
      expandedItem = true;
    }

    void contractItem() {
      removeAllItems();
      for (var element in itemsRep.reversed) {
        addItem(element);
      }
      expandedItem = false;
    }

    return Scaffold(
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
                  onPressed: () => settingsOverlay.open(),
                  size: 30,
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: AppShadow(
                      child: AnimatedDefaultTextStyle(
                        style: TextStyle(fontSize: _virkeyTitleSize),
                        duration: const Duration(milliseconds: 250),
                        child: const Text(
                          'ViRKEY',
                          style: TextStyle(
                              fontFamily: AppFonts.secondary, letterSpacing: 4, color: AppColors.dark),
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
          // const DefaultComponents(),
          // --> for later: Expanded List View
          // Row(
          //   children: [
          //     Expanded(
          //       child: Container(
          //         padding: const EdgeInsets.all(5),
          //         color: AppColors.dark,
          //         child: const AppText(
          //           text: 'Recordings',
          //           color: AppColors.secondary,
          //           size: 26,
          //           weight: AppFonts.weightLight,
          //           textAlign: TextAlign.center,
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
          Row(
            children: [
              Expanded(
                child: AppShadow(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                        color: AppColors.dark,
                        borderRadius: BorderRadius.all(AppRadius.radius)),
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
            ],
          ),
          AppButton(
              appText: const AppText(
                text: 'L',
              ),
              onPressed: () => {
                    setState(() {
                      _listExpanded = !_listExpanded;
                      _virkeyTitleSize -= 5 * (_listExpanded ? 1: -1);
                    }),
                    print(_listExpanded)
                  }),
          Expanded(
            // Expanded -> contain ListView (https://daill.de/flutter-handle-listview-overflow-in-column)
            child: NotificationListener<UserScrollNotification>(
              onNotification: (notification) {
                final ScrollDirection direction = notification.direction;
                if (direction == ScrollDirection.reverse) {
                  setState(() {
                    _listExpanded = true;
                    _virkeyTitleSize = 40;
                  });
                } else if (direction == ScrollDirection.forward) {
                  setState(() {
                    _listExpanded = false;
                    _virkeyTitleSize = 45;
                  });
                }
                print(_listExpanded);
                return true;
              },
              child: AnimatedList(
                key: recordingsListKey,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                initialItemCount: items.length,
                itemBuilder: (context, index, animation) {
                  return SizeTransition(
                    key: UniqueKey(),
                    sizeFactor: animation,
                    // position: animation.drive(
                    //   Tween(
                    //     begin: const Offset(0, 1),
                    //     end: Offset.zero,
                    //   ),
                    // ),
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
                                      {contractItem()}
                                    else
                                      {expandItem(index)}
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
                                          text: items[index],
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
                                      PropertyDescriptionActionCombination(
                                        title: items[index],
                                        icon: HeroIcons.pencilSquare,
                                        onPressed: () => {},
                                      ),
                                      const ExpandedListItemTitle(
                                          title: 'Audio-Playback'),
                                      PropertyDescriptionActionCombination(
                                        title: 'Audio',
                                        icon: HeroIcons.arrowDownTray,
                                        onPressed: () => {},
                                      ),
                                      PropertyDescriptionActionCombination(
                                        title: 'File1.mp3',
                                        icon: HeroIcons.trash,
                                        onPressed: () => {},
                                      ),
                                      const ExpandedListItemTitle(
                                          title: 'Export'),
                                      PropertyDescriptionActionCombination(
                                        title: 'Audio',
                                        icon: HeroIcons.arrowUpTray,
                                        onPressed: () => {},
                                      ),
                                      PropertyDescriptionActionCombination(
                                        title: 'MIDI',
                                        icon: HeroIcons.arrowUpTray,
                                        onPressed: () => {},
                                      ),
                                      PropertyDescriptionActionCombination(
                                        title: 'Audio & MIDI',
                                        icon: HeroIcons.arrowUpTray,
                                        onPressed: () => {},
                                      ),
                                      const ExpandedListItemTitle(
                                          title: 'Delete'),
                                      PropertyDescriptionActionCombination(
                                        title: 'Delete Recording',
                                        icon: HeroIcons.trash,
                                        onPressed: () => {},
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

class ExpandedListItemTitle extends StatelessWidget {
  const ExpandedListItemTitle({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 9),
      child: AppText(
        text: title,
        size: 16,
        letterSpacing: 3,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class PropertyDescriptionActionCombination extends StatelessWidget {
  const PropertyDescriptionActionCombination({
    Key? key,
    required this.title,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  final String title;
  final Object icon;
  final dynamic onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            text: title,
            size: 16,
            letterSpacing: 3,
            weight: AppFonts.weightLight,
          ),
          AppIcon(
            icon: icon,
            color: AppColors.dark,
          )
        ],
      ),
    );
  }
}
