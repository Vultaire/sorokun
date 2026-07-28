import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:math';

import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soroban_app/models/level_definitions.dart';
import 'package:soroban_app/problem_generation/flash_set.dart';
import 'package:soroban_app/screens/components/navigation_button.dart';
import 'package:soroban_app/screens/components/spammable_button.dart';
import 'package:soroban_app/screens/components/incrementer.dart';
import 'package:soroban_app/screens/components/start_button.dart';

class FlashFreeMenuPage extends StatefulWidget {
  const FlashFreeMenuPage({super.key});

  @override
  State<FlashFreeMenuPage> createState() => _FlashFreeMenuPageState();
}

class _FlashFreeMenuPageState extends State<FlashFreeMenuPage> {
  double _secondsPerProblem = 10.0;
  int _kuchi = 15;
  int _digits = 3;
  late final SharedPreferencesWithCache _prefs;

  void _decreaseValue() {
    double newValue;

    if (_secondsPerProblem > CircularSlider.range1End) {
      // In range 40-10: decrease by 1
      newValue = _secondsPerProblem - 1.0;
    } else {
      // In range 10-0.9: decrease by 0.1
      newValue = (_secondsPerProblem * 10 - 1) / 10;
    }

    newValue = newValue.clamp(CircularSlider.minValue, CircularSlider.maxValue);

    setState(() {
      _secondsPerProblem = newValue;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    _prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: <String>{'secondsPerProblem', 'kuchi', 'digits'},
      ),
    );

    setState(() {
      _secondsPerProblem = _prefs.getDouble('secondsPerProblem') ?? 10.0;
      _kuchi = _prefs.getInt('kuchi') ?? 15;
      _digits = _prefs.getInt('digits') ?? 3;
    });
  }

  void _increaseValue() {
    double newValue;

    if (_secondsPerProblem >= CircularSlider.range1End) {
      // In range 40-10: increase by 1
      newValue = _secondsPerProblem + 1.0;
    } else {
      // In range 10-0.9: increase by 0.1
      newValue = (_secondsPerProblem * 10 + 1) / 10;
    }

    newValue = newValue.clamp(CircularSlider.minValue, CircularSlider.maxValue);

    setState(() {
      _secondsPerProblem = newValue;
    });
  }

