import 'dart:async';
import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:go_router/go_router.dart';
import 'package:soroban_app/main.dart';
import 'package:soroban_app/problem_generation/mitori_set.dart';
import 'package:soroban_app/screens/components/appbar.dart';
import 'package:soroban_app/screens/components/divmult_display.dart';
import 'package:soroban_app/screens/components/mitori_display.dart';
import 'package:soroban_app/screens/components/pie_timer.dart';
import 'package:soroban_app/screens/settings.dart';

import '../models/level_definitions.dart';
import '../problem_generation/divmult_set.dart';
import 'components/keypad.dart';

class PaperProblemScreen extends StatefulWidget {
  const PaperProblemScreen({
    required this.selectedLevel,
    required this.isExam,
    required this.examDisplayString,
    super.key,
  });
  final PaperProblemLevel selectedLevel;
  final bool isExam;
  final String? examDisplayString;

  @override
  State<PaperProblemScreen> createState() => _PaperProblemScreenState();
}

class _PaperProblemScreenState extends State<PaperProblemScreen> {
  final GlobalKey<_MitorizanWindowState> _mitorizanKey = GlobalKey();
  final GlobalKey<_DivMultWindowState> _divMultKey = GlobalKey();
  final GlobalKey<ResultPopupState> _resultPopupKey =
      GlobalKey<ResultPopupState>();
  bool _delayOver = false;
  bool _showLoading = false;
  late final PaperProblemSounds _sound;
  Stopwatch _stopwatch = Stopwatch();
  @override
  void initState() {
    super.initState();
    _startDelaySequence();
  }

  void _startDelaySequence() async {
    _sound = PaperProblemSounds();

    await Future.wait([
      Future.delayed(DelayWindow.delayToSoundCue),
      _sound.init(),
    ]);

    if (!mounted) return;

    setState(() {
      _showLoading = true;
    });
  }

