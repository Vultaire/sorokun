import 'package:flutter/material.dart';
import 'dart:math';

import 'package:go_router/go_router.dart';
import 'package:soroban_app/models/flash_source.dart';
import 'package:soroban_app/problem_generation/flash.dart';

class FlashMenuPage extends StatefulWidget {
  const FlashMenuPage({super.key});

  @override
  State<FlashMenuPage> createState() => _FlashMenuPageState();
}

class _FlashMenuPageState extends State<FlashMenuPage> {
  double _secondsPerProblem = 10.00;
  int _kuchi = 15;
  int _digits = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Circular Slider')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularSlider(
              initialValue: 10.0,
              size: 300,
              onChanged: (value) {
                setState(() {
                  _secondsPerProblem = value;
                });
              },
            ),
            const SizedBox(height: 40),
            Text(
              '${(_secondsPerProblem / _kuchi).toStringAsFixed(3)} seconds per number',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            ElevatedButton(
              onPressed: () {
                FlashSingleProblemSpec spec = FlashSingleProblemSpec(
                  digits: _digits,
                  kuchi: _kuchi,
                  secondsPerProblem: _secondsPerProblem,
                  builder: mitoriStyle,
                );
                context.go(
                  '/flash-problem',
                  extra: {
                    'isSingleProblem': true,
                    'selectedLevel': FlashLevel.kkk1,
                  },
                );
              },
              child: Text('Start Flash Problem'),
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

  const CircularSlider({
    super.key,
    this.initialValue = 10.0,
    this.onChanged,
    this.activeColor,
    this.backgroundColor,
    this.size = 200,
  });

  @override
  State<CircularSlider> createState() => _CircularSliderState();
}

class _CircularSliderState extends State<CircularSlider> {
  late double _value;
  double? _lastAngle;
  double _accumulatedDelta = 0.0;

  // Custom scale constants
  static const double maxValue = 40.0;
  static const double minValue = 0.9;

  // Range boundaries
  static const double range1End = 10.0; // 40-10: precision 1
  // 10-0.9: precision 0.1

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue.clamp(minValue, maxValue);
  }

  // Convert value to progress (0.0 to 2.0)
  double _valueToProgress(double value) {
    if (value >= range1End) {
      // Range 1: 40-10
      return (maxValue - value) / (maxValue - range1End);
    } else {
      // Range 2: 10-0.9
      double range2Progress = (range1End - value) / (range1End - minValue);
      return 1.0 + range2Progress;
    }
  }

  // Convert progress (0.0 to 2.0) to value
  double _progressToValue(double progress) {
    if (progress < 1.0) {
      // Range 1: 40-10
      return maxValue - (progress * (maxValue - range1End));
    } else {
      // Range 2: 10-0.9
      double range2Progress = progress - 1.0;
      return range1End - (range2Progress * (range1End - minValue));
    }
  }

  // Round value to appropriate precision
  double _roundValue(double value) {
    if (value >= range1End) {
      // Precision: 1
      return value.roundToDouble();
    } else {
      // Precision: 0.1
      return (value * 10).round() / 10;
    }
  }

  double get _progress =>
      _valueToProgress(_value) / 2.0; // Normalize to 0-1 for display

  // Calculate the visual angle for the handle (accounting for gap and direction)
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

    // Normalize angle to 0-2π range
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

    // Convert angle delta to progress delta
    // Account for the speedometer layout (gap at bottom, starts bottom-left)
    const gapSize = pi / 4;
    const totalArc = 2 * pi - gapSize;
    double deltaProgress = (deltaAngle / totalArc) * 2.0;

    // Accumulate the delta
    _accumulatedDelta += deltaProgress;

    // Convert current value to progress
    double currentProgress = _valueToProgress(_value);
    double newProgress = currentProgress + _accumulatedDelta;

    // Clamp progress to valid range
    newProgress = newProgress.clamp(0.0, 2.0);

    // Convert back to value
    double newValue = _progressToValue(newProgress);

    // Round to appropriate precision
    double roundedValue = _roundValue(newValue);

    // Clamp to min/max
    roundedValue = roundedValue.clamp(minValue, maxValue);

    if (roundedValue != _value) {
      // Calculate how much progress was actually used
      double usedProgress = _valueToProgress(roundedValue) - currentProgress;

      setState(() {
        _value = roundedValue;
      });
      widget.onChanged?.call(_value);

      // Subtract only the used portion from accumulator
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
            // Circular slider track
            CustomPaint(
              size: Size(widget.size, widget.size),
              painter: CircularSliderPainter(
                progress: _progress,
                ringColor: activeColor,
                backgroundColor: backgroundColor,
              ),
            ),
            // Center display
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
            // Handle indicator at the current position
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
                        color: Colors.black.withOpacity(0.2),
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

    const startAngle = gapStart + gapSize; // Start right after the gap
    final sweepAngle = (2 * pi - gapSize) * progress; // Sweep counter-clockwise

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
