import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:provider/provider.dart';
import 'package:virkey/common_widgets/app_button.dart';
import 'package:virkey/common_widgets/app_icon.dart';
import 'package:virkey/features/app_introduction/introduction_provider.dart';
import 'package:virkey/utils/overlay.dart';
import 'package:virkey/common_widgets/app_text.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/fonts.dart';
import 'package:virkey/utils/platform_helper.dart';

class IntroductionOverlay {
  final BuildContext context;
  final TickerProvider vsync;

  IntroductionOverlay({
    required this.context,
    required this.vsync,
  });

  void close() {
    _overlay.close();
  }

  void open() {
    Provider.of<IntroductionProvider>(context, listen: false)
        .currentSlideIndex = 0;
    _overlay.open();
  }

  final Duration _slideDuration = const Duration(milliseconds: 150);
  final Curve _slideCurve = Curves.linear;

  // Original Plugin: carousel_slider
  // Problem: only supports fixed aspect ratio or fixed height
  // https://pub.dev/packages/carousel_slider, 13.02.2023
  // Solution: Plugin alternative: expandable_page_view
  // Plugin basically implements all function of previous plugin
  // https://pub.dev/packages/expandable_page_view, 13.02.2023

  final PageController _pageController = PageController();

  static const double _maxWidthDesktop = 574;

  static const _introductionImagesPath = 'assets/images/introduction_overlay/';

  static Image _introductionImage(int index) => Image(
      image: AssetImage(_introductionImagesPath +
          (PlatformHelper.isDesktop
              ? 'desktop/$index.png'
              : 'mobile/$index.png')));

  static Widget _slide(int imageNumber, String text, [String? optionalText]) {
    return Flexible(
      fit: FlexFit.loose,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxWidthDesktop),
          // TODO: make introduction screen scrollable
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _introductionImage(imageNumber),
              AppText(
                size: 19,
                height: 1.6,
                letterSpacing: 4,
                textAlign: TextAlign.center,
                text: text,
              ),
              const SizedBox(height: 35),
              if (optionalText != null)
                AppText(
                  height: 1.5,
                  textAlign: TextAlign.center,
                  text: optionalText,
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> get _slides => [
        _slide(
          1,
          "You can start playing by pressing the 'Play' button if a VirKey is connected to your device!",
          "Note: It is also possible to play without a VirKey connected.",
        ),
        _slide(
          2,
          "Your recordings can be found underneath the 'Play' button.",
        ),
        _slide(
          3,
          "In the settings you can change the volume, the sound libraries and log in for cloud synchronization.",
          "Note: settings, recordings and sound libraries will be synchronized.",
        ),
        _slide(
          4,
          "After pressing the 'Play' button you access the piano view. Here you are able to see which notes you are playing.",
        ),
        _slide(
          5,
          "Here you can start recording the notes you play.",
        ),
        _slide(
          6,
          "Here you can switch between octaves.",
        ),
        _slide(
          7,
          "And here you can change the output instrument or run a playback track. \n Have fun with VirKey!",
        ),
      ];

  late final AppOverlay _overlay = AppOverlay(
    context: context,
    vsync: vsync,
    children: [
      Padding(
        padding: const EdgeInsets.all(11),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 40,
          child: Stack(
            children: [
              const Positioned.fill(
                  left: 0,
                  right: 0,
                  child: Center(
                    child: AppText(
                      text: 'Welcome!',
                      size: 30,
                      family: AppFonts.secondary,
                    ),
                  )),
              Positioned(
                left: 0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AppIcon(
                      icon: HeroIcons.arrowUturnLeft,
                      color: AppColors.dark,
                      onPressed: () => close()),
                ),
              ),
            ],
          ),
        ),
      ),
      Consumer<IntroductionProvider>(
        builder: (BuildContext context,
                IntroductionProvider introductionProvider, Widget? child) =>
            Flexible(
          fit: FlexFit.loose,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                fit: FlexFit.loose,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ExpandablePageView.builder(
                          controller: _pageController,
                          itemCount: _slides.length,
                          onPageChanged: (int index) {
                            introductionProvider.currentSlideIndex = index;
                            introductionProvider.notify();
                          },
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [_slides[index]],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(11),
                child: Column(
                  children: [
                    if (!PlatformHelper.isDesktop &&
                        introductionProvider.currentSlideIndex ==
                            _slides.length - 1)
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: AppButton(
                                    appText: const AppText(
                                      text: "Let's Play",
                                      color: AppColors.white,
                                      size: 22,
                                      letterSpacing: 5,
                                    ),
                                    onPressed: () {
                                      close();
                                    }),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10)
                        ],
                      ),
                    DotsIndicator(
                      dotsCount: _slides.length,
                      position:
                          introductionProvider.currentSlideIndex.toDouble(),
                      decorator: const DotsDecorator(
                        color: AppColors.white,
                        activeColor: AppColors.primary,
                        size: Size.square(12),
                        activeSize: Size.square(12),
                        spacing:
                            EdgeInsets.symmetric(horizontal: 3, vertical: 6),
                        shape: CircleBorder(
                            side: BorderSide(color: AppColors.primary)),
                      ),
                    ),
                    if (PlatformHelper.isDesktop)
                      ConstrainedBox(
                        constraints:
                            const BoxConstraints(maxWidth: _maxWidthDesktop),
                        child: Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                appText: AppText(
                                  text:
                                      introductionProvider.currentSlideIndex ==
                                              0
                                          ? 'Skip'
                                          : 'Previous',
                                  color: AppColors.white,
                                  size: 22,
                                  letterSpacing: 5,
                                ),
                                onPressed: () {
                                  if (introductionProvider.currentSlideIndex ==
                                      0) {
                                    _pageController
                                        .jumpToPage(_slides.length - 1);
                                  } else {
                                    _pageController.previousPage(
                                        duration: _slideDuration,
                                        curve: _slideCurve);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Expanded(
                              child: AppButton(
                                appText: AppText(
                                  text:
                                      introductionProvider.currentSlideIndex ==
                                              _slides.length - 1
                                          ? "Let's Play"
                                          : 'Next',
                                  color: AppColors.white,
                                  size: 22,
                                  letterSpacing: 5,
                                ),
                                onPressed: () {
                                  if (introductionProvider.currentSlideIndex ==
                                      _slides.length - 1) {
                                    close();
                                  } else {
                                    _pageController.nextPage(
                                        duration: _slideDuration,
                                        curve: _slideCurve);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 15),
                    const AppText(
                      textAlign: TextAlign.center,
                      text: 'www.virkey.at',
                      letterSpacing: 3,
                      weight: AppFonts.weightLight,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
