// Modified by Vultaire on 2026-11-01.
// Fork: https://github.com/Vultaire/sorokun
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:go_router/go_router.dart';
import 'package:soroban_app/l10n/generated/app_localizations.dart';
import 'package:soroban_app/models/level_definitions.dart';
import 'package:soroban_app/problem_generation/flash_set.dart';
import 'package:soroban_app/screens/components/exit_button.dart';
import 'package:soroban_app/screens/components/keypad.dart';
import 'package:soroban_app/screens/components/navigation_button.dart';
import 'package:soroban_app/screens/components/pie_timer.dart';

import 'package:animations/animations.dart';

class FlashProblemScreen extends StatefulWidget {
  const FlashProblemScreen({
    super.key,
    required this.isSingleProblem,
    required this.selectedLevel,
    this.examDisplayString,
    this.isHandsFree = false,
    this.handsFreeThinkTimeSeconds = 5,
    this.handsFreeAnswerDisplaySeconds = 5,
  });
  final bool isSingleProblem;
  final FlashSpec selectedLevel;
  final String? examDisplayString;
  final bool isHandsFree;
  final int handsFreeThinkTimeSeconds;
  final int handsFreeAnswerDisplaySeconds;
  @override
  State<FlashProblemScreen> createState() => _FlashProblemScreenState();
}

class _FlashProblemScreenState extends State<FlashProblemScreen> {
  String _inputTime = '';
  bool _delayOver = false;
  bool _hasSubmitted = false;
  int _currentPageIndex = 0;
  int _currentProblemIndex = 0;
  late List<List<String>> _allProblems;
  late List<String> _allAnswers;
  late List<TextFieldData> _textFieldDataList;
  final Stopwatch _stopwatch = Stopwatch();
  final Stopwatch _handsFreeStopwatch = Stopwatch();
  final Stopwatch _handsFreePhaseStopwatch = Stopwatch();
  Timer? _handsFreePhaseTimer;
  Timer? _handsFreeTicker;
  int _handsFreeSecondsRemaining = 0;
  int _handsFreeCompletedQuestions = 0;
  late List<Segment> _schedule;

  void showInput() {
    if (widget.isHandsFree) {
      _showHandsFreeAnswerPrompt();
      return;
    }

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

  void setInputAndShowResult() {
    if (_hasSubmitted) return;
    _hasSubmitted = true;
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
    _cancelHandsFreeTimers();
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

  void _startHandsFreeSession() {
    if (!_handsFreeStopwatch.isRunning) {
      _handsFreeStopwatch.start();
    }
  }

  void _cancelHandsFreeTimers() {
    _handsFreePhaseTimer?.cancel();
    _handsFreePhaseTimer = null;
    _handsFreeTicker?.cancel();
    _handsFreeTicker = null;
    _handsFreePhaseStopwatch.stop();
    _handsFreePhaseStopwatch.reset();
  }

  void _startHandsFreeCountdown(int seconds, VoidCallback onComplete) {
    _cancelHandsFreeTimers();
    final duration = Duration(seconds: seconds);
    _handsFreePhaseStopwatch.start();
    if (mounted) {
      setState(() => _handsFreeSecondsRemaining = seconds);
    }

    _handsFreePhaseTimer = Timer(duration, () {
      _cancelHandsFreeTimers();
      if (mounted) onComplete();
    });
    _handsFreeTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final remaining = duration - _handsFreePhaseStopwatch.elapsed;
      final secondsRemaining = remaining.isNegative
          ? 0
          : (remaining.inMilliseconds / 1000).ceil();
      setState(() => _handsFreeSecondsRemaining = secondsRemaining);
    });
  }

  void _showHandsFreeAnswerPrompt() {
    setState(() => _currentPageIndex = 1);
    _startHandsFreeCountdown(
      widget.handsFreeThinkTimeSeconds,
      _revealHandsFreeAnswer,
    );
  }

