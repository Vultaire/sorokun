import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:go_router/go_router.dart';
import 'package:soroban_app/models/flash_source.dart';
import 'package:soroban_app/problem_generation/flash.dart';
import 'package:soroban_app/screens/components/keypad.dart';
import 'package:soroban_app/screens/components/pie_timer.dart';

import 'package:animations/animations.dart';

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
  int _currentPageIndex = 0;
  int _currentProblemIndex = 0;
  String _userInputted = '';
  Stopwatch _stopwatch = Stopwatch();
  late String _inputTime;
  bool _delayOver = false;

  void showInput() {
    _stopwatch.start();
    setState(() {
      _currentPageIndex = 1;
      _delayOver = true;
    });
  }

  void setInputAndShowResult(String userInputted) {
    _userInputted = userInputted;
    _stopwatch.stop();
    if (!widget.isSingleProblem) {
      final String trueInputTime = (_stopwatch.elapsedMilliseconds / 1000)
          .toStringAsFixed(2);
      _inputTime = double.parse(trueInputTime) > 15 ? '15.00' : trueInputTime;
    } else {
      _inputTime = (_stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2);
    }
    _stopwatch.reset();
    setState(() {
      _currentPageIndex = 2;
    });
  }

  void startNextProblem() {
    _currentProblemIndex++;
    setState(() {
      _currentPageIndex = 0;
      _delayOver = false;
    });
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
    final media = MediaQuery.of(context);
    final Size screenSize = media.size;
    final bool isPortrait = media.orientation == Orientation.portrait;
    bool _isCorrect = _userInputted == _allAnswers[_currentProblemIndex];

    return Scaffold(
      backgroundColor: Colors.black, // TODO: remove hardcode
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 300),
        reverse: _currentPageIndex == 0,
        transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
          return FadeThroughTransition(
            animation: primaryAnimation,
            secondaryAnimation: secondaryAnimation,
            fillColor: Colors.black, // Add this
            child: child,
          );
        },
        child: _buildPage(
          _currentPageIndex,
          screenSize,
          isPortrait,
          _isCorrect,
        ),
      ),
    );
  }

  Widget _buildPage(
    int index,
    Size screenSize,
    bool isPortrait,
    bool isCorrect,
  ) {
    switch (index) {
      case 0:
        return FlashProblem(
          key: ValueKey('problem_$_currentProblemIndex'),
          problemSet: _allProblems,
          schedule: _schedule,
          secondsPerProblem: widget.selectedLevel.secondsPerProblem,
          onEnd: showInput,
          currentProblemIndex: _currentProblemIndex,
        );
      case 1:
        return FlashProblemInput(
          key: ValueKey('input_$_currentProblemIndex'),
          showResult: setInputAndShowResult,
          allAnswers: _allAnswers,
          currentProblemIndex: _currentProblemIndex,
          screenSize: screenSize,
          isPortrait: isPortrait,
          showTimer: !widget.isSingleProblem,
          delayOver: _delayOver,
          isCorrect: isCorrect,
        );
      case 2:
        return FlashResult(
          key: ValueKey('result_$_currentProblemIndex'),
          onNextProblem: startNextProblem,
          screenSize: screenSize,
          isPortrait: isPortrait,
          allAnswers: _allAnswers,
          currentProblemIndex: _currentProblemIndex,
          userInputted: _userInputted,
          inputTime: _inputTime,
          isCorrect: isCorrect,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class FlashTextField extends StatelessWidget {
  const FlashTextField({super.key, required this.data});
  final TextFieldData data;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 155,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7),
        child: Text(
          data.formatted.isEmpty ? '答えを記入してください。' : data.formatted,
          style: Theme.of(
            context,
          ).textTheme.displayLarge?.copyWith(fontSize: 95),
        ),
      ),
    );
  }
}

class FlashProblemInput extends StatefulWidget {
  const FlashProblemInput({
    super.key,
    required this.allAnswers,
    required this.currentProblemIndex,
    required this.screenSize,
    required this.isPortrait,
    required this.showResult,
    required this.showTimer,
    required this.delayOver,
    required this.isCorrect,
  });
  final void Function(String) showResult;
  final List<String> allAnswers;
  final int currentProblemIndex;
  final Size screenSize;
  final bool isPortrait;
  final bool showTimer;
  final bool delayOver;
  final bool isCorrect;

