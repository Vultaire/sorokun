import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:soroban_app/problem_generation/generation_spec.dart';
import 'package:soroban_app/problem_generation/paper_source.dart';
import 'package:soroban_app/problem_generation/variable_digits.dart';

import 'components/keypad.dart';

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
                  final currentIndex = mitorizanState._currentIndex;
                  return Keypad(
                    controller: mitorizanState._controllers[currentIndex],
                    onCaretChanged: (newPos) {
                      setState(() {
                        mitorizanState._caretPositions[currentIndex] = newPos;
                      });
                    },
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

class MitorizanWindow extends StatefulWidget {
  const MitorizanWindow({super.key});

  @override
  State<MitorizanWindow> createState() => _MitorizanWindowState();
}

class _MitorizanWindowState extends State<MitorizanWindow> {
  PaperSources selectedLevel = PaperSources.dan; // default
  late final List<List<String>> currentProblemSet;
  late final List<TextEditingController> _controllers;
  late final List<double> _caretPositions;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeProblem(selectedLevel);
    _controllers = List.generate(
      currentProblemSet.length,
      (_) => TextEditingController(),
    );
    _caretPositions = List.generate(currentProblemSet.length, (_) => 0.0);
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeProblem(PaperSources source) {
    VariableDigitsProblemSet variableDigits = VariableDigitsProblemSet(
      spec: PaperSpec(source: source),
    );
    currentProblemSet = variableDigits.formattedProblems;
  }

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        reverse: true,
        onPageChanged: (index, reason) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      items: currentProblemSet.asMap().entries.map((entry) {
        final problemIndex = entry.key;
        final currentProblem = entry.value;
        return Builder(
          builder: (BuildContext context) {
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
                const Divider(color: Colors.black, thickness: 2, height: 10),
                CustomTextField(
                  controller: _controllers[problemIndex],
                  caretPos: _caretPositions[problemIndex],
                ),
              ],
            );
          },
        );
      }).toList(),
    );
  }
}

class CustomTextField extends StatefulWidget {
  CustomTextField({
    super.key,
    required this.controller,
    required this.caretPos,
  });

  final TextEditingController controller;
  final double caretPos;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Stack(
        alignment: AlignmentGeometry.xy(0, -0.5),
        children: [
          TextField(
            controller: widget.controller,
            readOnly: true,
            showCursor: false,
            style: TextStyle(fontSize: 20, fontFamily: 'abacusFont'),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "",
              counterText: "",
              contentPadding: EdgeInsets.symmetric(horizontal: 4),
              isDense: true,
            ),
          ),
          // Custom static cursor
          Positioned(
            left: widget.caretPos,
            top: 8,
            child: Container(
              width: 1.6,
              height: 30,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
