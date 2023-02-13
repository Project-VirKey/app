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

  final List<Widget> _slides = [
    const AppText(
      text: 'Slide 1',
    ),
    const AppText(
      text: 'Slide 2',
    ),
    const AppText(
      text: 'Slide 3',
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
                      text: 'Intro',
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
                      ExpandablePageView.builder(
                        controller: _pageController,
                        itemCount: _slides.length,
                        onPageChanged: (int index) {
                          introductionProvider.currentSlideIndex = index;
                          introductionProvider.notify();
                        },
                        itemBuilder: (context, index) {
                          return Container(
                            color: Colors.lightBlueAccent,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 20),
                                      child: _slides[index],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(11),
                child: Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        appText: AppText(
                          text: introductionProvider.currentSlideIndex == 0
                              ? 'Skip'
                              : 'Previous',
                          color: AppColors.white,
                          size: 22,
                          letterSpacing: 5,
                        ),
                        onPressed: () {
                          if (introductionProvider.currentSlideIndex == 0) {
                            _pageController.jumpToPage(_slides.length - 1);
                          } else {
                            _pageController.previousPage(
                                duration: _slideDuration, curve: _slideCurve);
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: AppButton(
                        appText: AppText(
                          text: introductionProvider.currentSlideIndex ==
                                  _slides.length - 1
                              ? 'Done'
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
                                duration: _slideDuration, curve: _slideCurve);
                          }
                        },
                      ),
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
