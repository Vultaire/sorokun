import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:soroban_app/problem_generation/variable_digits.dart';
import 'package:soroban_app/screens/components/pie_timer.dart';

import '../models/level_definitions.dart';
import '../problem_generation/generation_spec.dart';
import 'components/keypad.dart';

class PaperProblemScreen extends StatefulWidget {
  const PaperProblemScreen({
    required this.selectedLevel,
    required this.isExam,
    required this.time,
    required this.appBarTitle,
    super.key,
  });
  final ProblemLevel selectedLevel;
  final bool isExam;
  final Duration time;
  final String appBarTitle;

  @override
  State<PaperProblemScreen> createState() => _PaperProblemScreenState();
}

class _PaperProblemScreenState extends State<PaperProblemScreen> {
  final GlobalKey<_MitorizanWindowState> _mitorizanKey = GlobalKey();
  final GlobalKey<_DivMultWindowState> _divMultKey = GlobalKey();

  Widget _buildWindow() {
    if (widget.selectedLevel is MitoriLevel) {
      return MitorizanWindow(
        selectedLevel: widget.selectedLevel as MitoriLevel,
        isExam: widget.isExam,
        key: _mitorizanKey,
      );
    } else if (widget.selectedLevel is DivMultLevel) {
      return DivMultWindow(
        selectedLevel: widget.selectedLevel as DivMultLevel,
        isExam: widget.isExam,
        key: _divMultKey,
      );
    } else {
      return const Center(child: Text('Unknown level type'));
    }
  }

  Widget _buildKeypad() {
    if (widget.selectedLevel is MitoriLevel) {
      return Keypad(
        onAppendDigit: (digit) =>
            _mitorizanKey.currentState?.appendDigit(digit),
        onDeleteDigit: () => _mitorizanKey.currentState?.deleteDigit(),
        onClearAll: () => _mitorizanKey.currentState?.clearAll(),
        onSubmit: () => _mitorizanKey.currentState?.submit(),
        levelType: widget.selectedLevel,
      );
    } else if (widget.selectedLevel is DivMultLevel) {
      return Keypad(
        onAppendDigit: (digit) => _divMultKey.currentState?.appendDigit(digit),
        onDeleteDigit: () => _divMultKey.currentState?.deleteDigit(),
        onClearAll: () => _divMultKey.currentState?.clearAll(),
        onSubmit: () => _divMultKey.currentState?.submit(),
        levelType: widget.selectedLevel,
      );
    } else {
      return const SizedBox();
    }
  }

  void onComplete() {
    //TODO
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appBarTitle),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [PieTimer(duration: widget.time, onComplete: onComplete)],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(flex: 8, child: Container(child: _buildWindow())),
            Expanded(flex: 5, child: _buildKeypad()),
          ],
        ),
      ),
    );
  }
}

class TextFieldData {
  String internalString = '';
  String formatted = '';
  String beforeCaret = '';
  double caretPos = 0.0;
}

class MitorizanWindow extends StatefulWidget {
  const MitorizanWindow({
    required this.selectedLevel,
    required this.isExam,
    super.key,
  });
  final MitoriLevel selectedLevel;
  final bool isExam;

  @override
  State<MitorizanWindow> createState() => _MitorizanWindowState();
}

class _MitorizanWindowState extends State<MitorizanWindow> with KeypadMethods {
  late final List<List<String>> allProblems;

  @override
  late final bool isExam = widget.isExam;

  @override
  late final List<String> allAnswers;

  @override
  late final List<bool> answerBools;

  @override
  late final List<TextFieldData> textFieldDataList;

  @override
  int currentIndex = 0;

  @override
  late final CarouselSliderController carouselController =
      CarouselSliderController();

  @override
  void initState() {
    super.initState();
    _initializeProblem(widget.selectedLevel);
    textFieldDataList = List.generate(
      allProblems.length,
      (_) => TextFieldData(),
    );
    answerBools = List.generate(allProblems.length, (_) => false);
  }

