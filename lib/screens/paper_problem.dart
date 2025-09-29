import 'package:flutter/material.dart';
import 'package:soroban_app/problem_generation/generation_spec.dart';
import 'package:soroban_app/problem_generation/variable_digits.dart';

import '../problem_generation/helpers.dart';

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

class _MainContainerState extends State<MainContainer> {
  late VariableDigitsProblemSet variableDigits;
  late List<List<String>> currentProblemSet;
  late List<String> currentProblem;
  late List<bool> answerBools = [];
  String selectedLevel = "dan"; // default
  int currentProblemIndex = 0;
  final TextEditingController _controller = TextEditingController();
  String _internalString = "";

  String beforeCursor = '';

  TextPainter? _textPainter;

  void _appendDigit(String digit) {
    String currentText = _controller.text.replaceAll(
      ',',
      '',
    ); // Remove existing commas

    // Check if we're trying to add a minus sign
    if (digit == '-') {
      // Only allow minus at the beginning and if there's no minus already
      if (!_internalString.startsWith('-')) {
        _internalString = '-$_internalString';
      } else if (_internalString.startsWith('-')) {
        // Remove minus if it's already there (toggle functionality)
        _internalString = _internalString.substring(1);
      }
    }
    // Check if we're trying to add a decimal point
    else if (digit == '.') {
      String displayNumber = _getDisplayString().replaceAll(',', '');
      if (!displayNumber.contains('.') &&
          _internalString.isNotEmpty &&
          _internalString != '-') {
        _internalString += digit;
      }
    } else {
      _internalString += digit;
    }

    // Check length limit (excluding commas, decimal point, and minus for counting)
    String digitsOnly = currentText.replaceAll(RegExp(r'[,.\-]'), '');
    if (digitsOnly.length > 15) {
      return; // Limit to 15 digits (excluding formatting)
    }

    _updateText();
  }

  String _getDisplayString() {
    if (_internalString.isEmpty) return '';

    String result = _internalString;
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

    return result;
  }

  void _deleteDigit() {
    if (_controller.text.isNotEmpty) {
      _internalString = _internalString.substring(
        0,
        _internalString.length - 1,
      );

      _updateText();
    }
  }

  void _updateText() {
    String displayString = _getDisplayString();
    String formatted = formatWithCommas(displayString);
    _controller.text = formatted;
    beforeCursor = _getTextBeforeCursor(_internalString);
    setState(() {});
  }

  String _getTextBeforeCursor(String internalString) {
    int lastAIndex = internalString.lastIndexOf('a');

    if (lastAIndex == -1) {
      return internalString;
    } else {
      String afterLastA = internalString.substring(lastAIndex + 1);
      return afterLastA;
    }
  }

  double _calculateCursorPixelPosition(String beforeCursor) {
    if (_controller.text.isEmpty || beforeCursor.isEmpty) return 0;

    _textPainter = TextPainter(
      text: TextSpan(
        text: beforeCursor,
        style: TextStyle(fontSize: 17, fontFamily: 'abacusFont'),
      ),
      textDirection: TextDirection.ltr,
    );
    _textPainter!.layout();
    return _textPainter!.width;
  }

