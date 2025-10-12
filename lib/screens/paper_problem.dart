import 'package:flutter/material.dart';
import 'package:soroban_app/problem_generation/generation_spec.dart';
import 'package:soroban_app/problem_generation/variable_digits.dart';

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
  final TextEditingController _controller = TextEditingController();
  double caretPos = 0;

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

  Widget _buildTextFieldWithCursor() {
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
            left: caretPos,
            top: 2,
            child: Container(width: 1.5, height: 28, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentProblem = currentProblemSet[currentProblemIndex];
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 5),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  children: [
                    // Row with side buttons and middle numbers
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Left button flush to left
                          SizedBox(
                            width: 40,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                surfaceTintColor: Colors.transparent,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (currentProblemIndex > 0) {
                                    currentProblemIndex--;
                                  } else {
                                    currentProblemIndex =
                                        currentProblemSet.length - 1;
                                  }
                                });
                              },
                              child: const Icon(Icons.arrow_back),
                            ),
                          ),

                          // Middle numbers (right-aligned and vertically centered)
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment
                                  .center, // vertical centering
                              crossAxisAlignment:
                                  CrossAxisAlignment.end, // right-aligned
                              children: currentProblem
                                  .map(
                                    (n) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 3.0,
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

                          // Right button flush to right
                          SizedBox(
                            width: 40,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                surfaceTintColor: Colors.transparent,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (currentProblemIndex <
                                      currentProblemSet.length - 1) {
                                    currentProblemIndex++;
                                  } else {
                                    currentProblemIndex = 0;
                                  }
                                });
                              },
                              child: const Icon(Icons.arrow_forward),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Divider(
                      color: Colors.black,
                      thickness: 2,
                      height: 10,
                    ),
                    _buildTextFieldWithCursor(),
                  ],
                ),
              ),
            ),
            Keypad(
              controller: _controller,
              onCaretChanged: (newPos) {
                setState(() {
                  caretPos = newPos;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
