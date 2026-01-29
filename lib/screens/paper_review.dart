import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:soroban_app/models/level_definitions.dart';
import 'package:soroban_app/screens/paper_results.dart';

class PaperReviewScreen extends StatefulWidget {
  final PaperProblemLevel selectedLevel;
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

  @override
  Widget build(BuildContext context) {
    final List<ProblemScorer> incorrectProblemScorers = widget.problemScorerList
        .where((entry) => !entry.isCorrect)
        .toList();

    switch (widget.selectedLevel) {
      case (MitoriLevel _):
        return Scaffold(
          appBar: AppBar(title: Text("不正解の問題")),
          body: SafeArea(
            child: Column(
              mainAxisAlignment: .center,
              children: [
                CarouselSlider.builder(
                  options: CarouselOptions(
                    height: 500,
                    reverse: true,
                    viewportFraction: 0.95,
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
                          child: Container(
                            width: 40.0,
                            height: 40.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(width: 2),
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
                                      color: Colors.black,
                                      margin: const EdgeInsets.only(top: 5),
                                    ),
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
                                            style: const TextStyle(
                                              fontSize: 26,
                                              fontFamily: 'abacusFontSpaced',
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              decorationColor: Colors.red,
                                            ),
                                          ),
                                          Text(
                                            incorrectProblemScorers[problemIndex]
                                                .answer,
                                            style: const TextStyle(
                                              fontSize: 26,
                                              fontFamily: 'abacusFontSpaced',
                                              color: Colors.red,
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
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: incorrectProblemScorers
                      .asMap()
                      .entries
                      .map((entry) {
                        return Container(
                          width: 12.0,
                          height: 12.0,
                          margin: EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 4.0,
                          ),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                (Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : Colors.black)
                                    .withOpacity(
                                      currentIndex == entry.key ? 0.9 : 0.4,
                                    ),
                          ),
                        );
                      })
                      .toList()
                      .reversed
                      .toList(),
                ),
              ],
            ),
          ),
        );

      case (DivMultLevel _):
        return const Placeholder();
    }
  }
}
