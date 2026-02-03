import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:go_router/go_router.dart';
import 'package:soroban_app/models/flash_source.dart';
import 'package:soroban_app/models/level_definitions.dart';
import 'package:soroban_app/problem_generation/flash.dart';
import 'package:soroban_app/screens/components/keypad.dart';

class FlashProblemScreen extends StatefulWidget {
  const FlashProblemScreen({
    super.key,
    required this.isSingleProblem,
    required this.selectedLevel,
  });
  final bool isSingleProblem;
  final FlashSpec selectedLevel;

  @override
  State<FlashProblemScreen> createState() => _FlashProblemScreenState();
}

class _FlashProblemScreenState extends State<FlashProblemScreen> {
  late final List<Segment> _schedule;
  late final FlashProblemSet fullProblemSet;
  late final List<List<String>> _allProblems;
  late final List<String> _allAnswers;
  int _indexInIndexedStack = 0;
  int _currentProblemIndex = 0;

  final GlobalKey<FlashProblemState> _problemKey = GlobalKey();

  void showInput() => setState(() {
    _indexInIndexedStack = 1;
  });

  void startNextProblem() {
    setState(() => _indexInIndexedStack = 0);
    _currentProblemIndex++;
    _problemKey.currentState?.nextProblem();
  }

  @override
  void initState() {
    super.initState();
    fullProblemSet = FlashProblemSet(widget.selectedLevel);
    _allProblems = fullProblemSet.formattedProblems;
    _allAnswers = fullProblemSet.formattedAnswers;

    final kuchi = widget.selectedLevel.kuchi;
    final secondsPerProblem = widget.selectedLevel.secondsPerProblem;
    final hideDuration = secondsPerProblem / (2.5 * kuchi - 1);
    final showDuration = 1.5 * hideDuration;

    double t = 0;
    _schedule = [];
    for (int i = 0; i < kuchi; i++) {
      _schedule.add(Segment(t, t + showDuration, true, i));
      t += showDuration;

      if (i < kuchi - 1) {
        _schedule.add(Segment(t, t + hideDuration, false, i));
        t += hideDuration;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: _indexInIndexedStack,
      children: [
        FlashProblem(
          key: _problemKey,
          problemSet: _allProblems,
          schedule: _schedule,
          secondsPerProblem: widget.selectedLevel.secondsPerProblem,
          onEnd: showInput,
          currentProblemIndex: _currentProblemIndex,
        ),
        FlashProblemInput(
          onNextProblem: startNextProblem,
          allAnswers: _allAnswers,
          currentProblemIndex: _currentProblemIndex,
        ),
      ],
    );
  }
}

class FlashTextField extends StatelessWidget {
  const FlashTextField({super.key, required this.data});
  final TextFieldData data;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 10),
        child: Text(
          data.formatted,
          style: const TextStyle(fontSize: 26, fontFamily: 'abacusFontSpaced'),
        ),
      ),
    );
  }
}

class FlashProblemInput extends StatefulWidget {
  const FlashProblemInput({
    super.key,
    required this.onNextProblem,
    required this.allAnswers,
    required this.currentProblemIndex,
  });
  final VoidCallback onNextProblem;
  final List<String> allAnswers;
  final int currentProblemIndex;

  @override
  State<FlashProblemInput> createState() => _FlashProblemInputState();
}

class _FlashProblemInputState extends State<FlashProblemInput>
    with FlashKeypadMethods {
  @override
  TextFieldData data = TextFieldData();
  @override
  List<String> get allAnswers => widget.allAnswers;
  @override
  // TODO: implement onComplete
  VoidCallback get onComplete => throw UnimplementedError();
  late final KeypadSounds _sound;
  @override
  KeypadSounds get sound => _sound;
  @override
  int get currentIndex => widget.currentProblemIndex;

  @override
  void initState() {
    super.initState();

    _sound = KeypadSounds();
    _sound.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          width: 550,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(flex: 2, child: FlashTextField(data: data)),
              Expanded(
                flex: 5,
                child: Keypad(
                  onAppendDigit: appendDigit,
                  onDeleteDigit: deleteDigit,
                  onClearAll: clearAll,
                  onSubmit: submit,
                  levelType: DivMultLevel.dk4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FlashProblem extends StatefulWidget {
  const FlashProblem({
    super.key,
    required this.problemSet,
    required this.secondsPerProblem,
    required this.schedule,
    required this.onEnd,
    required this.currentProblemIndex,
  });
  final double secondsPerProblem;
  final List<List<String>> problemSet;
  final List<Segment> schedule;
  final VoidCallback onEnd;
  final int currentProblemIndex;

  @override
  State<FlashProblem> createState() => FlashProblemState();
}

class FlashProblemState extends State<FlashProblem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late List<String> currentProblem;

  int _currentNumberIndex = 0;
  bool _showNumber = false;

  late final AudioSource startingSine;
  late final AudioSource sineBeep;
  int _currentSegment = 0;

  @override
  void initState() {
    super.initState();

    currentProblem = widget.problemSet[widget.currentProblemIndex];

    // Animation controller
    _controller =
        AnimationController(
            vsync: this,
            duration: Duration(
              milliseconds: (widget.secondsPerProblem * 1000).round(),
            ),
          )
          ..addListener(_onTick)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              setState(() {
                _showNumber = false;
              });
              Future.delayed(const Duration(seconds: 1), () {
                if (mounted) {
                  widget.onEnd();
                }
              });
            }
          });

    _initSoundsAndStart();
  }

  Future<void> _initSoundsAndStart() async {
    startingSine = await SoLoud.instance.loadAsset('assets/starting-sine.wav');
    sineBeep = await SoLoud.instance.loadAsset('assets/sine-beep.wav');

    if (!mounted) return;

    SoLoud.instance.play(startingSine);

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    _controller.forward();
  }

  void _onTick() {
    final t = _controller.value * widget.secondsPerProblem;

    while (_currentSegment < widget.schedule.length - 1 &&
        t >= widget.schedule[_currentSegment].end) {
      _currentSegment++;
    }

    final seg = widget.schedule[_currentSegment];

    if (mounted &&
        (_currentNumberIndex != seg.index || _showNumber != seg.showing)) {
      setState(() {
        _currentNumberIndex = seg.index;
        _showNumber = seg.showing;
      });

      if (_showNumber) {
        SoLoud.instance.play(sineBeep);
      }
    }
  }

  void nextProblem() async {
    SoLoud.instance.play(startingSine);

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    setState(() {
      currentProblem = widget.problemSet[widget.currentProblemIndex];
      _currentSegment = 0;
      _currentNumberIndex = 0;
      _showNumber = false;
    });

    _controller.reset();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: FittedBox(
          fit: .contain,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: _showNumber
                ? Text(
                    currentProblem[_currentNumberIndex],
                    style: const TextStyle(
                      fontFamily: 'abacusFont',
                      fontSize: 200,
                      color: Colors.lightGreenAccent,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

class Segment {
  final double start; // seconds
  final double end; // seconds
  final bool showing;
  final int index;
  Segment(this.start, this.end, this.showing, this.index);
}
