import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:math';

import 'package:go_router/go_router.dart';
import 'package:soroban_app/models/flash_source.dart';
import 'package:soroban_app/problem_generation/flash.dart';
import 'package:soroban_app/screens/components/navigation_button.dart';
import 'package:soroban_app/screens/components/spammable_button.dart';
import 'package:vector_graphics/vector_graphics_compat.dart';
import 'package:soroban_app/screens/components/incrementer.dart';

class FlashMenuPage extends StatefulWidget {
  const FlashMenuPage({super.key});

  @override
  State<FlashMenuPage> createState() => _FlashMenuPageState();
}

class _FlashMenuPageState extends State<FlashMenuPage> {
  double _secondsPerProblem = 10.00;
  int _kuchi = 15;
  int _digits = 3;

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Circular Slider')),
      body: Center(
        child: Wrap(
          alignment: .center,
          children: [
            FittedBox(
              fit: .contain,
              child: Row(
                mainAxisAlignment: .spaceEvenly,
                children: [
                  Incrementer(
                    value: _kuchi,
                    label: '口数',
                    onChanged: (newValue) => setState(() => _kuchi = newValue),
                    min: 1,
                    max: 30,
                  ),
                  SizedBox(width: 16),
                  Incrementer(
                    value: _digits,
                    label: '桁数',
                    onChanged: (newValue) => setState(() => _digits = newValue),
                    min: 1,
                    max: 6,
                  ),
                ],
              ),
            ),
            FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: 300,
                height: 300,
                child: Stack(
                  children: [
                    CircularSlider(
                      initialValue: _secondsPerProblem,
                      size: 300,
                      onChanged: (value) {
                        setState(() {
                          _secondsPerProblem = value;
                        });
                      },
                    ),
                    Positioned(
                      left: 0,
                      bottom: 0,
                      child: SpammableButton(
                        onTapDown: () {
                          _increaseValue();
                        },
                        enableRepeat: true,
                        offsetX: 3.0,
                        offsetY: 3.0,
                        child: Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.all(8),
                          child: VectorGraphic(
                            loader: AssetBytesLoader('assets/svg/tortoise.svg'),
                            colorFilter: ColorFilter.mode(
                              Theme.of(context).colorScheme.onSurface,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: SpammableButton(
                        onTapDown: () {
                          _decreaseValue();
                        },
                        enableRepeat: true,
                        child: Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.all(8),
                          child: VectorGraphic(
                            loader: AssetBytesLoader('assets/svg/hare.svg'),
                            colorFilter: ColorFilter.mode(
                              Theme.of(context).colorScheme.onSurface,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              '${(_secondsPerProblem / _kuchi).toStringAsFixed(3)} seconds per number',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            NavigationButton(
              onPressed: () {
                FlashSingleProblemSpec spec = FlashSingleProblemSpec(
                  digits: _digits,
                  kuchi: _kuchi,
                  secondsPerProblem: _secondsPerProblem,
                  builder: mitoriStyle,
                );
                context.go(
                  '/flash-problem',
                  extra: {'isSingleProblem': true, 'selectedLevel': spec},
                );
              },
              label: Text(
                'Start Flash Problem',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
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
  final double size;

  static const double maxValue = 40.0;
  static const double minValue = 0.9;
  static const double range1End = 10.0;

  const CircularSlider({
    super.key,
    this.initialValue = 10.0,
    this.onChanged,
    this.activeColor,
    this.backgroundColor,
    this.size = 200,
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
    const gapSize = pi / 4;
    const gapStart = pi / 2 - gapSize / 2;
    const startAngle = gapStart + gapSize;
    const totalArc = 2 * pi - gapSize;
    return startAngle + (totalArc * _progress);
  }

  double _calculateAngle(Offset localPosition, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
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

    const gapSize = pi / 4;
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
    final activeColor = widget.activeColor ?? colorScheme.primary;
    final backgroundColor =
        widget.backgroundColor ?? colorScheme.surfaceContainerHighest;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: GestureDetector(
        onPanStart: (details) {
          _handlePanStart(
            details.localPosition,
            Size(widget.size, widget.size),
          );
        },
        onPanUpdate: (details) {
          _handlePanUpdate(
            details.localPosition,
            Size(widget.size, widget.size),
          );
        },
        onPanEnd: (details) {
          _handlePanEnd();
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(widget.size, widget.size),
              painter: CircularSliderPainter(
                progress: _progress,
                ringColor: activeColor,
                backgroundColor: backgroundColor,
              ),
            ),
            SizedBox(
              width: widget.size * 0.5,
              height: widget.size * 0.5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _value >= 10
                        ? '${_value.toStringAsFixed(0)}秒'
                        : '${_value.toStringAsFixed(1)}秒',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 50,
                      color: activeColor,
                      fontFamily: 'bizUDPGR',
                    ),
                  ),
                ],
              ),
            ),
            Transform.rotate(
              angle: _handleAngle + pi / 2,
              child: Transform.translate(
                offset: Offset(0, -widget.size * 0.4),
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: activeColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(100),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
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
  final double progress;
  final Color ringColor;
  final Color backgroundColor;

  CircularSliderPainter({
    required this.progress,
    required this.ringColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width * 0.4);

    // Gap size in radians (e.g., 45 degrees = pi/4)
    const gapSize = pi / 4;
    const gapStart = pi / 2 - gapSize / 2; // Center the gap at bottom

    // Draw background arc (with gap at bottom)
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    // Draw from end of gap, all the way around to start of gap
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      gapStart + gapSize,
      2 * pi - gapSize,
      false,
      backgroundPaint,
    );

    // Draw progress arc (starting from bottom left of gap, going counter-clockwise)
    final progressPaint = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    const startAngle = gapStart + gapSize;
    final sweepAngle = (2 * pi - gapSize) * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircularSliderPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.ringColor != ringColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
