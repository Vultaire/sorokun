import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:soroban_app/problem_generation/generation_spec.dart';
import 'package:soroban_app/problem_generation/helpers.dart';
import 'package:soroban_app/problem_generation/variable_digits.dart';

import 'components/keypad.dart';
import '../models/sources.dart';

class PaperProblemScreen extends StatefulWidget {
  const PaperProblemScreen({required this.selectedLevel, super.key});
  final Difficulty selectedLevel; // default

  @override
  State<PaperProblemScreen> createState() => _PaperProblemScreenState();
}

class _PaperProblemScreenState extends State<PaperProblemScreen> {
  final GlobalKey<_MitorizanWindowState> _mitorizanKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              flex: 6,
              child: Container(
                margin: const EdgeInsets.fromLTRB(40, 5, 40, 5),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: MitorizanWindow(key: _mitorizanKey),
              ),
            ),
            Expanded(
              flex: 5,
              child: Builder(
                builder: (context) {
                  final mitorizanState = _mitorizanKey.currentState;
                  if (mitorizanState == null) {
                    return const SizedBox();
                  }
                  return Keypad(
                    onAppendDigit: mitorizanState.appendDigit,
                    onDeleteDigit: mitorizanState.deleteDigit,
                    onClearAll: mitorizanState.clearAll,
                    onSubmit: mitorizanState.submit,
                  );
                },
              ),
            ),
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
  const MitorizanWindow({super.key});

  @override
  State<MitorizanWindow> createState() => _MitorizanWindowState();
}

class _MitorizanWindowState extends State<MitorizanWindow> {
  late final List<List<String>> currentProblemSet;
  late final List<TextFieldData> _textFieldData;
  int _currentIndex = 0;
  late final CarouselSliderController carouselController =
      CarouselSliderController();

  @override
  void initState() {
    super.initState();
    _initializeProblem(selectedLevel);
    _textFieldData = List.generate(
      currentProblemSet.length,
      (_) => TextFieldData(),
    );
  }

  void appendDigit(String digit) {
    setState(() {
      final data = _textFieldData[_currentIndex];

      if (digit == '-') {
        if (!data.internalString.startsWith('-')) {
          data.internalString = '-${data.internalString}';
        } else {
          data.internalString = data.internalString.substring(1);
        }
      } else if (digit == '.') {
        if (!data.internalString.contains('.') &&
            data.internalString.isNotEmpty &&
            data.internalString != '-') {
          data.internalString += digit;
        }
      } else if (digit == 'a') {
        if (!data.internalString.endsWith('a') &&
            data.internalString.isNotEmpty &&
            data.internalString != '-') {
          data.internalString += digit;
        }
      } else {
        String digitsOnly = data.formatted.replaceAll(RegExp(r'[,.\-]'), '');
        if (digitsOnly.length < 10) {
          data.internalString += digit;
        }
      }
      _updateText(data);
    });
  }

  void _updateText(TextFieldData data) {
    String result = '${data.internalString}b';
    bool hasMinusSign = false;
    if (result.startsWith('-')) {
      hasMinusSign = true;
      result = result.substring(1);
    }
    if (result.contains('a')) {
      List<String> parts = result.split('a');
      result = parts.reversed.join('');
    }
    if (hasMinusSign) {
      result = '-$result';
    }
    String formattedWithPlaceholder = formatWithCommas(result);
    int caretIndex = formattedWithPlaceholder.indexOf('b');
    data.formatted = formattedWithPlaceholder.replaceAll('b', '');
    data.beforeCaret = data.formatted.substring(0, caretIndex);
  }

  void deleteDigit() {
    if (_textFieldData[_currentIndex].internalString.isNotEmpty) {
      setState(() {
        final data = _textFieldData[_currentIndex];
        data.internalString = data.internalString.substring(
          0,
          data.internalString.length - 1,
        );
        _updateText(data);
      });
    }
  }

  void clearAll() {
    setState(() {
      final data = _textFieldData[_currentIndex];
      data.internalString = '';
      _updateText(data);
    });
  }

  void submit() {
    if (_textFieldData[_currentIndex].internalString.isEmpty) {
      () {}; //TODO: Add sound
    } else {
      for (var offset = 1; offset <= _textFieldData.length; offset++) {
        final i = (_currentIndex + offset) % _textFieldData.length;
        if (_textFieldData[i].internalString.isEmpty) {
          carouselController.animateToPage(i, curve: Curves.easeOutExpo);
          break;
        } else {
          () {}; //TODO: Add scoring callback
        }
      }
    }
  }

  void _initializeProblem(PaperSource source) {
    VariableDigitsProblemSet variableDigits = VariableDigitsProblemSet(
      spec: PaperSpec(source: source),
    );
    currentProblemSet = variableDigits.formattedProblems;
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
            _currentIndex = index;
          });
        },
      ),
      itemCount: currentProblemSet.length,
      itemBuilder: (BuildContext context, int problemIndex, int realIndex) {
        final currentProblem = currentProblemSet[problemIndex];
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
            CustomTextField(data: _textFieldData[_currentIndex]),
          ],
        );
      },
    );
  }
}

class CustomTextField extends StatelessWidget {
  const CustomTextField({super.key, required this.data});

  final TextFieldData data;

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
          Positioned(
            left: caretPos + 7, // Account for padding
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
