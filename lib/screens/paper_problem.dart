import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:soroban_app/problem_generation/variable_digits.dart';

import '../models/divmult_difficulty.dart';
import '../models/mitori_difficulty.dart';
import '../problem_generation/generation_spec.dart';
import 'components/keypad.dart';

class PaperProblemScreen extends StatefulWidget {
  const PaperProblemScreen({required this.selectedLevel, super.key});
  final dynamic selectedLevel; // default

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
        key: _mitorizanKey,
      );
    } else if (widget.selectedLevel is DivMultLevel) {
      return DivMultWindow(
        selectedLevel: widget.selectedLevel as DivMultLevel,
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
      );
    } else if (widget.selectedLevel is DivMultLevel) {
      return Keypad(
        onAppendDigit: (digit) => _divMultKey.currentState?.appendDigit(digit),
        onDeleteDigit: () => _divMultKey.currentState?.deleteDigit(),
        onClearAll: () => _divMultKey.currentState?.clearAll(),
        onSubmit: () => _divMultKey.currentState?.submit(),
      );
    } else {
      return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Flexible(flex: 6, child: Container(child: _buildWindow())),
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
  const MitorizanWindow({required this.selectedLevel, super.key});
  final MitoriLevel selectedLevel;

  @override
  State<MitorizanWindow> createState() => _MitorizanWindowState();
}

class _MitorizanWindowState extends State<MitorizanWindow> with KeypadMethods {
  late final List<List<String>> allProblems;

  @override
  late final List<TextFieldData> textFieldData;

  @override
  int currentIndex = 0;

  @override
  late final CarouselSliderController carouselController =
      CarouselSliderController();

  @override
  void initState() {
    super.initState();
    _initializeProblem(widget.selectedLevel);
    textFieldData = List.generate(allProblems.length, (_) => TextFieldData());
  }

  void _initializeProblem(MitoriLevel level) {
    MitoriProblemSet fullProblemSet = MitoriProblemSet(
      level: widget.selectedLevel,
    );
    allProblems = fullProblemSet.formattedProblems;
  }

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      carouselController: carouselController,
      options: CarouselOptions(
        height: 500,
        reverse: true,
        onPageChanged: (index, reason) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
      itemCount: allProblems.length,
      itemBuilder: (BuildContext context, int problemIndex, int realIndex) {
        final currentProblem = allProblems[problemIndex];
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10.0, bottom: 8.0),
              child: Text(
                'Problem ${problemIndex + 1}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: currentProblem
                    .map(
                      (n) => Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 3.0,
                          horizontal: 10.0,
                        ),
                        child: Text(
                          n.toString(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontFamily: 'abacusFontSpaced',
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const Divider(
              color: Colors.black,
              thickness: 2,
              height: 10,
              indent: 38,
              endIndent: 38,
            ),
            CustomTextField(data: textFieldData[problemIndex]),
          ],
        );
      },
    );
  }
}

class DivMultWindow extends StatefulWidget {
  const DivMultWindow({required this.selectedLevel, super.key});
  final DivMultLevel selectedLevel;

  @override
  State<DivMultWindow> createState() => _DivMultWindowState();
}

class _DivMultWindowState extends State<DivMultWindow> with KeypadMethods {
  late final List<(String, String)> allProblems;

  @override
  late final List<TextFieldData> textFieldData;

  @override
  int currentIndex = 0;

  @override
  late final CarouselSliderController carouselController =
      CarouselSliderController();

  @override
  void initState() {
    super.initState();
    _initializeProblem(widget.selectedLevel);
    textFieldData = List.generate(allProblems.length, (_) => TextFieldData());
  }

  void _initializeProblem(DivMultLevel level) {
    DivMultProblemSet fullProblemSet = DivMultProblemSet(
      level: widget.selectedLevel,
    );
    allProblems = fullProblemSet.formattedProblems;
  }

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      carouselController: carouselController,
      options: CarouselOptions(
        height: 500,
        scrollDirection: .vertical,
        viewportFraction: 0.4,
        enlargeCenterPage: true,
        enlargeStrategy: .zoom,
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
          opacity: isFocused ? 1.0 : 0.4,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10.0, bottom: 8.0),
                child: Text(
                  'Problem ${problemIndex + 1}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 10.0,
                ),
                child: Text(
                  '${currentProblem.$1} / ${currentProblem.$2}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontFamily: 'abacusFont',
                  ),
                ),
              ),
              const Text('||', style: TextStyle(fontSize: 20)),
              CustomTextField(
                data: textFieldData[problemIndex],
                isFocused: isFocused,
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
          fontSize: 20.4,
          fontFamily: 'abacusFontSpaced',
        ), // I don't know why the caret position drifts unless I add the extra .4 here.
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final caretPos = textPainter.width;

    return SizedBox(
      height: 50,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 10),
            child: Text(
              data.formatted,
              style: const TextStyle(
                fontSize: 20,
                fontFamily: 'abacusFontSpaced',
              ),
            ),
          ),
          // Custom static cursor
          if (isFocused)
            Positioned(
              left: caretPos + 7,
              top: 10,
              child: Container(
                width: 2,
                height: 30,
                color: Theme.of(context).primaryColor,
              ),
            ),
        ],
      ),
    );
  }
}
