import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:soroban_app/problem_generation/generation_spec.dart';
import 'package:soroban_app/problem_generation/variable_digits.dart';

import '../problem_generation/helpers.dart';
import 'components/keypadold.dart';

void main() {
  runApp(const MainPage());
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainContainer(),
    );
  }
}

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class AlwaysFocusedNode extends FocusNode {
  @override
  bool get hasFocus => true;
}

class _MainContainerState extends State<MainContainer> {
  late VariableDigitsProblemSet variableDigits;
  late List<List<String>> currentProblemSet;
  late List<String> currentProblem;
  late List<bool> answerBools = [];
  String selectedLevel = "dan"; // default
  int currentProblemIndex = 0;
  String formatted = '';
  int caretIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeProblem(selectedLevel);
  }

  void _initializeProblem(String level) {
    final spec = getPaperSpec(level);
    variableDigits = VariableDigitsProblemSet(spec: getPaperSpec("dan"));
    currentProblemSet = variableDigits.formattedProblems;
    currentProblemIndex = 0;
    List<bool> answerBools = List.filled(currentProblemSet.length, false);
  }

  double _calculateCursorPixelPosition() {
    if (_controller.text.isEmpty) return 0;

    _textPainter = TextPainter(
      text: TextSpan(
        text: _beforeCaret,
        style: TextStyle(fontSize: 17, fontFamily: 'abacusFont'),
      ),
      textDirection: TextDirection.ltr,
    );
    _textPainter!.layout();
    return _textPainter!.width;
  }

  @override
  Widget build(BuildContext context) {
    final currentProblem = currentProblemSet[currentProblemIndex];

    final text = controller.text;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              margin: EdgeInsets.symmetric(horizontal: 40, vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: currentProblem
                          .map(
                            (number) => Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 3.0,
                              ),
                              child: Text(
                                number.toString(),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: 'abacusFontSpaced',
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  Divider(
                    color: Colors.black,
                    thickness: 2,
                    indent: 0,
                    endIndent: 0,
                  ),
                  
Stack(
            children: [
              Text(formatted, style: const TextStyle(fontSize: 20)),
              Positioned(
                left: _calculateCaretPixel(formatted, caretIndex),
                top: 0,
                bottom: 0,
                child: Container(width: 2, color: Colors.blue),
              ),
            ],
          ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (currentProblemIndex > 0) {
                        currentProblemIndex--;
                      } else {
                        currentProblemIndex = currentProblemSet.length - 1;
                      }
                    });
                  },
                  child: Icon(Icons.arrow_back),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (currentProblemIndex < currentProblemSet.length - 1) {
                        currentProblemIndex++;
                      } else {
                        currentProblemIndex = 0;
                      }
                    });
                  },
                  child: Icon(Icons.arrow_forward),
                ),
              ],
            ),
            Keypad(),
          ],
        ),
      ),
    );
  }
}
