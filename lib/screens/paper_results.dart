import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:soroban_app/models/singer_config.dart';
import 'package:soroban_app/screens/components/navigation_button.dart';

import '../models/level_definitions.dart';
import 'components/keypad.dart';

class ResultsScreen extends StatelessWidget {
  final Level selectedLevel;
  final String? examDisplayString;
  final bool isExam;
  final List<String> allAnswers;
  final List<dynamic> allProblems;
  final List<TextFieldData> textFieldDataList;
  final Duration? elapsed;
  final Character? character;
  static final _countUpCircleKey = GlobalKey();

  ResultsScreen({
    super.key,
    required this.selectedLevel,
    required this.isExam,
    required this.allAnswers,
    required this.allProblems,
    required this.textFieldDataList,
    this.examDisplayString,
    this.elapsed,
    this.character,
  });

  @override
  Widget build(BuildContext context) {
    final List<ProblemScorer> problemScorerList = [
      for (int i = 0; i < allProblems.length; i++)
        ProblemScorer(
          index: i,
          problem: allProblems[i],
          answer: allAnswers[i],
          userAnswer: textFieldDataList[i].formatted,
        ),
    ];
    final score = getScore(selectedLevel.levelInfo, problemScorerList);

    return Scaffold(
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            final isPortrait = orientation == .portrait;

            Widget? examDescription;
            if (examDisplayString case final displayString?) {
              examDescription = Column(
                children: [
                  Text(
                    selectedLevel.levelInfo.denomination.denominationString,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  Text(
                    displayString,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ],
              );
            }

            Widget? elapsedCard;
            if (elapsed case final elapsedValue?) {
              elapsedCard = Material(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'タイム',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text(
                        elapsedValue.inMinutes > 0
                            ? '${elapsedValue.inMinutes}:${elapsedValue.inSeconds.remainder(60).toString().padLeft(2, '0')}.${elapsedValue.inMilliseconds.remainder(1000).toString().padLeft(3, '0')}'
                            : '${elapsedValue.inSeconds}.${elapsedValue.inMilliseconds.remainder(1000).toString().padLeft(3, '0')}',
                        style: TextStyle(fontSize: 48, fontFamily: 'mPlus'),
                      ),
                    ],
                  ),
                ),
              );
            }
            final countUpCircle = CountUpCircle(
              key: _countUpCircleKey,
              score: score,
              durationBase: Duration(milliseconds: 10),
              passThreshold: selectedLevel.levelInfo.passThreshold,
              rangedThreshold: selectedLevel.levelInfo.rangedThreshold,
              style: TextStyle(fontSize: 78, fontFamily: 'mPlus'),
              pointsPerProblem: selectedLevel.levelInfo.pointsPerProblem,
            );

            final buttonWrap = Wrap(
              alignment: .center,
              spacing: 20,
              runSpacing: 12,
              children: [
                if (score.$1 != score.$2)
                  SizedBox(
                    width: 310,
                    child: NavigationButton(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      onPressed: () {
                        context.push(
                          '/paper-review',
                          extra: {
                            'selectedLevel': selectedLevel,
                            'problemScorerList': problemScorerList,
                          },
                        );
                      },
                      child: Center(
                        child: iconHelper(
                          context,
                          Symbols.error_outline_rounded,
                          '間違えた問題を見る',
                        ),
                      ),
                    ),
                  ),
                SizedBox(
                  width: 310,
                  child: NavigationButton(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    onPressed: () {
                      switch (selectedLevel) {
                        case FlashLevel _:
                          context.go(
                            '/flash-problem',
                            extra: {
                              'selectedLevel': selectedLevel,
                              'isSingleProblem': false,
                              'examDisplayString': examDisplayString,
                            },
                          );
                        case AloudLevel _:
                          context.go(
                            '/aloud-problem',
                            extra: {
                              'isSingleProblem': false,
                              'selectedLevel': selectedLevel,
                              'character': character,
                              'examDisplayString': examDisplayString,
                            },
                          );
                        case PaperProblemLevel _:
                          context.go(
                            '/paper-problem',
                            extra: {
                              'selectedLevel': selectedLevel,
                              'isExam': isExam,
                              'time': selectedLevel.levelInfo.timeLimit,
                              'examDisplayString': examDisplayString,
                            },
                          );
                      }
                    },
                    child: Center(
                      child: iconHelper(
                        context,
                        Symbols.replay_rounded,
                        'もう一回挑戦する',
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 310,
                  child: NavigationButton(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    onPressed: () => context.go('/home'),
                    child: Center(
                      child: iconHelper(
                        context,
                        Symbols.home_rounded,
                        'メインメニューに戻る',
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 310,
                  child: NavigationButton(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    onPressed: () {
                      switch (selectedLevel) {
                        case FlashLevel _:
                          context.go('/flash-level-menu');
                        case AloudLevel _:
                          context.go('/aloud-level-menu');
                        case PaperProblemLevel _:
                          context.go('/paper-menu');
                      }
                    },
                    child: Center(
                      child: iconHelper(
                        context,
                        Symbols.settings_rounded,
                        '設定画面に戻る',
                      ),
                    ),
                  ),
                ),
              ],
            );

            if (isPortrait) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return Center(
                    child: FittedBox(
                      fit: .scaleDown,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ?examDescription,
                          countUpCircle,
                          ?elapsedCard,
                          SizedBox(height: 24),
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 500),
                            child: buttonWrap,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return Center(
                    child: FittedBox(
                      fit: .scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          countUpCircle,
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 12,
                            children: [
                              ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: 640),
                                child: Row(
                                  mainAxisAlignment: .center,
                                  spacing: 24,
                                  children: [?examDescription, ?elapsedCard],
                                ),
                              ),
                              const SizedBox(height: 10),
                              ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: 640),
                                child: buttonWrap,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

class ProblemScorer {
  final int index;
  final dynamic
  problem; // can be either List<List<String>> for Mitori/Flash/Aloud or List<String> for DivMult
  final String answer;
  final String userAnswer;

  const ProblemScorer({
    required this.index,
    required this.problem,
    required this.answer,
    required this.userAnswer,
  });

  bool get isCorrect => answer == userAnswer;
}

(int, int) getScore(
  LevelInfo levelInfo,
  List<ProblemScorer> problemScoringList,
) {
  final int score = problemScoringList.fold(
    0,
    (total, scorer) =>
        (total += scorer.isCorrect ? levelInfo.pointsPerProblem : 0),
  );
  final int outOf = problemScoringList.length * levelInfo.pointsPerProblem;
  return (score, outOf);
}

class CountUpCircle extends StatefulWidget {
  final (int, int) score;
  final Duration durationBase;
  final TextStyle style;
  final double passThreshold;
  final List<(String, int)>? rangedThreshold;
  final int pointsPerProblem;

  const CountUpCircle({
    super.key,
    required this.score,
    required this.durationBase,
    required this.style,
    required this.passThreshold,
    required this.rangedThreshold,
    required this.pointsPerProblem,
  });

  @override
  State<CountUpCircle> createState() => _CountUpCircleState();
}

class _CountUpCircleState extends State<CountUpCircle>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _countAnimation;
  late Animation<double> _progressAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  AudioSource? tickSound;
  AudioSource? passThresholdSound;
  AudioSource? passFailAppearSound;
  int _lastSoundTrigger = 0;
  bool _animatePassFail = false;
  bool _thresholdSoundPlayed = false;
  late final String passFailText;

  bool get userPassed =>
      widget.score.$1 / widget.score.$2 >= widget.passThreshold;

  @override
  void initState() {
    super.initState();
    if (widget.rangedThreshold != null) {
      String computedText = '不合格';
      for (final threshold in widget.rangedThreshold!) {
        if (widget.score.$1 >= threshold.$2) {
          computedText = threshold.$1;
        }
      }
      passFailText = computedText;
    } else {
      passFailText = userPassed ? '合格' : '不合格';
    }
    Duration duration =
        Duration(milliseconds: 800) + widget.durationBase * widget.score.$1;
    _controller = AnimationController(duration: duration, vsync: this);

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.elasticOut,
    );

    _countAnimation = IntTween(
      begin: 0,
      end: widget.score.$1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Progress animation from 0 to targetValue/maxValue
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.score.$1 / widget.score.$2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _countAnimation.addListener(_onCountChange);
    _progressAnimation.addListener(_onProgressChange);

    _startAfterDelay(duration);
  }

  void _startAfterDelay(Duration duration) async {
    await Future.wait([Future.delayed(Duration(seconds: 1)), _initSound()]);
    if (!mounted) return;
    _controller.forward();
    Future.delayed(duration + Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _animatePassFail = true);
      }
    });
  }

  Future<void> _initSound() async {
    try {
      tickSound = await SoLoud.instance.loadAsset('assets/tick.wav');
      passThresholdSound = await SoLoud.instance.loadAsset(
        'assets/passthreshold.wav',
      );
      passFailAppearSound = userPassed
          ? await SoLoud.instance.loadAsset('assets/pass.wav')
          : await SoLoud.instance.loadAsset('assets/fail.wav');
    } catch (e) {
      print('Error initializing sound: $e');
    }
  }

  void _onCountChange() {
    if (tickSound == null) return;
    int currentValue = _countAnimation.value;
    int currentMilestone =
        (currentValue ~/ widget.pointsPerProblem) * widget.pointsPerProblem;
    if (currentMilestone > _lastSoundTrigger && currentMilestone > 0) {
      _lastSoundTrigger = currentMilestone;
      int playCount = currentMilestone ~/ widget.pointsPerProblem;
      double pitch = 0.8 + (playCount * 0.04);
      final handle = SoLoud.instance.play(tickSound!);
      SoLoud.instance.setRelativePlaySpeed(handle, pitch);
    }
  }

  void _onProgressChange() {
    const epsilon = 0.0001;
    if (!_thresholdSoundPlayed &&
        _progressAnimation.value >= widget.passThreshold - epsilon) {
      _thresholdSoundPlayed = true;
      if (passThresholdSound != null) {
        SoLoud.instance.play(passThresholdSound!);
      }
      _pulseController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _countAnimation.removeListener(_onCountChange);
    _progressAnimation.removeListener(_onProgressChange);
    _controller.dispose();
    _pulseController.dispose();
    if (tickSound != null) {
      SoLoud.instance.disposeSource(tickSound!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _pulseController]),
      builder: (context, child) {
        const pulseAmplitude = 0.35;
        final double tickScale = 1.0 + _pulseAnimation.value * pulseAmplitude;
        return Padding(
          padding: const EdgeInsets.all(70.0),
          child: CustomPaint(
            painter: CircularProgressPainter(
              progress: _progressAnimation.value,
              ringColor: colorScheme.primary,
              backgroundColor: colorScheme.surfaceContainerHighest,
              tickPosition: widget.passThreshold,
              tickScale: tickScale,
            ),
            child: FittedBox(
              fit: .contain,
              child: Column(
                children: [
                  Transform.translate(
                    offset: Offset(0, 10),
                    child: Text(
                      '${widget.score.$2}点満点',
                      style: widget.style.copyWith(
                        fontSize: widget.style.fontSize! * 0.55,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 250,
                    child: Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        Opacity(
                          opacity: 0,
                          child: Row(
                            children: [
                              Text('${widget.score.$1}', style: widget.style),
                              Text(
                                '点',
                                style: widget.style.copyWith(
                                  fontSize: widget.style.fontSize! * 0.75,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          crossAxisAlignment: .end,
                          mainAxisAlignment: .center,
                          children: [
                            Transform.translate(
                              offset: Offset(0, 10),
                              child: Text(
                                '${_countAnimation.value}',
                                style: widget.style,
                              ),
                            ),
                            Text(
                              '点',
                              style: widget.style.copyWith(
                                fontSize: widget.style.fontSize! * 0.75,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PassFail(
                    animate: _animatePassFail,
                    userPassed: userPassed,
                    passFailAppearSound: passFailAppearSound,
                    passFailText: passFailText,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color ringColor;
  final Color backgroundColor;
  final double tickPosition;
  final double tickLength;
  final double tickScale;

  CircularProgressPainter({
    required this.progress,
    required this.ringColor,
    required this.backgroundColor,
    required this.tickPosition,
    required this.tickScale,
    this.tickLength = 20.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width * 0.7);

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc
    final progressPaint = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    const startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );

    final tickAngle = -pi / 2 + (2 * pi * tickPosition);

    final tickInnerRadius = radius - (tickLength * tickScale);
    final tickOuterRadius = radius - 3;

    final tickStart = Offset(
      center.dx + tickInnerRadius * cos(tickAngle),
      center.dy + tickInnerRadius * sin(tickAngle),
    );

    final tickEnd = Offset(
      center.dx + tickOuterRadius * cos(tickAngle),
      center.dy + tickOuterRadius * sin(tickAngle),
    );

    final tickPaint = Paint()
      ..color = progress >= tickPosition ? ringColor : backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0 * tickScale
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(tickStart, tickEnd, tickPaint);
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.ringColor != ringColor ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.tickPosition != tickPosition ||
        oldDelegate.tickLength != tickLength ||
        oldDelegate.tickScale != tickScale;
  }
}

class PassFail extends StatefulWidget {
  final bool animate;
  final bool userPassed;
  final AudioSource? passFailAppearSound;
  final String passFailText;

  const PassFail({
    super.key,
    required this.animate,
    required this.userPassed,
    required this.passFailAppearSound,
    required this.passFailText,
  });

  @override
  State<PassFail> createState() => _PassFailState();
}

class _PassFailState extends State<PassFail>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    final curved = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _scale = Tween<double>(begin: 1.4, end: 1.0).animate(curved);

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(curved);
  }

  @override
  void didUpdateWidget(PassFail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.animate && widget.animate) {
      _controller.forward();
      if (widget.passFailAppearSound != null) {
        SoLoud.instance.play(widget.passFailAppearSound!);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(
        scale: _scale,
        child: Text(widget.passFailText, style: const TextStyle(fontSize: 60)),
      ),
    );
  }
}
