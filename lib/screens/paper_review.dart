// Modified by Vultaire on 2026-11-01.
// Fork: https://github.com/Vultaire/sorokun
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:soroban_app/models/level_definitions.dart';
import 'package:soroban_app/screens/components/divmult_display.dart';
import 'package:soroban_app/screens/components/mitori_display.dart';
import 'package:soroban_app/screens/paper_results.dart';

class PaperReviewScreen extends StatefulWidget {
  final Level selectedLevel;
  final List<ProblemScorer> problemScorerList;

  const PaperReviewScreen({
    super.key,
    required this.selectedLevel,
    required this.problemScorerList,
  });

  @override
  State<PaperReviewScreen> createState() => _PaperReviewScreenState();
}

class _PaperReviewScreenState extends State<PaperReviewScreen> {
  int currentIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    final List<ProblemScorer> incorrectProblemScorers = widget.problemScorerList
        .where((entry) {
          return !entry.isCorrect;
        })
        .toList();
    bool isPortrait = MediaQuery.orientationOf(context) == .portrait;

    Widget buildDots({required Alignment? alignment}) {
      final dots = Wrap(
        alignment: WrapAlignment.center,
        spacing: 4,
        runSpacing: 4,
        children: incorrectProblemScorers
            .asMap()
            .entries
            .map((entry) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  _carouselController.animateToPage(
                    entry.key,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutExpo,
                  );
                },
                child: Container(
                  width: 12.0,
                  height: 12.0,
                  margin: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 4.0,
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        (Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black)
                            .withAlpha(currentIndex == entry.key ? 255 : 100),
                  ),
                ),
              );
            })
            .toList()
            .reversed
            .toList(),
      );

      return alignment == null
          ? dots
          : Align(alignment: alignment, child: dots);
    }

    final Widget body = switch (widget.selectedLevel) {
      FlashLevel _ || MitoriLevel _ => Stack(
        children: [
          Align(
            alignment: isPortrait ? .center : .topCenter,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final carouselHeight = isPortrait
                    ? 530.0
                    : constraints.maxHeight * 0.9;
                final maxDigits = widget.selectedLevel.maxDigits;
                return CarouselSlider.builder(
                  carouselController: _carouselController,
                  options: CarouselOptions(
                    height: carouselHeight,
                    reverse: true,
                    viewportFraction: isPortrait ? 1 : 0.45,
                    enlargeCenterPage: true,
                    enableInfiniteScroll: false,
                    enlargeStrategy: .zoom,
                    disableCenter: true,
                    enlargeFactor: 0.25,
                    onPageChanged: (index, reason) {
                      setState(() {
                        currentIndex = index;
                      });
                    },
                  ),
                  itemCount: incorrectProblemScorers.length,
                  itemBuilder: (BuildContext context, int problemIndex, int realIndex) {
                    final currentProblem =
                        incorrectProblemScorers[problemIndex].problem;
                    final isFocused = problemIndex == currentIndex;
                    return AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOutCubic,
                      opacity: isFocused ? 1.0 : 0.6,
                      child: FittedBox(
                        fit: .fitHeight,
                        clipBehavior: .none,
                        child: IntrinsicWidth(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              MitoriDisplay(
                                problemIndex:
                                    incorrectProblemScorers[problemIndex].index,
                                currentProblem: currentProblem,
                                isSimpleMitori:
                                    widget.selectedLevel is SimpleMitoriLevel,
                              ),
                              Container(
                                width:
                                    maxDigits * 28 +
                                    (((maxDigits - 1) ~/ 3) * 10) +
                                    67,
                                height: 2,
                                color: Theme.of(context).colorScheme.onSurface,
                                margin: const EdgeInsets.only(top: 5),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 10,
                                ),
                                child: Row(
                                  mainAxisAlignment: .end,
                                  children: [
                                    Column(
                                      crossAxisAlignment: .end,
                                      children: [
                                        if (incorrectProblemScorers[problemIndex]
                                            .userAnswer
                                            .isNotEmpty)
                                          Text(
                                            incorrectProblemScorers[problemIndex]
                                                .userAnswer,
                                            style: TextStyle(
                                              fontSize: 30,
                                              fontFamily: 'abacusFontSpaced',
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              decorationColor: Theme.of(
                                                context,
                                              ).colorScheme.error,
                                            ),
                                            textScaler: .noScaling,
                                          ),
                                        Text(
                                          incorrectProblemScorers[problemIndex]
                                              .answer,
                                          style: TextStyle(
                                            fontSize: 30,
                                            fontFamily: 'abacusFontSpaced',
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.error,
                                          ),
                                          textScaler: .noScaling,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 3),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (incorrectProblemScorers.length > 1)
            buildDots(
              alignment: isPortrait
                  ? const Alignment(0, 0.8)
                  : const Alignment(0, 0.95),
            ),
        ],
      ),

      DivMultLevel _ => Stack(
        children: [
          OverflowBox(
            maxHeight: MediaQuery.sizeOf(context).height + 30,
            alignment: .bottomCenter,
            child: CarouselSlider.builder(
              carouselController: _carouselController,
              options: CarouselOptions(
                height: MediaQuery.sizeOf(context).height + 30,
                scrollDirection: .vertical,
                viewportFraction: isPortrait ? 0.45 : 0.7,
                enlargeCenterPage: true,
                enlargeStrategy: .zoom,
                enlargeFactor: 0.2,
                enableInfiniteScroll: false,
                onPageChanged: (index, reason) {
                  setState(() {
                    currentIndex = index;
                  });
                },
              ),
              itemCount: incorrectProblemScorers.length,
              itemBuilder:
                  (BuildContext context, int problemIndex, int realIndex) {
                    final currentProblem =
                        incorrectProblemScorers[problemIndex].problem;
                    final isFocused = problemIndex == currentIndex;
                    return AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOutCubic,
                      opacity: isFocused ? 1.0 : 0.6,
                      child: DivMultDisplay(
                        problemIndex:
                            incorrectProblemScorers[problemIndex].index,
                        isFocused: isFocused,
                        underEquals: Column(
                          children: [
                            if (incorrectProblemScorers[problemIndex]
                                .userAnswer
                                .isNotEmpty)
                              Text(
                                incorrectProblemScorers[problemIndex]
                                    .userAnswer,
                                style: TextStyle(
                                  fontSize: 30,
                                  fontFamily: 'abacusFont',
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: Theme.of(
                                    context,
                                  ).colorScheme.error,
                                ),
                                textScaler: .noScaling,
                              ),
                            Text(
                              incorrectProblemScorers[problemIndex].answer,
                              style: TextStyle(
                                fontSize: 30,
                                fontFamily: 'abacusFont',
                                color: Theme.of(context).colorScheme.error,
                              ),
                              textScaler: .noScaling,
                            ),
                          ],
                        ),
                        intRoundIndex: -1,
                        currentProblem: currentProblem,
                      ),
                    );
                  },
            ),
          ),
          if (incorrectProblemScorers.length > 1)
            buildDots(
              alignment: isPortrait
                  ? const Alignment(0, 0.3)
                  : const Alignment(0, 0.85),
            ),
        ],
      ),
    };
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(isPortrait ? kToolbarHeight : 40),
        child: AppBar(title: const Text('不正解の問題'), centerTitle: true),
      ),
      body: SafeArea(child: body),
    );
  }
}
