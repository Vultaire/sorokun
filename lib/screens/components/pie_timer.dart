import 'dart:math';
import 'package:flutter/material.dart';

class PieTimer extends StatefulWidget {
  final Duration duration;
  final VoidCallback onComplete;

  const PieTimer({super.key, required this.duration, required this.onComplete});

  @override
  State<PieTimer> createState() => _PieTimerState();
}

class _PieTimerState extends State<PieTimer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _TimerCirclePainter(
              progress: 1 - _controller.value,
              color: Theme.of(context).primaryColor,
              borderColor: Theme.of(context).dividerColor,
              borderWidth: 2,
            ),
          );
        },
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
    canvas.drawCircle(center, radius - borderWidth / 2, borderPaint);

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
