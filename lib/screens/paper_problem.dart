import 'package:flutter/material.dart';
import 'package:soroban_app/problem_generation/generation_spec.dart';
import 'package:soroban_app/problem_generation/variable_digits.dart';

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
  late List<List<int>> currentProblemSet;
  late List<int> currentProblem;
  late List<bool> answerBools = [];
  String selectedLevel = "1kyuu"; // default
  int currentProblemIndex = 0;
  final TextEditingController _controller = TextEditingController();

  void _appendDigit(String digit) {
    _controller.text += digit;
  }

  void _deleteDigit() {
    if (_controller.text.isNotEmpty) {
      _controller.text = _controller.text.substring(
        0,
        _controller.text.length - 1,
      );
    }
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
    variableDigits = VariableDigitsProblemSet(spec: getPaperSpec("1kyuu"));
    currentProblemSet = variableDigits.allProblems;
    currentProblemIndex = 0;
    List<bool> answerBools = List.filled(currentProblemSet.length, false);
  }

  @override
  Widget build(BuildContext context) {
    final currentProblem = currentProblemSet[currentProblemIndex];
    return Scaffold(
      appBar: AppBar(title: const Text("Problems")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  "Problem ${currentProblemIndex + 1}",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Column(
                  children: currentProblem
                      .map(
                        (number) => Text(
                          number.toString(),
                          style: TextStyle(fontSize: 24),
                        ),
                      )
                      .toList(),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _controller,
                    readOnly: true, // prevent system keyboard
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Enter number",
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                child: Icon(Icons.arrow_back),
              ),
              SizedBox(width: 20),
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
                child: Icon(Icons.arrow_forward),
              ),
            ],
          ),

          // Keypad buttons
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  for (var i = 1; i <= 9; i++)
                    ElevatedButton(
                      onPressed: () => _appendDigit(i.toString()),
                      child: Text(
                        i.toString(),
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ElevatedButton(
                    onPressed: _deleteDigit,
                    child: const Icon(Icons.backspace),
                  ),
                  ElevatedButton(
                    onPressed: () => _appendDigit('0'),
                    child: const Text('0', style: TextStyle(fontSize: 24)),
                  ),
                  ElevatedButton(
                    onPressed: _checkAnswer,
                    child: const Icon(Icons.check),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
