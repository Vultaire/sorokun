import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:go_router/go_router.dart';
import 'package:soroban_app/models/flash_source.dart';
import 'package:soroban_app/problem_generation/flash.dart';

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
  late final List<List<String>> allProblems;
  late final List<String> allAnswers;
  int _index = 0;

  final GlobalKey<FlashProblemState> _problemKey = GlobalKey();

  void showInput() => setState(() => _index = 1);

  void startNextProblem() {
    setState(() => _index = 0); // show problem screen
    _problemKey.currentState?.nextProblem();
  }

  @override
  void initState() {
    super.initState();
    fullProblemSet = FlashProblemSet(widget.selectedLevel);
    allProblems = fullProblemSet.formattedProblems;
    allAnswers = fullProblemSet.formattedAnswers;

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
      index: _index,
      children: [
        FlashProblem(
          key: _problemKey,
          problemSet: allProblems,
          schedule: _schedule,
          secondsPerProblem: widget.selectedLevel.secondsPerProblem,
          onEnd: showInput,
        ),
        FlashProblemInput(onNextProblem: startNextProblem),
      ],
    );
  }
}

class FlashProblemInput extends StatefulWidget {
  const FlashProblemInput({super.key, required this.onNextProblem});
  final VoidCallback onNextProblem;

  @override
  State<FlashProblemInput> createState() => _FlashProblemInputState();
}

class _FlashProblemInputState extends State<FlashProblemInput> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          width: 250,
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
              const Text(
                'Ready for next problem?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: widget.onNextProblem,
                child: const Text('Start'),
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
  });
  final double secondsPerProblem;
  final List<List<String>> problemSet;
  final List<Segment> schedule;
  final VoidCallback onEnd;

  @override
  State<FlashProblem> createState() => FlashProblemState();
}

class FlashProblemState extends State<FlashProblem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late List<String> currentProblem;

  int _currentNumberIndex = 0;
  bool _showNumber = false;
  int _currentProblemIndex = 0;

  late final AudioSource startingSine;
  late final AudioSource sineBeep;
  int _currentSegment = 0;

  @override
  void initState() {
    super.initState();

    currentProblem = widget.problemSet[_currentProblemIndex];

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
    _currentProblemIndex++;

    if (_currentProblemIndex >= widget.problemSet.length) {
      _currentProblemIndex = 0;
    }
    SoLoud.instance.play(startingSine);

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    setState(() {
      currentProblem = widget.problemSet[_currentProblemIndex];
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