  @override
  State<FlashProblemInput> createState() => _FlashProblemInputState();
}

class _FlashProblemInputState extends State<FlashProblemInput>
    with FlashKeypadMethods {
  @override
  TextFieldData data = TextFieldData();
  @override
  List<String> get allAnswers => widget.allAnswers;
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
    Widget landscapeAndPortrait() {
      return Flex(
        direction: widget.isPortrait ? Axis.vertical : Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            flex: widget.isPortrait ? 2 : 1,
            child: Column(
              children: [
                PieTimer(
                  duration: Duration(seconds: 15),
                  delayOver: widget.delayOver,
                  onComplete: () => widget.showResult(data.formatted),
                ),
                FittedBox(
                  fit: BoxFit.contain,
                  child: FlashTextField(data: data),
                ),
              ],
            ),
          ),
          if (!widget.isPortrait) const SizedBox(width: 50),
          Expanded(
            flex: widget.isPortrait ? 3 : 1,
            child: Keypad(
              onAppendDigit: appendDigit,
              onDeleteDigit: deleteDigit,
              onClearAll: clearAll,
              onSubmit: () {
                if (data.formatted.isNotEmpty) {
                  widget.showResult(data.formatted);
                  widget.isCorrect
                      ? SoLoud.instance.play(sound.correct)
                      : SoLoud.instance.play(sound.incorrect);
                } else {
                  SoLoud.instance.play(sound.invalid);
                }
              },
              levelType: KeypadType.flash,
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: widget.isPortrait
                ? widget.screenSize.width
                : widget.screenSize.width * 0.9,
            maxHeight: widget.isPortrait
                ? widget.screenSize.height * 0.65
                : widget.screenSize.height * 0.85,
          ),
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
            ),
            child: landscapeAndPortrait(),
          ),
        ),
      ),
    );
  }
}

class FlashResult extends StatefulWidget {
  const FlashResult({
    super.key,
    required this.screenSize,
    required this.isPortrait,
    required this.onNextProblem,
    required this.currentProblemIndex,
    required this.allAnswers,
    required this.userInputted,
    required this.inputTime,
    required this.isCorrect,
  });
  final VoidCallback onNextProblem;
  final Size screenSize;
  final bool isPortrait;
  final int currentProblemIndex;
  final List<String> allAnswers;
  final String userInputted;
  final String inputTime;
  final bool isCorrect;

  @override
  State<FlashResult> createState() => _FlashResultState();
}

class _FlashResultState extends State<FlashResult> {
  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: widget.isPortrait
                ? widget.screenSize.width * 0.9
                : widget.screenSize.width * 0.7,
            maxHeight: widget.isPortrait
                ? widget.screenSize.height * 0.65
                : widget.screenSize.height * 0.85,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: widget.isCorrect
                        ? colorScheme.primary
                        : colorScheme.tertiary,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      widget.isCorrect ? '正解' : '不正解',
                      style: widget.isCorrect
                          ? Theme.of(context).textTheme.displayLarge?.copyWith(
                              color: colorScheme.onPrimary,
                            )
                          : Theme.of(context).textTheme.displayLarge?.copyWith(
                              color: colorScheme.onTertiary,
                            ),
                    ),
                  ),
                ),
                Wrap(
                  alignment: .center,
                  children: [
                    Container(
                      padding: .symmetric(horizontal: 40, vertical: 10),
                      margin: .all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainer,
                        borderRadius: .all(.circular(16)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '答え',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          Text(
                            widget.allAnswers[widget.currentProblemIndex],
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: .symmetric(horizontal: 40, vertical: 10),
                      margin: .all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainer,
                        borderRadius: .all(.circular(16)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '回答タイム',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          Text(
                            '${widget.inputTime}秒',
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed:
                      widget.currentProblemIndex == widget.allAnswers.length - 1
                      ? () {}
                      : widget.onNextProblem,
                  child: Text(
                    widget.currentProblemIndex == widget.allAnswers.length - 1
                        ? '採点'
                        : '次の問題',
                  ),
                ),
              ],
            ),
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
              widget.onEnd();
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
