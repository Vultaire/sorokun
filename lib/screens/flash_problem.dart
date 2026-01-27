import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:soroban_app/problem_generation/mitori.dart';

class FlashProblemScreen extends StatefulWidget {
  const FlashProblemScreen({
    super.key,
    required this.kuchi,
    required this.digits,
    required this.secondsPerProblem,
  });
  final int kuchi;
  final int digits;
  final double secondsPerProblem;

  @override
  State<FlashProblemScreen> createState() => FlashProblemScreenState();
}

class FlashProblemScreenState extends State<FlashProblemScreen>
    with SingleTickerProviderStateMixin {
  late final List<int> template;
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

    // Generate the problem
    template = List.filled(widget.kuchi, widget.digits);
    problem = generateMitoriProblemFromDigitList(template, Random());

    // Calculate green/black durations
    final n = widget.kuchi;
    final d = widget.secondsPerProblem;
    final blackDuration = d / (2.5 * n - 1);
    final greenDuration = 1.5 * blackDuration;

    // Build schedule of segments (green/black alternating)
    double t = 0;
    _schedule = [];
    for (int i = 0; i < n; i++) {
      // Green segment
      _schedule.add(Segment(t, t + greenDuration, true, i));
      t += greenDuration;

      // Black segment (except after last green)
      if (i < n - 1) {
        _schedule.add(Segment(t, t + blackDuration, false, i));
        t += blackDuration;
      }
    }

    // Animation controller
    _controller = AnimationController(
      vsync: this,
      duration: Duration(microseconds: (d * 1e6).round()),
    )..addListener(_onTick);

    // Initialize sounds and start animation
    _initSoundsAndStart();
  }

  Future<void> _initSoundsAndStart() async {
    startingSine = await SoLoud.instance.loadAsset('assets/starting-sine.wav');
    sineBeep = await SoLoud.instance.loadAsset('assets/sine-beep.wav');

    if (!mounted) return;

    SoLoud.instance.play(startingSine);

    // Wait 2 seconds before starting animation
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    _controller.forward();
  }

  void _onTick() {
    final t = _controller.value * widget.secondsPerProblem;

    // Advance current segment pointer only if t > segment.end
    while (_currentSegment < _schedule.length - 1 &&
        t >= _schedule[_currentSegment].end) {
      _currentSegment++;
    }

    final seg = _schedule[_currentSegment];

    // Update only if the segment actually changed
    if (mounted && (_currentIndex != seg.index || _showNumber != seg.showing)) {
      _currentIndex = seg.index;
      _showNumber = seg.showing;

      setState(() {});

      // Play sine beep only at start of green
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
    if (_currentIndex >= problem.length) {
      return const Scaffold(body: Center(child: Text('Done!')));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _showNumber
            ? Text(
                '${problem[_currentIndex]}',
                style: const TextStyle(
                  fontFamily: 'abacusFont',
                  fontSize: 92,
                  color: Colors.lightGreenAccent,
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}

class Segment {
  final double start; // seconds
  final double end; // seconds
  final bool showing; // green = true, black = false
  final int index; // which number
  Segment(this.start, this.end, this.showing, this.index);
}