  void _revealHandsFreeAnswer() {
    setState(() {
      _currentPageIndex = 2;
      _handsFreeCompletedQuestions++;
    });
    _startHandsFreeCountdown(widget.handsFreeAnswerDisplaySeconds, newProblem);
  }

  void _stopHandsFreeSession() {
    _cancelHandsFreeTimers();
    _handsFreeStopwatch.stop();
  }

  void _exitHandsFreeSession() {
    _stopHandsFreeSession();
    if (mounted) context.pop();
  }

  void showResultPage() {
    context.pushReplacement(
      '/paper-results',
      extra: {
        'selectedLevel': widget.selectedLevel,
        'isExam': true,
        'allProblems': _allProblems,
        'allAnswers': _allAnswers,
        'textFieldDataList': _textFieldDataList,
        'examDisplayString': widget.examDisplayString,
      },
    );
  }

  void _initProblems() {
    FlashProblemSet fullProblemSet = FlashProblemSet(widget.selectedLevel);
    _allProblems = fullProblemSet.formattedProblems;
    _allAnswers = fullProblemSet.formattedAnswers;
    _textFieldDataList = List.generate(
      _allAnswers.length,
      (_) => TextFieldData(),
    );
  }

  @override
  void dispose() {
    _cancelHandsFreeTimers();
    _handsFreeStopwatch.stop();
    super.dispose();
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
    final Size screenSize = MediaQuery.sizeOf(context);
    final bool isPortrait =
        MediaQuery.orientationOf(context) == Orientation.portrait;

    return FlashProblemData<String>(
      screenSize: screenSize,
      isPortrait: isPortrait,
      currentProblemIndex: _currentProblemIndex,
      allAnswers: _allAnswers,
      allProblems: _allProblems,
      textFieldDataList: _textFieldDataList,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: PageTransitionSwitcher(
            duration: const Duration(milliseconds: 300),
            reverse: _currentPageIndex == 0,
            transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
              return FadeThroughTransition(
                animation: primaryAnimation,
                secondaryAnimation: secondaryAnimation,
                fillColor: Colors.black,
                child: child,
              );
            },
            child: Stack(
              key: ValueKey('${_currentProblemIndex}_$_currentPageIndex'),
              children: [
                _buildPage(_currentPageIndex),
                if (_currentPageIndex != 0)
                  ExitButton(
                    onShowResults: showResultPage,
                    isSingleProblem: widget.isSingleProblem,
                    onExit: widget.isHandsFree ? _stopHandsFreeSession : null,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return FlashProblem(
          key: ValueKey('problem_$_currentProblemIndex'),
          schedule: _schedule,
          secondsPerProblem: widget.selectedLevel.secondsPerProblem,
          onEnd: showInput,
          onStart: widget.isHandsFree ? _startHandsFreeSession : null,
        );
      case 1:
        if (widget.isHandsFree) {
          return FlashHandsFreePrompt(
            key: ValueKey('hands_free_prompt_$_currentProblemIndex'),
            secondsRemaining: _handsFreeSecondsRemaining,
            totalSeconds: widget.handsFreeThinkTimeSeconds,
          );
        }
        return FlashProblemInput<String>(
          key: ValueKey('input_$_currentProblemIndex'),
          showAnswer: setInputAndShowResult,
          showTimer: !widget.isSingleProblem,
          delayOver: _delayOver,
          duration: 14500,
          maxDigits: 7,
        );
      case 2:
        if (widget.isHandsFree) {
          return FlashHandsFreeResult(
            key: ValueKey('hands_free_result_$_currentProblemIndex'),
            answer: _allAnswers[_currentProblemIndex],
            completedQuestions: _handsFreeCompletedQuestions,
            elapsed: _handsFreeStopwatch.elapsed,
            secondsRemaining: _handsFreeSecondsRemaining,
            onRepeatProblem: playProblem,
            onNextProblem: newProblem,
            onStop: _exitHandsFreeSession,
          );
        }
        return FlashResult<String>(
          key: ValueKey('result_$_currentProblemIndex'),
          onNextProblem: startNextProblem,
          onRepeatProblem: playProblem,
          onNewProblem: newProblem,
          onShowResults: showResultPage,
          inputTime: _inputTime,
          isSingleProblem: widget.isSingleProblem,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class FlashProblemData<T> extends InheritedWidget {
  const FlashProblemData({
    super.key,
    required this.screenSize,
    required this.isPortrait,
    required this.currentProblemIndex,
    required this.allAnswers,
    required this.allProblems,
    required this.textFieldDataList,
    required super.child,
  });

  final Size screenSize;
  final bool isPortrait;
  final int currentProblemIndex;
  final List<String> allAnswers;
  final List<List<T>> allProblems;
  final List<TextFieldData> textFieldDataList;

  List<bool?> get answerResults => List.generate(
    allAnswers.length,
    (i) => i <= currentProblemIndex
        ? textFieldDataList[i].formatted == allAnswers[i]
        : null,
  );

  bool get isCorrect =>
      textFieldDataList[currentProblemIndex].formatted ==
      allAnswers[currentProblemIndex];

  static FlashProblemData<T> of<T>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<FlashProblemData<T>>()!;
  }

  @override
  bool updateShouldNotify(FlashProblemData<T> old) =>
      screenSize != old.screenSize ||
      isPortrait != old.isPortrait ||
      currentProblemIndex != old.currentProblemIndex ||
      allAnswers != old.allAnswers;
}

class FlashTextField extends StatelessWidget {
  FlashTextField({super.key, required this.data});
  final TextFieldData data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      height: 155,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: Text(
            data.formatted.isEmpty ? l10n.flashAnswerPrompt : data.formatted,
            style: data.formatted.isEmpty
                ? Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primaryFixed,
                  )
                : TextStyle(
                    fontFamily: 'abacusFont',
                    fontSize: 80,
                    color: Theme.of(context).colorScheme.primaryFixed,
                  ),
          ),
        ),
      ),
    );
  }
}

class FlashProblemInput<T> extends StatefulWidget {
  const FlashProblemInput({
    super.key,
    required this.showAnswer,
    required this.showTimer,
    required this.delayOver,
    required this.duration,
    required this.maxDigits,
  });
  final VoidCallback showAnswer;
  final bool showTimer;
  final bool delayOver;
  final int duration;
  final int maxDigits;