  Widget _buildWindow({required double height}) {
    if (widget.selectedLevel is MitoriLevel) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: MitorizanWindow(
          selectedLevel: widget.selectedLevel as MitoriLevel,
          isExam: widget.isExam,
          onComplete: () => _onComplete(outOfTime: false),
          height: height,
          resultPopupKey: _resultPopupKey,
          key: _mitorizanKey,
        ),
      );
    } else if (widget.selectedLevel is DivMultLevel) {
      return DivMultWindow(
        selectedLevel: widget.selectedLevel as DivMultLevel,
        isExam: widget.isExam,
        onComplete: () => _onComplete(outOfTime: false),
        height: height,
        resultPopupKey: _resultPopupKey,
        key: _divMultKey,
      );
    } else {
      return const Center(child: Text('Unknown level type'));
    }
  }

  Widget _buildKeypad() {
    if (widget.selectedLevel is MitoriLevel) {
      return Keypad(
        onAppendDigit: (digit) =>
            _mitorizanKey.currentState?.appendDigit(digit),
        onDeleteDigit: () => _mitorizanKey.currentState?.deleteDigit(),
        onClearAll: () => _mitorizanKey.currentState?.clearAll(),
        onSubmit: () => _mitorizanKey.currentState?.submit(),
        levelType: .mitori,
      );
    } else if (widget.selectedLevel is DivMultLevel) {
      return Keypad(
        onAppendDigit: (digit) => _divMultKey.currentState?.appendDigit(digit),
        onDeleteDigit: () => _divMultKey.currentState?.deleteDigit(),
        onClearAll: () => _divMultKey.currentState?.clearAll(),
        onSubmit: () => _divMultKey.currentState?.submit(),
        levelType: .divMult,
      );
    } else {
      return const SizedBox();
    }
  }

  void _onComplete({required bool outOfTime}) async {
    _stopwatch.stop();

    final data = _collectResultData();
    if (data == null || !mounted) return;

    final blockingOverlay = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: AbsorbPointer(
          absorbing: true,
          child: Container(color: Colors.transparent),
        ),
      ),
    );
    Overlay.of(context).insert(blockingOverlay);

    await _playCompleteAnimation(
      outOfTime: outOfTime,
      blockingOverlay: blockingOverlay,
      data: data,
    );
  }

  _PaperResultData? _collectResultData() {
    List<String>? allAnswers;
    List<dynamic>? allProblems;
    List<TextFieldData>? textFieldDataList;

    switch (widget.selectedLevel) {
      case MitoriLevel():
        final state = _mitorizanKey.currentState;
        if (state != null) {
          allAnswers = state._allAnswers;
          allProblems = state._allProblems;
          textFieldDataList = state._textFieldDataList;
        }
      case DivMultLevel():
        final state = _divMultKey.currentState;
        if (state != null) {
          allAnswers = state._allAnswers;
          allProblems = state._allProblems;
          textFieldDataList = state._textFieldDataList;
        }
    }

    if (allAnswers == null ||
        allProblems == null ||
        textFieldDataList == null) {
      return null;
    }

    return _PaperResultData(
      selectedLevel: widget.selectedLevel,
      isExam: widget.isExam,
      allAnswers: allAnswers,
      allProblems: allProblems,
      textFieldDataList: textFieldDataList,
      elapsed: _stopwatch.elapsed,
    );
  }

  void _navigateToResults(_PaperResultData data) {
    GoRouter.of(context).go(
      '/paper-results',
      extra: {
        'selectedLevel': data.selectedLevel,
        'isExam': data.isExam,
        'examDisplayString': widget.examDisplayString,
        'allProblems': data.allProblems,
        'allAnswers': data.allAnswers,
        'textFieldDataList': data.textFieldDataList,
        'elapsed': data.elapsed,
      },
    );
  }

  Future<void> _playCompleteAnimation({
    required bool outOfTime,
    required OverlayEntry blockingOverlay,
    required _PaperResultData data,
  }) async {
    final overlay = Overlay.of(context);
    await Future.delayed(const Duration(milliseconds: 500));

    int animationState = 0;
    late OverlayEntry animationOverlay;
    animationOverlay = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withValues(alpha: 0.7),
          ),
          TweenAnimationBuilder<double>(
            key: ValueKey(animationState),
            tween: Tween(
              begin: animationState == 0
                  ? 2.0
                  : (animationState == 1 ? 0.0 : 0.0),
              end: animationState == 0
                  ? 0.0
                  : (animationState == 1 ? 0.0 : -2.0),
            ),
            duration: Duration(milliseconds: animationState == 1 ? 0 : 500),
            curve: animationState == 0 ? Curves.easeOut : Curves.easeIn,
            onEnd: () {
              if (animationState == 0) {
                // Finished sliding in, now pause
                animationState = 1;
                animationOverlay.markNeedsBuild();
                // After pause, slide out
                Future.delayed(const Duration(milliseconds: 1000), () {
                  animationState = 2;
                  animationOverlay.markNeedsBuild();
                  _navigateToResults(data);
                });
              } else if (animationState == 2) {
                // Finished sliding out, remove overlays
                animationOverlay.remove();
                blockingOverlay.remove();
              }
            },
            builder: (context, value, child) {
              return Center(
                child: Transform.translate(
                  offset: Offset(value * MediaQuery.of(context).size.width, 0),
                  child: outOfTime
                      ? Image.asset('assets/yame.png', width: 200, height: 200)
                      : Image.asset(
                          'assets/kanryou.png',
                          width: 200,
                          height: 200,
                        ),
                ),
              );
            },
          ),
        ],
      ),
    );
    overlay.insert(animationOverlay);
    await Future.delayed(const Duration(milliseconds: 2400));
  }

  @override
  Widget build(BuildContext context) {
    final Widget pieTimer = SizedBox(
      width: 33,
      height: 33,
      child: PieTimer(
        duration: widget.selectedLevel.levelInfo.timeLimit,
        delayOver: _delayOver,
        onComplete: () => _onComplete(outOfTime: true),
      ),
    );
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: CustomAppBar(
        title: widget.examDisplayString ?? '',
        context: context,
        black: true,
        actionWidget: widget.isExam ? pieTimer : null,
        onBackPressed: () async {
          await showExitDialog(
            context,
            homeRoute: '/paper-menu',
            onSubmit: () {
              final data = _collectResultData();
              if (data != null) _navigateToResults(data);
            },
          );
        },
      ),
      body: Container(
        color: Colors.black,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return OrientationBuilder(
                builder: (context, orientation) {
                  final isPortrait = orientation == Orientation.portrait;
                  final isLeftHanded =
                      InheritedAppController.of(context).handedness ==
                      Handedness.left;

                  final problemWindow = Stack(
                    children: [
                      Align(
                        alignment: .centerLeft,
                        child: LayoutBuilder(
                          builder: (context, innerConstraints) =>
                              _buildWindow(height: innerConstraints.maxHeight),
                        ),
                      ),
                      if (!_delayOver)
                        DelayWindow(
                          showLoading: _showLoading,
                          sounds: _sound,
                          onFinished: () {
                            setState(() {
                              _delayOver = true;
                            });
                            _stopwatch.start();
                          },
                        ),
                    ],
                  );
                  final keypad = IgnorePointer(
                    ignoring: !_delayOver,
                    child: Stack(
                      children: [
                        Align(
                          alignment: .center,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              isPortrait ? 8.0 : 0,
                              isPortrait ? 8.0 : 0,
                              isPortrait ? 8.0 : 0,
                              0,
                            ),
                            child: _buildKeypad(),
                          ),
                        ),
                        Align(
                          alignment: .center,
                          child: ResultPopup(key: _resultPopupKey),
                        ),
                      ],
                    ),
                  );
                  final Widget mainContent = Flex(
                    direction: isPortrait ? Axis.vertical : Axis.horizontal,
                    children: isPortrait || !isLeftHanded
                        ? [
                            Expanded(
                              flex: 8,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(maxHeight: 600),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: Container(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surface,
                                      child: problemWindow,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(flex: 5, child: keypad),
                          ]
                        : [
                            Expanded(flex: 5, child: keypad),
                            Expanded(
                              flex: 8,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(maxHeight: 600),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: Container(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surface,
                                      child: problemWindow,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                  );
                  return mainContent;
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PaperResultData {
  const _PaperResultData({
    required this.selectedLevel,
    required this.isExam,
    required this.allAnswers,
    required this.allProblems,
    required this.textFieldDataList,
    required this.elapsed,
  });

  final PaperProblemLevel selectedLevel;
  final bool isExam;
  final List<String> allAnswers;
  final List<dynamic> allProblems;
  final List<TextFieldData> textFieldDataList;
  final Duration elapsed;
}

class PaperProblemSounds {
  late final AudioSource startingSine;
  late final AudioSource sineBeep;

  final Completer<void> _ready = Completer<void>();

  Future<void> init() async {
    startingSine = await SoLoud.instance.loadAsset('assets/starting-sine.wav');
    sineBeep = await SoLoud.instance.loadAsset('assets/sine-beep.wav');
    _ready.complete();
  }

  Future<void> get ready => _ready.future;
}

class LoadingCircle extends CustomPainter {
  final double progress;
  final Color ringColor;
  final Color backgroundColor;

  LoadingCircle({
    required this.progress,
    required this.ringColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width * 0.5);

    // Draw progress arc
    final progressPaint = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    const startAngle = -pi / 2;
    final sweepAngle = -2 * pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(LoadingCircle oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.ringColor != ringColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}

class DelayWindow extends StatefulWidget {
  const DelayWindow({
    super.key,
    required this.showLoading,
    required this.sounds,
    required this.onFinished,
  });
  final bool showLoading;
  static const Duration delayToSoundCue = Duration(milliseconds: 600);
  static const Duration delayToStart = Duration(seconds: 2);
  final PaperProblemSounds sounds;
  final VoidCallback onFinished;

  @override
  State<DelayWindow> createState() => _DelayWindowState();
}

class _DelayWindowState extends State<DelayWindow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: DelayWindow.delayToStart,
      vsync: this,
    );

    _progressAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.linear)),
        weight: 32,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(0.0), weight: 16),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.linear)),
        weight: 32,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(0.0), weight: 20),
    ]).animate(_controller);
    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.forward) {
        await widget.sounds.ready;
        SoLoud.instance.play(widget.sounds.startingSine);
      }

      if (status == AnimationStatus.completed) {
        await widget.sounds.ready;
        SoLoud.instance.play(widget.sounds.sineBeep);

        if (mounted) {
          widget.onFinished();
        }
      }
    });
    if (widget.showLoading) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(DelayWindow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showLoading && !oldWidget.showLoading) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: widget.showLoading
            ? AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  if (_progressAnimation.value <= 0.0) {
                    return const SizedBox.shrink();
                  }

                  return SizedBox(
                    width: 200,
                    height: 200,
                    child: CustomPaint(
                      painter: LoadingCircle(
                        progress: _progressAnimation.value,
                        ringColor: colorScheme.primary,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                      ),
                    ),
                  );
                },
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}