  // Replace your TextField with this widget
  Widget _buildTextFieldWithCursor() {
    double cursorPixelPos = _calculateCursorPixelPosition(beforeCursor);

    return SizedBox(
      height: 30,
      child: Stack(
        children: [
          TextField(
            controller: _controller,
            readOnly: true,
            showCursor: false, // Disable native cursor
            style: TextStyle(fontSize: 17, fontFamily: 'abacusFont'),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "",
              counterText: "",
              contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
              isDense: true,
            ),
          ),
          // Custom static cursor
          Positioned(
            left: cursorPixelPos,
            top: 4,
            child: Container(width: 1.5, height: 20, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  void _checkAnswer() {
    // Get text from the controller
    final inputText = _controller.text;

    // Convert to integer
    final inputNumber = int.tryParse(inputText);

    setState(() {
      currentProblemIndex++;
    });

    if (inputNumber == null) {
      // Not a valid number
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid number")),
      );
      return;
    }

    if (inputNumber == variableDigits.sums[currentProblemIndex]) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Correct! 🎉")));
      answerBools[currentProblemIndex] = true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Wrong! The correct sum is ${variableDigits.sums[currentProblemIndex]}",
          ),
        ),
      );
      answerBools[currentProblemIndex] = false;
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final currentProblem = currentProblemSet[currentProblemIndex];
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
                  _buildTextFieldWithCursor(),
                ],
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

            // Keypad buttons
            Expanded(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    children: [
                      // Top row - backspace and home
                      Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                constraints: const BoxConstraints(
                                  maxWidth: 120,
                                ),
                                child: ElevatedButton(
                                  onPressed: _deleteDigit,
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Icon(Icons.backspace),
                                ),
                              ),
                            ),
                            SizedBox(width: 6),
                            Expanded(
                              child: Container(
                                constraints: const BoxConstraints(
                                  maxWidth: 120,
                                ),
                                child: ElevatedButton(
                                  onPressed: () => _appendDigit('a'),
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Icon(Icons.home),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Main keypad
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 3,
                          mainAxisSpacing: 6,
                          crossAxisSpacing: 6,
                          childAspectRatio: 2,
                          children: [
                            // Row 1: 7 8 9
                            Container(
                              constraints: const BoxConstraints(maxWidth: 120),
                              child: ElevatedButton(
                                onPressed: () => _appendDigit('7'),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  '7',
                                  style: TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                            Container(
                              constraints: const BoxConstraints(maxWidth: 120),
                              child: ElevatedButton(
                                onPressed: () => _appendDigit('8'),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  '8',
                                  style: TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                            Container(
                              constraints: const BoxConstraints(maxWidth: 120),
                              child: ElevatedButton(
                                onPressed: () => _appendDigit('9'),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  '9',
                                  style: TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                            // Row 2: 4 5 6
                            Container(
                              constraints: const BoxConstraints(maxWidth: 120),
                              child: ElevatedButton(
                                onPressed: () => _appendDigit('4'),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  '4',
                                  style: TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                            Container(
                              constraints: const BoxConstraints(maxWidth: 120),
                              child: ElevatedButton(
                                onPressed: () => _appendDigit('5'),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  '5',
                                  style: TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                            Container(
                              constraints: const BoxConstraints(maxWidth: 120),
                              child: ElevatedButton(
                                onPressed: () => _appendDigit('6'),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  '6',
                                  style: TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                            // Row 3: 1 2 3
                            Container(
                              constraints: const BoxConstraints(maxWidth: 120),
                              child: ElevatedButton(
                                onPressed: () => _appendDigit('1'),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  '1',
                                  style: TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                            Container(
                              constraints: const BoxConstraints(maxWidth: 120),
                              child: ElevatedButton(
                                onPressed: () => _appendDigit('2'),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  '2',
                                  style: TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                            Container(
                              constraints: const BoxConstraints(maxWidth: 120),
                              child: ElevatedButton(
                                onPressed: () => _appendDigit('3'),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  '3',
                                  style: TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                            // Row 4: - 0 . ✓
                            Container(
                              constraints: const BoxConstraints(maxWidth: 120),
                              child: ElevatedButton(
                                onPressed: () => _appendDigit('-'),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  '−',
                                  style: TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                            Container(
                              constraints: const BoxConstraints(maxWidth: 120),
                              child: ElevatedButton(
                                onPressed: () => _appendDigit('0'),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  '0',
                                  style: TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                            Container(
                              constraints: const BoxConstraints(maxWidth: 120),
                              child: ElevatedButton(
                                onPressed: () => _appendDigit('.'),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  '.',
                                  style: TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Bottom check button
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                constraints: const BoxConstraints(
                                  maxWidth: 120,
                                ),
                                child: ElevatedButton(
                                  onPressed: _checkAnswer,
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Icon(Icons.check),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
