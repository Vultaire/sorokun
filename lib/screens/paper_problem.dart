import 'dart:async';
import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:go_router/go_router.dart';
import 'package:soroban_app/problem_generation/mitori_set.dart';
import 'package:soroban_app/screens/components/pie_timer.dart';

import '../models/level_definitions.dart';
import '../problem_generation/divmult_set.dart';
import 'components/keypad.dart';

class PaperProblemScreen extends StatefulWidget {
  const PaperProblemScreen({
    required this.selectedLevel,
    required this.isExam,
    required this.time,
    required this.appBarTitle,
    super.key,
  });
  final PaperProblemLevel selectedLevel;
  final bool isExam;
  final Duration time;
  final String appBarTitle;

  @override
  State<PaperProblemScreen> createState() => _PaperProblemScreenState();
}

class _PaperProblemScreenState extends State<PaperProblemScreen> {
  final GlobalKey<_MitorizanWindowState> _mitorizanKey = GlobalKey();
  final GlobalKey<_DivMultWindowState> _divMultKey = GlobalKey();
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

  Future<bool> _onWillPop() async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('終了の確認'),
        content: const Text('本当にやめますか?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('いいえ'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('はい'),
          ),
        ],
      ),
    );
    return shouldPop ?? false;
  }

  Widget _buildWindow({required double height}) {
    if (widget.selectedLevel is MitoriLevel) {
      return MitorizanWindow(
        selectedLevel: widget.selectedLevel as MitoriLevel,
        isExam: widget.isExam,
        onComplete: () => _onComplete(outOfTime: false),
        height: height,
        key: _mitorizanKey,
      );
    } else if (widget.selectedLevel is DivMultLevel) {
      return DivMultWindow(
        selectedLevel: widget.selectedLevel as DivMultLevel,
        isExam: widget.isExam,
        onComplete: () => _onComplete(outOfTime: false),
        height: height,
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
    PaperProblemLevel? selectedLevel;
    bool? isExam;
    List<String>? allAnswers;
    List<dynamic>? allProblems;
    List<TextFieldData>? textFieldDataList;
    Duration? elapsed;

    _stopwatch.stop();

    final blockingOverlay = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: AbsorbPointer(
          absorbing: true,
          child: Container(color: Colors.transparent),
        ),
      ),
    );
    Overlay.of(context).insert(blockingOverlay);

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

    selectedLevel = widget.selectedLevel;
    isExam = widget.isExam;
    elapsed = _stopwatch.elapsed;

    if (!mounted) return;
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

                final router = GoRouter.of(context);

                // After pause, slide out
                Future.delayed(const Duration(milliseconds: 1000), () {
                  animationState = 2;
                  animationOverlay.markNeedsBuild();
                  // Navigate to results page
                  router.go(
                    '/paper-results',
                    extra: {
                      'selectedLevel': selectedLevel,
                      'isExam': isExam,
                      'allProblems': allProblems,
                      'allAnswers': allAnswers,
                      'textFieldDataList': textFieldDataList,
                      'elapsed': elapsed,
                    },
                  );
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
    final bool isPortrait = MediaQuery.orientationOf(context) == .portrait;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.appBarTitle),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () async {
              final shouldClose = await _onWillPop();
              if (shouldClose && context.mounted) {
                GoRouter.of(context).go('/paper-menu');
              }
            },
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          actions: [
            if (widget.isExam)
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: FittedBox(
                  fit: .contain,
                  child: PieTimer(
                    duration: widget.time,
                    delayOver: _delayOver,
                    onComplete: () => _onComplete(outOfTime: true),
                  ),
                ),
              ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: Flex(
              direction: isPortrait ? .vertical : .horizontal,
              children: [
                Expanded(
                  flex: 8,
                  child: Stack(
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) =>
                            _buildWindow(height: constraints.maxHeight),
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
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: IgnorePointer(
                    ignoring: !_delayOver,
                    child: _buildKeypad(),
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
        weight: 32, // 0.5s out of 2s = 25%
      ),
      TweenSequenceItem(tween: ConstantTween<double>(0.0), weight: 16),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.linear)),
        weight: 32, // 0.5s animation
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
  });
  final MitoriLevel selectedLevel;
  final bool isExam;
  final VoidCallback onComplete;
  final double height;

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

  void _initializeProblem(MitoriLevel level) {
    MitoriProblemSet fullProblemSet = MitoriProblemSet(
      level: widget.selectedLevel,
    );
    _allProblems = fullProblemSet.formattedProblems;
    _allAnswers = fullProblemSet.formattedAnswers;
    _maxDigits = fullProblemSet.maxDigits;
  }

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      carouselController: carouselController,
      options: CarouselOptions(
        height: widget.height,
        reverse: true,
        viewportFraction: 0.95,
        enlargeCenterPage: true,
        enlargeStrategy: .scale,
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
        return Stack(
          children: [
            Positioned(
              left: 0,
              top: 10,
              child: Container(
                width: 40.0,
                height: 40.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 2,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${problemIndex + 1}',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'bizUDPGR',
                      fontWeight: .bold,
                    ),
                  ),
                ),
              ),
            ),
            Column(
              children: [
                Expanded(
                  child: FittedBox(
                    fit: .fitHeight,
                    clipBehavior: Clip.hardEdge,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 3.0,
                                horizontal: 10.0,
                              ),
                              child: Text(
                                currentProblem[0],
                                style: switch (widget.selectedLevel) {
                                  SimpleMitoriLevel() => TextStyle(
                                    fontSize: 120,
                                    fontFamily: 'ogutama',
                                  ),
                                  _ => TextStyle(
                                    fontSize: 26,
                                    fontFamily: 'abacusFontSpaced',
                                  ),
                                },
                              ),
                            ),
                            ...currentProblem
                                .sublist(1)
                                .map(
                                  (n) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 3.0,
                                      horizontal: 10.0,
                                    ),
                                    child: Text(
                                      n,
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontFamily: 'abacusFontSpaced',
                                      ),
                                    ),
                                  ),
                                ),
                          ],
                        ),
                        Container(
                          width: 700,
                          height: 2,
                          color: Theme.of(context).colorScheme.onSurface,
                          margin: const EdgeInsets.only(top: 5),
                        ),
                        CustomTextField(
                          data: textFieldDataList[problemIndex],
                          isFocused: isFocused,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
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
  });
  final DivMultLevel selectedLevel;
  final bool isExam;
  final VoidCallback onComplete;
  final double height;

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
    return CarouselSlider.builder(
      carouselController: carouselController,
      options: CarouselOptions(
        height: widget.height,
        scrollDirection: .vertical,
        viewportFraction: 0.5,
        enlargeCenterPage: true,
        enlargeStrategy: .zoom,
        enlargeFactor: 0.25,
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
        return Opacity(
          opacity: isFocused ? 1.0 : 0.6,
          child: Stack(
            children: [
              if (problemIndex == 0 && _intRoundIndex != -1)
                Align(
                  alignment: .topCenter,
                  child: Transform.translate(
                    offset: const Offset(0, -30.0),
                    child: Text(
                      '（注意） 小数第3位未満四捨五入。',
                      style: TextStyle(fontSize: 18, fontFamily: 'bizUDPGR'),
                    ),
                  ),
                ),
              if (problemIndex == _intRoundIndex)
                Align(
                  alignment: .topCenter,
                  child: Transform.translate(
                    offset: const Offset(0, -30.0),
                    child: Text(
                      '（注意） 整数位未満四捨五入。',
                      style: TextStyle(fontSize: 18, fontFamily: 'bizUDPGR'),
                    ),
                  ),
                ),
              Align(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 40.0,
                        height: 40.0,
                        margin: const EdgeInsets.all(1.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 2,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${problemIndex + 1}',
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'bizUDPGR',
                              fontWeight: .bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    FittedBox(
                      fit: .contain,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Text(
                              currentProblem,
                              style: const TextStyle(
                                fontSize: 26,
                                fontFamily: 'abacusFont',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text('||', style: TextStyle(fontSize: 26)),
                    CustomTextField(
                      data: textFieldDataList[problemIndex],
                      isFocused: isFocused,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
          fontSize: 26.4,
          fontFamily: 'abacusFontSpaced',
        ), // I don't know why the caret position drifts unless I add the extra .4 here.
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final caretPos = textPainter.width;

    return SizedBox(
      height: 55,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 10),
            child: Text(
              data.formatted,
              style: const TextStyle(
                fontSize: 26,
                fontFamily: 'abacusFontSpaced',
              ),
            ),
          ),
          // Custom static cursor
          if (isFocused)
            Positioned(
              left: caretPos + 6,
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
