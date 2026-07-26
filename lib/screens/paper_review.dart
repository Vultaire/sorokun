import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:soroban_app/models/level_definitions.dart';
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
        .where((entry) => !entry.isCorrect)
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
      FlashLevel _ || AloudLevel _ || MitoriLevel _ => Stack(
        children: [
          Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final carouselHeight = isPortrait
                    ? 500.0
                    : constraints.maxHeight * 0.9;
                return CarouselSlider.builder(
                  carouselController: _carouselController,
                  options: CarouselOptions(
                    height: carouselHeight,
                    reverse: true,
                    viewportFraction: isPortrait ? 0.95 : 0.3,
                    enlargeCenterPage: true,
                    enlargeStrategy: .scale,
                    enableInfiniteScroll: false,
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
                    return Stack(
                      children: [
                        Positioned(
                          left: 0,
                          top: 10,
                          child: FittedBox(
                            fit: .scaleDown,
                            child: Container(
                              width: 40.0,
                              height: 40.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  width: 2,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '${incorrectProblemScorers[problemIndex].index + 1}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontFamily: 'bizUDPGR',
                                    fontWeight: .bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            Expanded(
                              child: FittedBox(
                                fit: .fitHeight,
                                clipBehavior: Clip.hardEdge,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        ...currentProblem.map(
                                          (n) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 3.0,
                                              horizontal: 10.0,
                                            ),
                                            child: Text(
                                              n.toString(),
                                              style: const TextStyle(
                                                fontSize: 26,
                                                fontFamily: 'abacusFontSpaced',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      width: 700,
                                      height: 2,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                      margin: const EdgeInsets.only(top: 5),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 10,
                                      ),
                                      child: Column(
                                        children: [
                                          if (incorrectProblemScorers[problemIndex]
                                              .userAnswer
                                              .isNotEmpty)
                                            Text(
                                              incorrectProblemScorers[problemIndex]
                                                  .userAnswer,
                                              style: TextStyle(
                                                fontSize: 26,
                                                fontFamily: 'abacusFontSpaced',
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                decorationColor: Theme.of(
                                                  context,
                                                ).colorScheme.error,
                                              ),
                                            ),
                                          Text(
                                            incorrectProblemScorers[problemIndex]
                                                .answer,
                                            style: TextStyle(
                                              fontSize: 26,
                                              fontFamily: 'abacusFontSpaced',
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.error,
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
                        ),
                      ],
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
          CarouselSlider.builder(
            carouselController: _carouselController,
            options: CarouselOptions(
              height: 1000,
              scrollDirection: .vertical,
              viewportFraction: isPortrait ? 0.45 : 0.8,
              enlargeCenterPage: true,
              enlargeStrategy: .zoom,
              enlargeFactor: 0.25,
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
                  return Opacity(
                    opacity: isFocused ? 1.0 : 0.6,
                    child: Stack(
                      children: [
                        Align(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width: 40.0,
                                  height: 40.0,
                                  margin: const EdgeInsets.all(1.0),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      width: 2,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${problemIndex + 1}',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontFamily: 'bizUDPGR',
                                        fontWeight: .bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              FittedBox(
                                fit: .contain,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                      ),
                                      child: Text(
                                        currentProblem,
                                        style: const TextStyle(
                                          fontSize: 30,
                                          fontFamily: 'abacusFont',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text('||', style: TextStyle(fontSize: 26)),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 10,
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      incorrectProblemScorers[problemIndex]
                                          .userAnswer,
                                      style: TextStyle(
                                        fontSize: 26,
                                        fontFamily: 'abacusFontSpaced',
                                        decoration: TextDecoration.lineThrough,
                                        decorationColor: Theme.of(
                                          context,
                                        ).colorScheme.error,
                                      ),
                                    ),
                                    Text(
                                      incorrectProblemScorers[problemIndex]
                                          .answer,
                                      style: TextStyle(
                                        fontSize: 26,
                                        fontFamily: 'abacusFontSpaced',
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.error,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
          ),
          if (incorrectProblemScorers.length > 1)
            buildDots(
              alignment: isPortrait
                  ? const Alignment(0, 0.3)
                  : const Alignment(0, 0.8),
            ),
        ],
      ),
    };
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          MediaQuery.of(context).orientation == Orientation.landscape
              ? 40
              : kToolbarHeight,
        ),
        child: AppBar(title: const Text('不正解の問題'), centerTitle: true),
      ),
      body: SafeArea(child: body),
    );
  }
}