  @override
  State<FlashProblemInput<T>> createState() => _FlashProblemInputState<T>();
}

class _FlashProblemInputState<T> extends State<FlashProblemInput<T>>
    with FlashKeypadMethods {
  FlashProblemData<T> get _data => FlashProblemData.of<T>(context);
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
  int get maxDigits => widget.maxDigits;

  String get _input => textData.formatted;

  void _submit() {
    if (_input.isEmpty) {
      SoLoud.instance.play(sound.invalid);
      return;
    }

    _data.textFieldDataList[_data.currentProblemIndex] = textData;
    widget.showAnswer();
    SoLoud.instance.play(_data.isCorrect ? sound.correct : sound.incorrect);
  }

  @override
  void initState() {
    super.initState();

    _sound = KeypadSounds();
    _sound.init();
  }

  @override
  Widget build(BuildContext context) {
    return KeypadKeyboardListener(
      keypadType: KeypadType.flash,
      onAppendDigit: appendDigit,
      onDeleteDigit: deleteDigit,
      onClearAll: clearAll,
      onSubmit: _submit,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox.expand(
          child: Flex(
            direction: _data.isPortrait ? Axis.vertical : Axis.horizontal,
            children: [
              Expanded(
                flex: 8,
                child: Column(
                  mainAxisAlignment: .center,
                  crossAxisAlignment: .center,
                  children: [
                    if (widget.showTimer) SizedBox(height: 50),
                    SizedBox(
                      height: 150,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: FlashTextField(data: textData),
                      ),
                    ),
                    if (widget.showTimer)
                      Opacity(
                        opacity: 0.4,
                        child: SizedBox(
                          width: 400,
                          height: 50,
                          child: BarTimer(
                            duration: Duration(milliseconds: widget.duration),
                            delayOver: widget.delayOver,
                            onComplete: () {
                              _data.textFieldDataList[_data
                                      .currentProblemIndex] =
                                  textData;
                              widget.showAnswer();
                              SoLoud.instance.play(
                                _data.isCorrect
                                    ? sound.correct
                                    : sound.incorrect,
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                flex: 5,
                child: Keypad(
                  onAppendDigit: appendDigit,
                  onDeleteDigit: deleteDigit,
                  onClearAll: clearAll,
                  onSubmit: _submit,
                  levelType: KeypadType.flash,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FlashResult<T> extends StatefulWidget {
  const FlashResult({
    super.key,
    required this.onNextProblem,
    required this.inputTime,
    required this.isSingleProblem,
    required this.onRepeatProblem,
    required this.onNewProblem,
    required this.onShowResults,
  });
  final VoidCallback onNextProblem;
  final VoidCallback onRepeatProblem;
  final VoidCallback onNewProblem;
  final VoidCallback onShowResults;
  final String inputTime;
  final bool isSingleProblem;

  @override
  State<FlashResult<T>> createState() => _FlashResultState<T>();
}

class _FlashResultState<T> extends State<FlashResult<T>> {
  FlashProblemData<T> get _data => FlashProblemData.of<T>(context);
  int? _frozenIndex;
  List<bool?>? _frozenAnswerResults;
  String? _frozenAnswer;
  bool? _frozenIsCorrect;

  Widget freeOrLevelButtons(bool isSingleProblem) {
    final l10n = AppLocalizations.of(context);
    if (isSingleProblem) {
      return Wrap(
        alignment: .center,
        spacing: 20,
        runSpacing: 12,
        children: [
          SizedBox(
            width: 160,
            child: NavigationButton(
              color: Theme.of(context).colorScheme.primaryContainer,
              onPressed: widget.onRepeatProblem,
              child: Center(
                child: iconHelper(
                  context,
                  Icons.replay_rounded,
                  l10n.repeatProblem,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 160,
            child: NavigationButton(
              color: Theme.of(context).colorScheme.primaryContainer,
              onPressed: widget.onNewProblem,
              child: Center(
                child: iconHelper(
                  context,
                  Icons.arrow_forward_ios_rounded,
                  l10n.nextProblem,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return SizedBox(
        width: 180,
        child: NavigationButton(
          onPressed: _data.currentProblemIndex == _data.allAnswers.length - 1
              ? widget.onShowResults
              : widget.onNextProblem,
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Center(
            child: iconHelper(
              context,
              _data.currentProblemIndex == _data.allAnswers.length - 1
                  ? Icons.grade
                  : Icons.arrow_forward,
              _data.currentProblemIndex == _data.allAnswers.length - 1
                  ? l10n.grade
                  : l10n.nextProblem,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    _frozenIndex ??= _data.currentProblemIndex;
    _frozenAnswerResults ??= _data.answerResults;
    _frozenAnswer ??= _data.allAnswers[_data.currentProblemIndex];
    _frozenIsCorrect ??= _data.isCorrect;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: .all(18),
        child: SizedBox.expand(
          child: FittedBox(
            fit: .scaleDown,
            child: SizedBox(
              width: _data.isPortrait
                  ? _data.screenSize.width
                  : _data.screenSize.width * 0.7,
              child: Container(
                padding: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  mainAxisSize: .min,
                  spacing: 20,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _frozenIsCorrect!
                            ? colorScheme.primary
                            : colorScheme.tertiary,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _frozenIsCorrect! ? l10n.correct : l10n.incorrect,
                          style: Theme.of(context).textTheme.displayLarge
                              ?.copyWith(
                                color: _frozenIsCorrect!
                                    ? colorScheme.onPrimary
                                    : colorScheme.onTertiary,
                              ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Wrap(
                        alignment: .center,
                        spacing: 20,
                        runSpacing: 20,
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(minWidth: 220),
                            child: Material(
                              elevation: 4,
                              color: colorScheme.surfaceContainerHigh,
                              borderRadius: .all(.circular(16)),
                              child: Padding(
                                padding: const .all(10),
                                child: Column(
                                  children: [
                                    Text(
                                      l10n.answer,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.headlineMedium,
                                    ),
                                    FittedBox(
                                      fit: .scaleDown,
                                      child: Text(
                                        _frozenAnswer!,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.displayMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          ConstrainedBox(
                            constraints: const BoxConstraints(minWidth: 220),
                            child: Material(
                              elevation: 4,
                              color: colorScheme.surfaceContainerHigh,
                              borderRadius: .all(.circular(16)),
                              child: Padding(
                                padding: const .all(10),
                                child: Column(
                                  children: [
                                    Text(
                                      l10n.answerTime,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.headlineMedium,
                                    ),
                                    FittedBox(
                                      fit: .scaleDown,
                                      child: Text(
                                        l10n.answerTimeValue(widget.inputTime),
                                        style: Theme.of(
                                          context,
                                        ).textTheme.displayMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (!widget.isSingleProblem)
                            Material(
                              elevation: 4,
                              color: colorScheme.surfaceContainerHigh,
                              borderRadius: .all(.circular(16)),
                              child: Padding(
                                padding: const .symmetric(
                                  horizontal: 40,
                                  vertical: 10,
                                ),
                                child: AnswerTracker(
                                  answerResults: _frozenAnswerResults!,
                                  currentIndex: _frozenIndex!,
                                  isPortrait: _data.isPortrait,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    freeOrLevelButtons(widget.isSingleProblem),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FlashHandsFreePrompt extends StatelessWidget {
  const FlashHandsFreePrompt({
    super.key,
    required this.secondsRemaining,
    required this.totalSeconds,
  });

  final int secondsRemaining;
  final int totalSeconds;

  @override
  Widget build(BuildContext context) {
    final data = FlashProblemData.of<String>(context);
    final l10n = AppLocalizations.of(context);
    final progress = (1 - secondsRemaining / totalSeconds).clamp(0.0, 1.0);
    final width = data.isPortrait
        ? data.screenSize.width * 0.85
        : data.screenSize.width * 0.65;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SizedBox(
          width: width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.handsFreeAnswerPrompt,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Colors.lightGreenAccent,
                ),
              ),
              const SizedBox(height: 32),
              LinearProgressIndicator(value: progress, minHeight: 8),
              const SizedBox(height: 16),
              Text(
                l10n.handsFreeRevealCountdown(secondsRemaining),
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FlashHandsFreeResult extends StatelessWidget {
  const FlashHandsFreeResult({
    super.key,
    required this.answer,
    required this.completedQuestions,
    required this.elapsed,
    required this.secondsRemaining,
    required this.onRepeatProblem,
    required this.onNextProblem,
    required this.onStop,
  });

  final String answer;
  final int completedQuestions;
  final Duration elapsed;
  final int secondsRemaining;
  final VoidCallback onRepeatProblem;
  final VoidCallback onNextProblem;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final data = FlashProblemData.of<String>(context);
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final elapsedText =
        '${elapsed.inMinutes}:${elapsed.inSeconds.remainder(60).toString().padLeft(2, '0')}';
    final width = data.isPortrait
        ? data.screenSize.width * 0.92
        : data.screenSize.width * 0.78;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: width,
              child: Container(
                padding: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 16,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          l10n.answer,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(color: colorScheme.onPrimary),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          answer,
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                      ),
                    ),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _HandsFreeStatCard(
                          label: l10n.handsFreeQuestionsCompleted(
                            completedQuestions,
                          ),
                        ),
                        _HandsFreeStatCard(
                          label: l10n.handsFreePracticeTime(elapsedText),
                        ),
                      ],
                    ),
                    Text(
                      l10n.handsFreeNextProblemCountdown(secondsRemaining),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 16,
                      runSpacing: 12,
                      children: [
                        _HandsFreeActionButton(
                          color: colorScheme.primaryContainer,
                          icon: Icons.replay_rounded,
                          label: l10n.repeatProblem,
                          onPressed: onRepeatProblem,
                        ),
                        _HandsFreeActionButton(
                          color: colorScheme.primaryContainer,
                          icon: Icons.arrow_forward_ios_rounded,
                          label: l10n.nextProblem,
                          onPressed: onNextProblem,
                        ),
                        FilledButton.icon(
                          onPressed: onStop,
                          icon: const Icon(Icons.stop_circle_outlined),
                          label: Text(l10n.handsFreeStop),
                          style: FilledButton.styleFrom(
                            backgroundColor: colorScheme.tertiaryContainer,
                            foregroundColor: colorScheme.onTertiaryContainer,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HandsFreeStatCard extends StatelessWidget {
  const _HandsFreeStatCard({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3,
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Text(label, style: Theme.of(context).textTheme.titleLarge),
      ),
    );
  }
}

class _HandsFreeActionButton extends StatelessWidget {
  const _HandsFreeActionButton({
    required this.color,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final Color color;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 180,
      child: NavigationButton(
        color: color,
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: colorScheme.onPrimaryContainer, size: 26),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnswerTracker extends StatelessWidget {
  const AnswerTracker({
    super.key,
    required this.answerResults,
    required this.currentIndex,
    required this.isPortrait,
  });
  final List<bool?> answerResults;
  final int currentIndex;
  final bool isPortrait;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const double itemWidth = 44;
    const double spacing = 6;
    final int itemsPerRow = answerResults.length > 10
        ? (isPortrait ? 5 : 8)
        : (isPortrait ? 5 : answerResults.length);
    final double wrapWidth =
        itemsPerRow * itemWidth + (itemsPerRow - 1) * spacing;

    return SizedBox(
      width: wrapWidth,
      child: Wrap(
        alignment: .center,
        direction: Axis.horizontal,
        runAlignment: WrapAlignment.center,
        spacing: spacing,
        runSpacing: spacing,
        children: List.generate(answerResults.length, (i) {
          final bool? isCorrect = answerResults[i];
          final bool isCurrent = i == currentIndex;
          final resultColor = isCorrect == null
              ? colorScheme.onSurface
              : isCorrect
              ? colorScheme.primary
              : colorScheme.tertiary;
          return Container(
            width: itemWidth,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: isCurrent
                  ? Border.all(color: resultColor, width: 2)
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${i + 1}', style: Theme.of(context).textTheme.titleLarge),
                Icon(
                  isCorrect == null
                      ? Icons.remove
                      : isCorrect
                      ? Icons.circle_outlined
                      : Icons.close,
                  size: isCorrect == null
                      ? 30
                      : isCorrect
                      ? 26
                      : 30,
                  color: resultColor,
                ),
              ],
            ),
          );
        }),
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
    this.onStart,
  });
  final double secondsPerProblem;
  final List<Segment> schedule;
  final VoidCallback onEnd;
  final VoidCallback? onStart;

  @override
  State<FlashProblem> createState() => FlashProblemState();
}

class FlashProblemState extends State<FlashProblem>
    with SingleTickerProviderStateMixin {
  FlashProblemData<String> get _data => FlashProblemData.of<String>(context);
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

    widget.onStart?.call();
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
