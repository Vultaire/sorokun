import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:go_router/go_router.dart';
import 'package:soroban_app/problem_generation/mitori.dart';

class FlashProblemScreen extends StatefulWidget {
  const FlashProblemScreen({
    super.key,
    required this.kuchi,
    required this.digits,
    required this.secondsPerProblem,
    this.repeatedProblem,
  });
  final int kuchi;
  final int digits;
  final double secondsPerProblem;
  final List<int>? repeatedProblem;

  @override
  State<FlashProblemScreen> createState() => FlashProblemScreenState();
}

class FlashProblemScreenState extends State<FlashProblemScreen>
    with SingleTickerProviderStateMixin {
  late final List<int> problem;
  late final AnimationController _controller;
  late final List<Segment> _schedule;

  int _currentIndex = 0;
  bool _showNumber = false;

  late final AudioSource startingSine;
  late final AudioSource sineBeep;
  int _currentSegment = 0;

  @override
  void initState() {
    super.initState();

    problem =
        widget.repeatedProblem ??
        (() {
          late final List<int> template = List.filled(
            widget.kuchi,
            widget.digits,
          );
          return generateMitoriProblemFromDigitList(template, Random());
        })();

    final n = widget.kuchi;
    final d = widget.secondsPerProblem;
    final hideDuration = d / (2.5 * n - 1);
    final showDuration = 1.5 * hideDuration;

    double t = 0;
    _schedule = [];
    for (int i = 0; i < n; i++) {
      _schedule.add(Segment(t, t + showDuration, true, i));
      t += showDuration;

      if (i < n - 1) {
        _schedule.add(Segment(t, t + hideDuration, false, i));
        t += hideDuration;
      }
    }

    // Animation controller
    _controller =
        AnimationController(
            vsync: this,
            duration: Duration(milliseconds: (d * 1000).round()),
          )
          ..addListener(_onTick)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              setState(() {
                _showNumber = false;
              });
              Future.delayed(const Duration(seconds: 1), () {
                if (mounted) {
                  context.push('/flash-input');
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

    while (_currentSegment < _schedule.length - 1 &&
        t >= _schedule[_currentSegment].end) {
      _currentSegment++;
    }

    final seg = _schedule[_currentSegment];

    if (mounted && (_currentIndex != seg.index || _showNumber != seg.showing)) {
      setState(() {
        _currentIndex = seg.index;
        _showNumber = seg.showing;
      });

      if (_showNumber) {
        SoLoud.instance.play(sineBeep);
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: FittedBox(
          fit: .contain,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: _showNumber
                ? Text(
                    '${problem[_currentIndex]}',
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