  @override
  void dispose() {
    _prefs.setDouble('secondsPerProblem', _secondsPerProblem);
    _prefs.setInt('kuchi', _kuchi);
    _prefs.setInt('digits', _digits);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int hideDuration = (_secondsPerProblem / (2.5 * _kuchi - 1) * 1000)
        .round();
    final int showDuration = (1.5 * hideDuration).round();
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          MediaQuery.of(context).orientation == Orientation.landscape
              ? 40
              : kToolbarHeight,
        ),
        child: AppBar(
          title: const Text('フラッシュ暗算フリー'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/home'),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: OrientationBuilder(
              builder: (context, orientation) {
                final isPortrait = orientation == Orientation.portrait;

                final incrementers = Row(
                  mainAxisAlignment: .spaceEvenly,
                  children: [
                    Incrementer(
                      value: _kuchi,
                      label: '口数',
                      onChanged: (newValue) =>
                          setState(() => _kuchi = newValue.toInt()),
                      min: 2,
                      max: 30,
                    ),
                    SizedBox(width: 16),
                    Incrementer(
                      value: _digits,
                      label: '桁数',
                      onChanged: (newValue) =>
                          setState(() => _digits = newValue.toInt()),
                      min: 1,
                      max: 6,
                    ),
                  ],
                );

                final slider = SizedBox(
                  width: 400,
                  height: 300,
                  child: Stack(
                    children: [
                      CircularSlider(
                        initialValue: _secondsPerProblem,
                        width: 400,
                        height: 300,
                        onChanged: (value) {
                          setState(() {
                            _secondsPerProblem = value;
                          });
                        },
                      ),
                      Positioned(
                        left: 90,
                        bottom: 40,
                        child: SpammableButton(
                          onTapDown: () {
                            _increaseValue();
                          },
                          enableRepeat: true,
                          offsetX: 3.0,
                          offsetY: 3.0,
                          child: Container(
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.all(8),
                            child: Image.asset(
                              'assets/tortoise.png',
                              color: colorScheme.onSurface,
                              colorBlendMode: BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 90,
                        bottom: 40,
                        child: SpammableButton(
                          onTapDown: () {
                            _decreaseValue();
                          },
                          enableRepeat: true,
                          child: Container(
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.all(8),
                            child: Image.asset(
                              'assets/hare.png',
                              color: colorScheme.onSurface,
                              colorBlendMode: BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );

                final durationCards = Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Flex(
                    direction: isPortrait ? Axis.horizontal : Axis.vertical,
                    spacing: isPortrait ? 10 : 40,
                    children: [
                      Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(8),
                        color: colorScheme.surfaceContainer,
                        child: SizedBox(
                          width: 200,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Text('表示間隔', style: textTheme.headlineSmall),
                                Text(
                                  '~${showDuration}ms',
                                  style: textTheme.headlineLarge!.copyWith(
                                    fontFeatures: <FontFeature>[
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(8),
                        color: colorScheme.surfaceContainer,
                        child: SizedBox(
                          width: 200,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Text('消画間隔', style: textTheme.headlineSmall),
                                Text(
                                  '~${hideDuration}ms',
                                  style: textTheme.headlineLarge!.copyWith(
                                    fontFeatures: <FontFeature>[
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );

                final startButton = StartButton(
                  onPressed: () {
                    FlashSingleProblemSpec spec = FlashSingleProblemSpec(
                      digits: _digits,
                      kuchi: _kuchi,
                      secondsPerProblem: _secondsPerProblem,
                      builder: mitoriStyle,
                    );
                    context.push(
                      '/flash-problem',
                      extra: {'isSingleProblem': true, 'selectedLevel': spec},
                    );
                  },
                );

                if (isPortrait) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return Column(
                        mainAxisAlignment: .center,
                        spacing: 16,
                        children: [
                          Expanded(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: constraints.maxWidth,
                              ),
                              child: FittedBox(
                                fit: .contain,
                                child: Column(
                                  mainAxisAlignment: .spaceEvenly,
                                  spacing: 8,
                                  children: [
                                    incrementers,
                                    slider,
                                    durationCards,
                                  ],
                                ),
                              ),
                            ),
                          ),
                          startButton,
                        ],
                      );
                    },
                  );
                } else {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return Column(
                        mainAxisAlignment: .spaceEvenly,
                        children: [
                          Flexible(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: constraints.maxWidth,
                              ),
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    incrementers,
                                    slider,
                                    durationCards,
                                  ],
                                ),
                              ),
                            ),
                          ),
                          startButton,
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

class CircularSlider extends StatefulWidget {
  final double initialValue;
  final ValueChanged<double>? onChanged;
  final Color? activeColor;
  final Color? backgroundColor;
  final double width;
  final double height;

  static const double maxValue = 40.0;
  static const double minValue = 0.9;
  static const double range1End = 10.0;

  const CircularSlider({
    super.key,
    this.initialValue = 10.0,
    this.onChanged,
    this.activeColor,
    this.backgroundColor,
    required this.width,
    required this.height,
  });

  static double valueToProgress(double value) {
    if (value >= range1End) {
      return (maxValue - value) / (maxValue - range1End);
    } else {
      double range2Progress = (range1End - value) / (range1End - minValue);
      return 1.0 + range2Progress;
    }
  }

  static double progressToValue(double progress) {
    if (progress < 1.0) {
      return maxValue - (progress * (maxValue - range1End));
    } else {
      double range2Progress = progress - 1.0;
      return range1End - (range2Progress * (range1End - minValue));
    }
  }

  static double roundValue(double value) {
    if (value >= range1End) {
      return value.roundToDouble();
    } else {
      return (value * 10).round() / 10;
    }
  }

  @override
  State<CircularSlider> createState() => _CircularSliderState();
}

class _CircularSliderState extends State<CircularSlider> {
  late double _value;
  double? _lastAngle;
  double _accumulatedDelta = 0.0;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue.clamp(
      CircularSlider.minValue,
      CircularSlider.maxValue,
    );
  }

  @override
  void didUpdateWidget(CircularSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _value = widget.initialValue.clamp(
        CircularSlider.minValue,
        CircularSlider.maxValue,
      );
    }
  }

  // Use the static methods from the widget class
  double get _progress => CircularSlider.valueToProgress(_value) / 2.0;

  double get _handleAngle {
    const gapSize = 5 * pi / 6;
    const gapStart = pi / 2 - gapSize / 2;
    const startAngle = gapStart + gapSize;
    const totalArc = 2 * pi - gapSize;
    return startAngle + (totalArc * _progress);
  }

  double _calculateAngle(Offset localPosition, Size size) {
    final center = Offset(size.width / 2, 7 * size.height / 10);
    final touchPoint = localPosition - center;
    double angle = atan2(touchPoint.dy, touchPoint.dx);
    if (angle < 0) angle += 2 * pi;
    return angle;
  }

  void _handlePanStart(Offset localPosition, Size size) {
    _lastAngle = _calculateAngle(localPosition, size);
    _accumulatedDelta = 0.0;
  }

  void _handlePanUpdate(Offset localPosition, Size size) {
    final currentAngle = _calculateAngle(localPosition, size);
    if (_lastAngle == null) {
      _lastAngle = currentAngle;
      return;
    }

    double deltaAngle = currentAngle - _lastAngle!;
    if (deltaAngle > pi) {
      deltaAngle -= 2 * pi;
    } else if (deltaAngle < -pi) {
      deltaAngle += 2 * pi;
    }

    const gapSize = 5 * pi / 6;
    const totalArc = 2 * pi - gapSize;
    double deltaProgress = (deltaAngle / totalArc) * 2.0;

    _accumulatedDelta += deltaProgress;
    double currentProgress = CircularSlider.valueToProgress(_value);
    double newProgress = currentProgress + _accumulatedDelta;
    newProgress = newProgress.clamp(0.0, 2.0);

    double newValue = CircularSlider.progressToValue(newProgress);
    double roundedValue = CircularSlider.roundValue(newValue);
    roundedValue = roundedValue.clamp(
      CircularSlider.minValue,
      CircularSlider.maxValue,
    );

    if (roundedValue != _value) {
      double usedProgress =
          CircularSlider.valueToProgress(roundedValue) - currentProgress;
      setState(() {
        _value = roundedValue;
      });
      widget.onChanged?.call(_value);
      _accumulatedDelta -= usedProgress;
    }

    _lastAngle = currentAngle;
  }

  void _handlePanEnd() {
    _lastAngle = null;
    _accumulatedDelta = 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = widget.activeColor ?? colorScheme.primary;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: GestureDetector(
        onPanStart: (details) {
          _handlePanStart(
            details.localPosition,
            Size(widget.width, widget.height),
          );
        },
        onPanUpdate: (details) {
          _handlePanUpdate(
            details.localPosition,
            Size(widget.width, widget.height),
          );
        },
        onPanEnd: (details) {
          _handlePanEnd();
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(widget.width, widget.height),
              painter: CircularSliderPainter(backgroundColor: primaryColor),
            ),
            Positioned(
              top: 100,
              child: Row(
                mainAxisAlignment: .center,
                crossAxisAlignment: .end,
                children: [
                  Text(
                    _value >= 10
                        ? _value.toStringAsFixed(0)
                        : _value.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
                    ),
                  ),
                  Text('秒', style: Theme.of(context).textTheme.displaySmall),
                ],
              ),
            ),
            Transform.translate(
              offset: Offset(0, widget.height / 5),
              child: Transform.rotate(
                angle: _handleAngle + pi / 2,
                child: Transform.translate(
                  offset: Offset(0, -widget.height * 0.53),
                  child: Icon(Icons.circle, size: 30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CircularSliderPainter extends CustomPainter {
  final Color backgroundColor;

  CircularSliderPainter({required this.backgroundColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, 7 * size.height / 10);
    final radius = (size.width * 0.4);

    // Gap size in radians (e.g., 45 degrees = pi/4)
    const gapSize = 5 * pi / 6;
    const gapStart = pi / 2 - gapSize / 2; // Center the gap at bottom

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      gapStart + gapSize,
      2 * pi - gapSize,
      false,
      backgroundPaint,
    );
  }

  @override
  bool shouldRepaint(CircularSliderPainter oldDelegate) {
    return oldDelegate.backgroundColor != backgroundColor;
  }
}
