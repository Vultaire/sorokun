import 'package:flutter/material.dart';
import 'package:soroban_app/problem_generation/generation_spec.dart';
import 'package:soroban_app/problem_generation/paper_source.dart';
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

class _MainContainerState extends State<MainContainer> {
  final TextEditingController _controller = TextEditingController();
  double caretPos = 0;

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
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // PROBLEM AREA - Takes 60% of the screen height
            Flexible(
              child: Container(
                // The margin and decoration for your problem box
                margin: const EdgeInsets.fromLTRB(40, 5, 40, 5),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  children: [
                    MitorizanWindow(),
                    const Spacer(),
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
            Expanded(
              child: Keypad(
                controller: _controller,
                onCaretChanged: (newPos) {
                  setState(() {
                    caretPos = newPos;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MitorizanWindow extends StatefulWidget {
  const MitorizanWindow({super.key});

  @override
  State<MitorizanWindow> createState() => _MitorizanWindowState();
}

class _MitorizanWindowState extends State<MitorizanWindow> {
  int currentProblemIndex = 0;
  String selectedLevel = "dan"; // default
  late List<List<String>> currentProblemSet;
  List<String> get currentProblem => currentProblemSet[currentProblemIndex];

  @override
  void initState() {
    super.initState();
    _initializeProblem(selectedLevel);
  }

  void _initializeProblem(String level) {
    VariableDigitsProblemSet variableDigits = VariableDigitsProblemSet(
      spec: PaperSpec(source: PaperSources.k5),
    );
    currentProblemSet = variableDigits.formattedProblems;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 40,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              padding: EdgeInsets.zero,
            ),
            onPressed: () {
              setState(() {
                if (currentProblemIndex > 0) {
                  currentProblemIndex--;
                } else {
                  currentProblemIndex = currentProblemSet.length - 1;
                }
              });
            },
            child: const Icon(Icons.arrow_back),
          ),
        ),

        // Middle numbers
        Expanded(
          child: Column(
            // These properties are still correct for alignment within the column
            mainAxisAlignment: MainAxisAlignment.center,
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

        // Right button
        SizedBox(
          width: 40,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              padding: EdgeInsets.zero,
            ),
            onPressed: () {
              setState(() {
                if (currentProblemIndex < currentProblemSet.length - 1) {
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
    );
  }
}
