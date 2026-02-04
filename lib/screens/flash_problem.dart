import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:go_router/go_router.dart';
import 'package:soroban_app/models/flash_source.dart';
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
  final PageController _pageController = PageController(initialPage: 0);
  int _currentProblemIndex = 0;
  String _userInputted = '';

  final GlobalKey<FlashProblemState> _problemKey = GlobalKey();

  void showInput() {
    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void setInputAndShowResult(String userInputted) {
    _userInputted = userInputted;
    _pageController.animateToPage(
      2,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void startNextProblem() {
    _currentProblemIndex++;
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
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
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final Size screenSize = media.size;
    final bool isPortrait = media.orientation == Orientation.portrait;

    return PageView.builder(
      controller: _pageController,
      itemBuilder: (context, index) {
        switch (index) {
          case 0:
            return FlashProblem(
              key: _problemKey,
              problemSet: _allProblems,
              schedule: _schedule,
              secondsPerProblem: widget.selectedLevel.secondsPerProblem,
              onEnd: showInput,
              currentProblemIndex: _currentProblemIndex,
            );

          case 1:
            return FlashProblemInput(
              showResult: setInputAndShowResult,
              allAnswers: _allAnswers,
              currentProblemIndex: _currentProblemIndex,
              screenSize: screenSize,
              isPortrait: isPortrait,
            );

          case 2:
            return FlashResult(
              onNextProblem: startNextProblem,
              screenSize: screenSize,
              isPortrait: isPortrait,
              allAnswers: _allAnswers,
              currentProblemIndex: _currentProblemIndex,
              userInputted: _userInputted,
            );

          default:
            return const SizedBox.shrink();
        }
      },
    );
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
          data.formatted,
          style: TextStyle(
            fontSize: 95,
            fontFamily: 'bizUDPGR',
            color: Theme.of(context).primaryColor,
          ),
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
  });
  final void Function(String) showResult;
  final List<String> allAnswers;
  final int currentProblemIndex;
  final Size screenSize;
  final bool isPortrait;

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
      if (widget.isPortrait) {
        return Column(
          mainAxisAlignment: .end,
          children: [
            Expanded(
              flex: 2,
              child: Center(
                child: FittedBox(
                  fit: .contain,
                  child: FlashTextField(data: data),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Keypad(
                onAppendDigit: appendDigit,
                onDeleteDigit: deleteDigit,
                onClearAll: clearAll,
                onSubmit: () {
                  widget.showResult(data.formatted);
                },
                levelType: KeypadType.flash,
              ),
            ),
          ],
        );
      } else {
        return Row(
          mainAxisAlignment: .end,
          children: [
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: .contain,
                  child: FlashTextField(data: data),
                ),
              ),
            ),
            SizedBox(width: 50),
            Expanded(
              child: Keypad(
                onAppendDigit: appendDigit,
                onDeleteDigit: deleteDigit,
                onClearAll: clearAll,
                onSubmit: () {
                  widget.showResult(data.formatted);
                },
                levelType: KeypadType.flash,
              ),
            ),
          ],
        );
      }
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
  });
  final VoidCallback onNextProblem;
  final Size screenSize;
  final bool isPortrait;
  final int currentProblemIndex;
  final List<String> allAnswers;
  final String userInputted;

  @override
  State<FlashResult> createState() => _FlashResultState();
}

class _FlashResultState extends State<FlashResult> {
  @override
  Widget build(BuildContext context) {
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Container(
                  child: Text(
                    widget.userInputted ==
                            widget.allAnswers[widget.currentProblemIndex]
                        ? '正解'
                        : '不正解',
                  ),
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
