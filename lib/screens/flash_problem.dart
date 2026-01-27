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
  late final Duration kuchiWindow;
  late final AudioSource startingSine;
  late final AudioSource sineBeep;
  late final AnimationController _controller;

  int _currentIndex = 0;
  bool _showNumber = true;

  @override
  void initState() {
    super.initState();
    Random rand = Random();
    template = List.filled(widget.kuchi, widget.digits);
    problem = generateMitoriProblemFromDigitList(template, rand);

    // Debug print
    print('Full problem: $problem');
    print('Problem length: ${problem.length}');

    kuchiWindow = Duration(
      milliseconds: (widget.secondsPerProblem / widget.kuchi * 1000).round(),
    );

    print('Kuchi window duration: ${kuchiWindow.inMilliseconds}ms');

    _controller = AnimationController(vsync: this, duration: kuchiWindow)
      ..addListener(_onTick)
      ..addStatusListener(_onAnimationStatus);

    _beepsAndStart();
  }

  void _beepsAndStart() async {
    await Future.wait([Future.delayed(Duration(seconds: 1)), _initSound()]);
    if (!mounted) return;
    SoLoud.instance.play(startingSine);
    await Future.delayed(Duration(seconds: 2));
    if (!mounted) return;
    _controller.forward();
  }

  Future<void> _initSound() async {
    startingSine = await SoLoud.instance.loadAsset('assets/starting-sine.wav');
    sineBeep = await SoLoud.instance.loadAsset('assets/sine-beep.wav');
  }

  void _onTick() {
    final progress = _controller.value;
    final shouldShow = progress < 0.6;

    if (shouldShow != _showNumber && mounted) {
      setState(() {
        _showNumber = shouldShow;
      });
    }
  }

  void _onAnimationStatus(AnimationStatus status) {
    print('Animation status: $status, currentIndex: $_currentIndex');

    if (status == AnimationStatus.completed) {
      if (mounted) {
        setState(() {
          _currentIndex++;
          _showNumber = true;
        });
      }

      print('Advanced to index: $_currentIndex');

      if (_currentIndex < problem.length) {
        _controller.forward(from: 0);
      } else {
        print('Problem complete!');
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
    print('Building with index: $_currentIndex, showNumber: $_showNumber');

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
                  color: Colors.green,
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
