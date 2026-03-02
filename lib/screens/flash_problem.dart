import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:go_router/go_router.dart';
import 'package:soroban_app/models/level_definitions.dart';
import 'package:soroban_app/problem_generation/flash_set.dart';
import 'package:soroban_app/screens/components/keypad.dart';
import 'package:soroban_app/screens/components/navigation_button.dart';
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
  String _userInputted = '';
  bool _delayOver = false;
  bool _hasSubmitted = false;
  final Stopwatch _stopwatch = Stopwatch();
  int _currentPageIndex = 0;
  int _currentProblemIndex = 0;
  late List<List<String>> _allProblems;
  late List<String> _allAnswers;
  late String _inputTime;
  late final List<Segment> _schedule;

  void showInput() {
    _stopwatch.start();
    setState(() {
      _delayOver = true;
      _hasSubmitted = false;
    });
    Future.delayed(Duration(milliseconds: 500)).then((_) {
      if (mounted) {
        setState(() {
          _currentPageIndex = 1;
        });
      }
    });
  }

  void setInputAndShowResult(String userInputted) {
    if (_hasSubmitted) return;
    _hasSubmitted = true;
    _userInputted = userInputted;
    _stopwatch.stop();
    final elapsedSeconds = _stopwatch.elapsedMilliseconds / 1000;
    _inputTime = (!widget.isSingleProblem && elapsedSeconds > 15)
        ? '15.00'
        : elapsedSeconds.toStringAsFixed(2);
    setState(() {
      _currentPageIndex = 2;
    });
    _stopwatch.reset();
  }

  void startNextProblem() {
    _currentProblemIndex++;
    playProblem();
  }

  void playProblem() {
    setState(() {
      _currentPageIndex = 0;
      _delayOver = false;
      _hasSubmitted = false;
    });
  }

  void newProblem() {
    _initProblems();
    playProblem();
  }

  void _initProblems() {
    FlashProblemSet fullProblemSet = FlashProblemSet(widget.selectedLevel);
    _allProblems = fullProblemSet.formattedProblems;
    _allAnswers = fullProblemSet.formattedAnswers;
  }

  @override
  void initState() {
    super.initState();
    _initProblems();
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
    final bool isCorrect = _userInputted == _allAnswers[_currentProblemIndex];

    return FlashAndAloudProblemData<String>(
      screenSize: screenSize,
      isPortrait: isPortrait,
      currentProblemIndex: _currentProblemIndex,
      allAnswers: _allAnswers,
      allProblems: _allProblems,
      child: Scaffold(
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
          child: _buildPage(_currentPageIndex, isCorrect),
        ),
      ),
    );
  }

  Widget _buildPage(int index, bool isCorrect) {
    switch (index) {
      case 0:
        return FlashProblem(
          key: ValueKey('problem_$_currentProblemIndex'),
          schedule: _schedule,
          secondsPerProblem: widget.selectedLevel.secondsPerProblem,
          onEnd: showInput,
        );
      case 1:
        return FlashAndAloudProblemInput<String>(
          key: ValueKey('input_$_currentProblemIndex'),
          showResult: setInputAndShowResult,
          showTimer: !widget.isSingleProblem,
          delayOver: _delayOver,
          duration: 14500,
        );
      case 2:
        return FlashAndAloudResult<String>(
          key: ValueKey('result_$_currentProblemIndex'),
          onNextProblem: startNextProblem,
          onRepeatProblem: playProblem,
          onNewProblem: newProblem,
          inputTime: _inputTime,
          isCorrect: isCorrect,
          isSingleProblem: widget.isSingleProblem,
          answer: _allAnswers[_currentProblemIndex],
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class FlashAndAloudProblemData<T> extends InheritedWidget {
  const FlashAndAloudProblemData({
    super.key,
    required this.screenSize,
    required this.isPortrait,
    required this.currentProblemIndex,
    required this.allAnswers,
    required this.allProblems,
    required super.child,
  });

  final Size screenSize;
  final bool isPortrait;
  final int currentProblemIndex;
  final List<String> allAnswers;
  final List<List<T>> allProblems;

  static FlashAndAloudProblemData<T> of<T>(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<FlashAndAloudProblemData<T>>()!;
  }

  @override
  bool updateShouldNotify(FlashAndAloudProblemData<T> old) =>
      screenSize != old.screenSize ||
      isPortrait != old.isPortrait ||
      currentProblemIndex != old.currentProblemIndex ||
      allAnswers != old.allAnswers;
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

class FlashAndAloudProblemInput<T> extends StatefulWidget {
  const FlashAndAloudProblemInput({
    super.key,
    required this.showResult,
    required this.showTimer,
    required this.delayOver,
    required this.duration,
  });
  final void Function(String) showResult;
  final bool showTimer;
  final bool delayOver;
  final int duration;

  @override
  State<FlashAndAloudProblemInput<T>> createState() =>
      _FlashAndAloudProblemInputState<T>();
}

class _FlashAndAloudProblemInputState<T>
    extends State<FlashAndAloudProblemInput<T>>
    with FlashKeypadMethods {
  FlashAndAloudProblemData<T> get _data =>
      FlashAndAloudProblemData.of<T>(context);
  @override
  TextFieldData textData = TextFieldData();
  @override
  List<String> get allAnswers => _data.allAnswers;
  late final KeypadSounds _sound;
  @override
  KeypadSounds get sound => _sound;
  @override
  int get currentIndex => _data.currentProblemIndex;

  @override
  void initState() {
    super.initState();

    _sound = KeypadSounds();
    _sound.init();
  }

  Widget _landscapeAndPortrait() {
    return Flex(
      direction: _data.isPortrait ? Axis.vertical : Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          flex: _data.isPortrait ? 2 : 1,
          child: Stack(
            alignment: .center,
            children: [
              if (widget.showTimer)
                Opacity(
                  opacity: 0.4,
                  child: SizedBox(
                    width: 400,
                    height: 400,
                    child: PieTimer(
                      duration: Duration(milliseconds: widget.duration),
                      delayOver: widget.delayOver,
                      onComplete: () => widget.showResult(textData.formatted),
                    ),
                  ),
                ),
              FittedBox(
                fit: BoxFit.contain,
                child: FlashTextField(data: textData),
              ),
            ],
          ),
        ),
        if (!_data.isPortrait) const SizedBox(width: 50),
        Expanded(
          flex: _data.isPortrait ? 3 : 1,
          child: Keypad(
            onAppendDigit: appendDigit,
            onDeleteDigit: deleteDigit,
            onClearAll: clearAll,
            onSubmit: () {
              if (textData.formatted.isNotEmpty) {
                final isCorrect =
                    textData.formatted ==
                    _data.allAnswers[_data.currentProblemIndex];

                widget.showResult(textData.formatted);

                isCorrect
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: _data.isPortrait
                ? _data.screenSize.width
                : _data.screenSize.width * 0.9,
            maxHeight: _data.isPortrait
                ? _data.screenSize.height * 0.65
                : _data.screenSize.height * 0.85,
          ),
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
            ),
            child: _landscapeAndPortrait(),
          ),
        ),
      ),
    );
  }
}

class FlashAndAloudResult<T> extends StatefulWidget {
  const FlashAndAloudResult({
    super.key,
    required this.onNextProblem,
    required this.inputTime,
    required this.isCorrect,
    required this.isSingleProblem,
    required this.onRepeatProblem,
    required this.onNewProblem,
    required this.answer, //must be passed or next answer shows before page transition completes
  });
  final VoidCallback onNextProblem;
  final VoidCallback onRepeatProblem;
  final VoidCallback onNewProblem;
  final String inputTime;
  final bool isCorrect;
  final bool isSingleProblem;
  final String answer;

  @override
  State<FlashAndAloudResult<T>> createState() => _FlashAndAloudResultState<T>();
}

class _FlashAndAloudResultState<T> extends State<FlashAndAloudResult<T>> {
  FlashAndAloudProblemData<T> get _data =>
      FlashAndAloudProblemData.of<T>(context);
  Widget freeOrSetButtons(bool isSingleProblem) {
    if (isSingleProblem) {
      return Row(
        mainAxisAlignment: .center,
        children: [
          NavigationButton(
            onPressed: () => context.go('/flash-menu'),
            label: Text('設定画面に戻る'),
          ),
          NavigationButton(
            onPressed: widget.onRepeatProblem,
            label: Text('もう一回'),
          ),
          NavigationButton(onPressed: widget.onNewProblem, label: Text('次へ')),
        ],
      );
    } else {
      return ElevatedButton(
        onPressed: _data.currentProblemIndex == _data.allAnswers.length - 1
            ? () {}
            : widget.onNextProblem,
        child: Text(
          _data.currentProblemIndex == _data.allAnswers.length - 1
              ? '採点'
              : '次の問題',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: _data.isPortrait
                ? _data.screenSize.width * 0.9
                : _data.screenSize.width * 0.7,
            maxHeight: _data.isPortrait
                ? _data.screenSize.height * 0.65
                : _data.screenSize.height * 0.85,
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
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: widget.isCorrect
                            ? colorScheme.onPrimary
                            : colorScheme.onTertiary,
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
                            widget.answer,
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
                freeOrSetButtons(widget.isSingleProblem),
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
    required this.secondsPerProblem,
    required this.schedule,
    required this.onEnd,
  });
  final double secondsPerProblem;
  final List<Segment> schedule;
  final VoidCallback onEnd;

  @override
  State<FlashProblem> createState() => FlashProblemState();
}

class FlashProblemState extends State<FlashProblem>
    with SingleTickerProviderStateMixin {
  FlashAndAloudProblemData<String> get _data =>
      FlashAndAloudProblemData.of<String>(context);
  late final AnimationController _controller;
  List<String> get currentProblem =>
      _data.allProblems[_data.currentProblemIndex];

  int _currentNumberIndex = 0;
  bool _showNumber = false;
  int _currentSegment = 0;

  late final AudioSource startingSine;
  late final AudioSource sineBeep;

  @override
  void initState() {
    super.initState();

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