class MitorizanWindow extends StatefulWidget {
  const MitorizanWindow({
    required this.selectedLevel,
    required this.isExam,
    required this.onComplete,
    required this.height,
    super.key,
    required this.resultPopupKey,
  });
  final MitoriLevel selectedLevel;
  final bool isExam;
  final VoidCallback onComplete;
  final double height;
  final GlobalKey<ResultPopupState> resultPopupKey;

  @override
  State<MitorizanWindow> createState() => _MitorizanWindowState();
}

class _MitorizanWindowState extends State<MitorizanWindow>
    with PaperKeypadMethods {
  late final List<List<String>> _allProblems;
  late final List<String> _allAnswers;
  late final List<TextFieldData> _textFieldDataList;
  late final KeypadSounds _sound;
  late final int _maxDigits;
  late final double _dividerWidth =
      (widget.selectedLevel.maxDigits * 29) +
      (((widget.selectedLevel.maxDigits - 1) ~/ 3) * 10) +
      60;
  late final double _landscapeViewportFraction;

  @override
  bool get isExam => widget.isExam;
  @override
  int get maxDigits => _maxDigits;
  @override
  List<String> get allAnswers => _allAnswers;
  @override
  List<TextFieldData> get textFieldDataList => _textFieldDataList;
  @override
  KeypadSounds get sound => _sound;
  @override
  VoidCallback get onComplete => widget.onComplete;
  @override
  int currentIndex = 0;
  @override
  final CarouselSliderController carouselController =
      CarouselSliderController();
  @override
  GlobalKey<ResultPopupState> get resultPopupKey => widget.resultPopupKey;

  @override
  void initState() {
    super.initState();

    _initializeProblem(widget.selectedLevel);

    _textFieldDataList = List.generate(
      _allProblems.length,
      (_) => TextFieldData(),
    );

    _sound = KeypadSounds();
    _sound.init();
    _landscapeViewportFraction = _computeViewportFraction();
  }

  void _initializeProblem(MitoriLevel level) {
    MitoriProblemSet fullProblemSet = MitoriProblemSet(
      level: widget.selectedLevel,
    );
    _allProblems = fullProblemSet.formattedProblems;
    _allAnswers = fullProblemSet.formattedAnswers;
    _maxDigits = fullProblemSet.maxDigits;
  }

  double _computeViewportFraction() {
    const referenceWidth = 409.0;
    const maxFraction = 0.622;
    const minFraction =
        0.499; //https://github.com/serenader2014/flutter_carousel_slider/issues/419#issuecomment-2460944294

    final fraction = maxFraction * (_dividerWidth / referenceWidth);
    print(fraction.clamp(minFraction, maxFraction));
    return fraction.clamp(minFraction, maxFraction);
  }

  @override
  Widget build(BuildContext context) {
    final bool isPortrait = MediaQuery.orientationOf(context) == .portrait;

    return CarouselSlider.builder(
      carouselController: carouselController,
      options: CarouselOptions(
        height: widget.height,
        reverse: true,
        viewportFraction: isPortrait ? 1 : _landscapeViewportFraction,
        padEnds: false,
        enlargeCenterPage: isPortrait ? false : true,
        enlargeStrategy: .scale,
        disableCenter: true,
        enlargeFactor: 0.2,
        onPageChanged: (index, reason) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
      itemCount: _allProblems.length,
      itemBuilder: (BuildContext context, int problemIndex, int realIndex) {
        final List<String> currentProblem = _allProblems[problemIndex];
        final isFocused = problemIndex == currentIndex;
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOutCubic,
          opacity: isFocused ? 1.0 : 0.6,
          child: FittedBox(
            fit: .scaleDown,
            clipBehavior: Clip.none,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IntrinsicWidth(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MitoriDisplay(
                      problemIndex: problemIndex,
                      currentProblem: currentProblem,
                      isSimpleMitori: widget.selectedLevel is SimpleMitoriLevel,
                    ),
                    Container(
                      width: _dividerWidth,
                      height: 2,
                      color: Theme.of(context).colorScheme.onSurface,
                      margin: const EdgeInsets.only(top: 5),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CustomTextField(
                          data: textFieldDataList[problemIndex],
                          isFocused: isFocused,
                        ),
                        const SizedBox(width: 6),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class DivMultWindow extends StatefulWidget {
  const DivMultWindow({
    required this.selectedLevel,
    required this.isExam,
    required this.onComplete,
    required this.height,
    super.key,
    required this.resultPopupKey,
  });
  final DivMultLevel selectedLevel;
  final bool isExam;
  final VoidCallback onComplete;
  final double height;
  final GlobalKey<ResultPopupState> resultPopupKey;

  @override
  State<DivMultWindow> createState() => _DivMultWindowState();
}

class _DivMultWindowState extends State<DivMultWindow> with PaperKeypadMethods {
  late final List<String> _allProblems;
  late final List<String> _allAnswers;
  late final List<TextFieldData> _textFieldDataList;
  late final KeypadSounds _sound;
  // index in allProblems at the first problem to require an answer rounded to integer
  late final int _intRoundIndex;

  @override
  bool get isExam => widget.isExam;
  @override
  List<String> get allAnswers => _allAnswers;
  @override
  List<TextFieldData> get textFieldDataList => _textFieldDataList;
  @override
  KeypadSounds get sound => _sound;
  @override
  final maxDigits = 11;
  @override
  VoidCallback get onComplete => widget.onComplete;
  @override
  int currentIndex = 0;
  @override
  final CarouselSliderController carouselController =
      CarouselSliderController();
  @override
  GlobalKey<ResultPopupState> get resultPopupKey => widget.resultPopupKey;

  double _computeViewportFraction(double height) {
    const referenceHeight = 330.0; // height at which fraction == 0.53
    const maxFraction = 0.53; // fraction for small screens
    const minFraction = 0.36; // floor for very large screens

    final fraction = maxFraction * (referenceHeight / height);
    return fraction.clamp(minFraction, maxFraction);
  }

  @override
  void initState() {
    super.initState();

    _initializeProblem(widget.selectedLevel);

    _textFieldDataList = List.generate(
      _allProblems.length,
      (_) => TextFieldData(),
    );

    _sound = KeypadSounds();
    _sound.init();
  }

  void _initializeProblem(DivMultLevel level) {
    DivMultProblemSet fullProblemSet = DivMultProblemSet(
      level: widget.selectedLevel,
    );
    _allProblems = fullProblemSet.formattedProblems;
    _allAnswers = fullProblemSet.formattedAnswers;
    _intRoundIndex = _allProblems.indexWhere((item) => item.startsWith('\\'));
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: OverflowBox(
        maxHeight: widget.height + 70,
        alignment: .bottomCenter,
        child: CarouselSlider.builder(
          carouselController: carouselController,
          options: CarouselOptions(
            height: widget.height + 70,
            scrollDirection: .vertical,
            viewportFraction: _computeViewportFraction(widget.height),
            enlargeCenterPage: true,
            enlargeStrategy: .zoom,
            enlargeFactor: 0.2,
            onPageChanged: (index, reason) {
              setState(() {
                currentIndex = index;
              });
            },
          ),
          itemCount: _allProblems.length,
          itemBuilder: (BuildContext context, int problemIndex, int realIndex) {
            final currentProblem = _allProblems[problemIndex];
            final isFocused = problemIndex == currentIndex;
            return AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              opacity: isFocused ? 1.0 : 0.6,
              child: DivMultDisplay(
                problemIndex: problemIndex,
                isFocused: isFocused,
                underEquals: CustomTextField(
                  data: textFieldDataList[problemIndex],
                  isFocused: isFocused,
                ),
                intRoundIndex: _intRoundIndex,
                currentProblem: currentProblem,
              ),
            );
          },
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.data,
    this.isFocused = false,
  });

  final TextFieldData data;
  final bool isFocused;

  @override
  Widget build(BuildContext context) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: data.beforeCaret,
        style: const TextStyle(
          fontSize: 30.4,
          fontFamily: 'abacusFontSpaced',
        ), // I don't know why the caret position drifts unless I add the extra .4 here.
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final caretPos = textPainter.width;

    return SizedBox(
      height: 58,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
            child: Text(
              data.formatted,
              style: const TextStyle(
                fontSize: 30,
                fontFamily: 'abacusFontSpaced',
              ),
              textScaler: .noScaling,
            ),
          ),
          // Custom static cursor
          if (isFocused)
            Positioned(
              left: caretPos + 2,
              top: 10,
              child: Container(
                width: 2,
                height: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }
}