  void _initializeProblem(MitoriLevel level) {
    MitoriProblemSet fullProblemSet = MitoriProblemSet(
      level: widget.selectedLevel,
    );
    allProblems = fullProblemSet.formattedProblems;
    allAnswers = fullProblemSet.formattedAnswers;
  }

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      carouselController: carouselController,
      options: CarouselOptions(
        height: 500,
        reverse: true,
        viewportFraction: 0.95,
        enlargeCenterPage: true,
        enlargeStrategy: .scale,
        onPageChanged: (index, reason) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
      itemCount: allProblems.length,
      itemBuilder: (BuildContext context, int problemIndex, int realIndex) {
        final currentProblem = allProblems[problemIndex];
        final isFocused = problemIndex == currentIndex;
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
                          crossAxisAlignment: CrossAxisAlignment.end,
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
                        CustomTextField(
                          data: textFieldDataList[problemIndex],
                          isFocused: isFocused,
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
  }
}

class DivMultWindow extends StatefulWidget {
  const DivMultWindow({
    required this.selectedLevel,
    required this.isExam,
    super.key,
  });
  final DivMultLevel selectedLevel;
  final bool isExam;

  @override
  State<DivMultWindow> createState() => _DivMultWindowState();
}

class _DivMultWindowState extends State<DivMultWindow> with KeypadMethods {
  late final List<String> allProblems;
  late final int
  intRoundIndex; // index in allProblems at the first problem to require an answer rounded to integer

  @override
  late final bool isExam = widget.isExam;

  @override
  late final List<String> allAnswers;

  @override
  late final List<bool> answerBools;

  @override
  late final List<TextFieldData> textFieldDataList;

  @override
  int currentIndex = 0;

  @override
  late final CarouselSliderController carouselController =
      CarouselSliderController();

  @override
  void initState() {
    super.initState();
    _initializeProblem(widget.selectedLevel);
    textFieldDataList = List.generate(
      allProblems.length,
      (_) => TextFieldData(),
    );
    answerBools = List.generate(allProblems.length, (_) => false);
  }

  void _initializeProblem(DivMultLevel level) {
    DivMultProblemSet fullProblemSet = DivMultProblemSet(
      level: widget.selectedLevel,
    );
    allProblems = fullProblemSet.formattedProblems;
    allAnswers = fullProblemSet.formattedAnswers;
    intRoundIndex = allProblems.indexWhere((item) => item.startsWith('\\'));
  }

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      carouselController: carouselController,
      options: CarouselOptions(
        height: 700,
        scrollDirection: .vertical,
        viewportFraction: 0.5,
        enlargeCenterPage: true,
        enlargeStrategy: .zoom,
        enlargeFactor: 0.25,
        onPageChanged: (index, reason) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
      itemCount: allProblems.length,
      itemBuilder: (BuildContext context, int problemIndex, int realIndex) {
        final currentProblem = allProblems[problemIndex];
        final isFocused = problemIndex == currentIndex;
        return Opacity(
          opacity: isFocused ? 1.0 : 0.6,
          child: Stack(
            children: [
              if (problemIndex == 0 && intRoundIndex != -1)
                Align(
                  alignment: .topCenter,
                  child: Transform.translate(
                    offset: const Offset(0, -30.0),
                    child: Text(
                      '（注意） 小数第3位未満四捨五入。',
                      style: TextStyle(fontSize: 18, fontFamily: 'bizUDPGR'),
                    ),
                  ),
                ),
              if (problemIndex == intRoundIndex)
                Align(
                  alignment: .topCenter,
                  child: Transform.translate(
                    offset: const Offset(0, -30.0),
                    child: Text(
                      '（注意） 整数位未満四捨五入。',
                      style: TextStyle(fontSize: 18, fontFamily: 'bizUDPGR'),
                    ),
                  ),
                ),
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
                          border: Border.all(width: 2),
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
                                fontSize: 26,
                                fontFamily: 'abacusFont',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text('||', style: TextStyle(fontSize: 26)),
                    CustomTextField(
                      data: textFieldDataList[problemIndex],
                      isFocused: isFocused,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.data,
    this.isFocused = false,
  });

  final TextFieldData data;
  final bool isFocused;

  @override
  Widget build(BuildContext context) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: data.beforeCaret,
        style: const TextStyle(
          fontSize: 26.4,
          fontFamily: 'abacusFontSpaced',
        ), // I don't know why the caret position drifts unless I add the extra .4 here.
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final caretPos = textPainter.width;

    return SizedBox(
      height: 55,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 10),
            child: Text(
              data.formatted,
              style: const TextStyle(
                fontSize: 26,
                fontFamily: 'abacusFontSpaced',
              ),
            ),
          ),
          // Custom static cursor
          if (isFocused)
            Positioned(
              left: caretPos + 6,
              top: 10,
              child: Container(
                width: 2,
                height: 40,
                color: Theme.of(context).primaryColor,
              ),
            ),
        ],
      ),
    );
  }
}
