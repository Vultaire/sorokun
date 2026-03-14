import 'dart:math';
import 'package:flutter/material.dart';

class PieTimer extends StatefulWidget {
  final Duration duration;
  final VoidCallback onComplete;
  final bool delayOver;

  const PieTimer({
    super.key,
    required this.duration,
    required this.delayOver,
    required this.onComplete,
  });

  @override
  State<PieTimer> createState() => _PieTimerState();
}

class _PieTimerState extends State<PieTimer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _hasStarted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });

    // Start animation if delay is over
    if (widget.delayOver) {
      _controller.forward();
      _hasStarted = true;
    }
  }

  @override
  void didUpdateWidget(PieTimer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.delayOver && widget.delayOver && !_hasStarted) {
      _controller.forward();
      _hasStarted = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 100,
        height: 100,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _TimerCirclePainter(
                progress: 1 - _controller.value,
                color: Theme.of(context).colorScheme.primary,
                borderColor: Theme.of(context).colorScheme.primary,
                borderWidth: 3,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TimerCirclePainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color borderColor;
  final double borderWidth;

  _TimerCirclePainter({
    required this.progress,
    required this.color,
    required this.borderColor,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw border
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    canvas.drawCircle(center, radius - borderWidth, borderPaint);

    // Draw filled pie chart
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final sweepAngle = progress * 2 * pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - borderWidth),
      -pi / 2,
      sweepAngle,
      true,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(_TimerCirclePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class BarTimer extends StatefulWidget {
  final Duration duration;
  final VoidCallback onComplete;
  final bool delayOver;
  const BarTimer({
    super.key,
    required this.duration,
    required this.delayOver,
    required this.onComplete,
  });
  @override
  State<BarTimer> createState() => _BarTimerState();
}

class _BarTimerState extends State<BarTimer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _hasStarted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });
    if (widget.delayOver) {
      _controller.forward();
      _hasStarted = true;
    }
  }

  @override
  void didUpdateWidget(BarTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.delayOver && widget.delayOver && !_hasStarted) {
      _controller.forward();
      _hasStarted = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _TimerBarPainter(
            progress: 1 - _controller.value,
            color: Theme.of(context).colorScheme.primary,
            borderColor: Theme.of(context).colorScheme.primary,
            borderWidth: 3,
          ),
        );
      },
    );
  }
}

class _TimerBarPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color borderColor;
  final double borderWidth;

  _TimerBarPainter({
    required this.progress,
    required this.color,
    required this.borderColor,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(12);

    // Draw border/track
    final borderPaint = Paint()
      ..color = borderColor.withAlpha(100)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          borderWidth / 2,
          borderWidth / 2,
          size.width - borderWidth,
          size.height - borderWidth,
        ),
        radius,
      ),
      borderPaint,
    );

    // Draw filled bar
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final fillWidth = (size.width - borderWidth) * progress;
    if (fillWidth > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            borderWidth / 2,
            borderWidth / 2,
            fillWidth,
            size.height - borderWidth,
          ),
          radius,
        ),
        fillPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_TimerBarPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
