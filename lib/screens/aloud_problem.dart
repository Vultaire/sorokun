import 'dart:math';
import 'dart:typed_data';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:soroban_app/models/aloud_source.dart';
import 'package:soroban_app/problem_generation/aloud.dart';
import 'package:soroban_app/problem_generation/aloud_set.dart';
import 'package:soroban_app/screens/components/keypad.dart';
import 'package:soroban_app/screens/flash_problem.dart';
import 'package:soroban_app/src/voicevox_paths.dart';
import 'package:soroban_app/src/voicevox_sing.dart';

class AloudProblemScreen extends StatefulWidget {
  const AloudProblemScreen({
    super.key,
    required this.paths,
    required this.isSingleProblem,
    required this.selectedLevel,
  });
  final VoicevoxPaths paths;
  final bool isSingleProblem;
  final AloudLevel selectedLevel;

  @override
  State<AloudProblemScreen> createState() => _AloudProblemScreenState();
}

class _AloudProblemScreenState extends State<AloudProblemScreen> {
  int _currentPageIndex = 0;
  int _currentProblemIndex = 0;
  String _userInputted = '';
  late final VoicevoxSing _singer;
  late final Future<Uint8List> _wavBytesFuture;
  late final KeypadSounds _sound;
  late final List<List<int>> _allProblems;
  late final List<String> _allAnswers;
  static const int _singingTeacher = 6000;
  late final List<String> _scores;
  bool _delayOver = false;

  void _initProblem(AloudSpec spec) {
    AloudProblemSet fullProblemSet = AloudProblemSet(spec: spec);
    _allProblems = fullProblemSet.unformattedProblems;
    _allAnswers = fullProblemSet.formattedAnswers;
    _scores = _initScore();
  }

  List<String> _initScore() {
    List<String> scores = [];
    for (List<int> unformattedProblem in _allProblems) {
      List<Mora> problemMora = scoreMora(unformattedProblem);
      scores.add(moraListToJson(moraList: problemMora, targetSeconds: 19));
    }
    return scores;
  }

  @override
  void initState() {
    super.initState();
    _singer = VoicevoxSing(
      dictDir: widget.paths.dictDir,
      vvmPath: '${widget.paths.vvmDir}/s0.vvm',
    );
    _initProblem(widget.selectedLevel);
    _sound = KeypadSounds();
    _sound.init();
    _wavBytesFuture = Future(() {
      _singer.initialize();
      return _singer.synthesizeWithF0(
        scoreJson: _scores[0],
        singingTeacherStyleId: _singingTeacher,
        singerStyleId: 3024,
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
    _singer.dispose();
  }

  Widget _buildPage(
    int index,
    Size screenSize,
    bool isPortrait,
    bool isCorrect,
  ) {
    switch (index) {
      case 0:
        return AloudProblem(wavBytesFuture: _wavBytesFuture);
      case 1:
        return Placeholder();
      case 2:
        return Placeholder();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final Size screenSize = media.size;
    final bool isPortrait = media.orientation == Orientation.portrait;
    final bool isCorrect = _userInputted == _allAnswers[_currentProblemIndex];

    return FlashAndAloudProblemData(
      screenSize: screenSize,
      isPortrait: isPortrait,
      currentProblemIndex: _currentProblemIndex,
      allAnswers: _allAnswers,
      allProblems: _allProblems,
      child: Scaffold(
        body: PageTransitionSwitcher(
          duration: const Duration(milliseconds: 300),
          reverse: _currentPageIndex == 0,
          transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
            return FadeThroughTransition(
              animation: primaryAnimation,
              secondaryAnimation: secondaryAnimation,
              fillColor: Colors.black, // Add this
              child: child,
            );
          },
          child: _buildPage(
            _currentPageIndex,
            screenSize,
            isPortrait,
            isCorrect,
          ),
        ),
      ),
    );
  }
}

class AloudProblem extends StatefulWidget {
  const AloudProblem({super.key, required this.wavBytesFuture});
  final Future<Uint8List> wavBytesFuture;

  @override
  State<AloudProblem> createState() => _AloudProblemState();
}

class _AloudProblemState extends State<AloudProblem> {
  bool _isPlaying = false;
  SoundHandle? _soundHandle;

  Future<void> _play(Uint8List wavBytes) async {
    if (_isPlaying) {
      await SoLoud.instance.stop(_soundHandle!);
      setState(() => _isPlaying = false);
      return;
    }
    final source = await SoLoud.instance.loadMem('voicevox_out.wav', wavBytes);
    source.filters.pitchShiftFilter.activate();
    final handle = await SoLoud.instance.play(source);
    source.filters.pitchShiftFilter.shift(soundHandle: handle).value = 0.8;
    SoLoud.instance.setRelativePlaySpeed(handle, 1.2);
    setState(() {
      _soundHandle = handle;
      _isPlaying = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: widget.wavBytesFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        return Column(
          children: [
            IconButton(
              iconSize: 64,
              icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
              onPressed: () => _play(snapshot.data!),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}

class F0Graph extends StatelessWidget {
  const F0Graph({super.key, required this.f0});
  final List<double> f0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: CustomPaint(
        painter: _F0Painter(f0: f0),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _F0Painter extends CustomPainter {
  final List<double> f0;
  _F0Painter({required this.f0});

  @override
  void paint(Canvas canvas, Size size) {
    if (f0.isEmpty) return;

    final nonZero = f0.where((v) => v > 0);
    if (nonZero.isEmpty) return;

    final minF0 = nonZero.reduce(min);
    final maxF0 = nonZero.reduce(max);
    final range = maxF0 - minF0;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final silencePaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 2;

    for (int i = 0; i < f0.length - 1; i++) {
      final x1 = size.width * i / (f0.length - 1);
      final x2 = size.width * (i + 1) / (f0.length - 1);

      if (f0[i] == 0 || f0[i + 1] == 0) {
        // Draw silence as flat line at bottom
        canvas.drawLine(
          Offset(x1, size.height),
          Offset(x2, size.height),
          silencePaint,
        );
        continue;
      }

      final y1 = size.height - (size.height * (f0[i] - minF0) / range);
      final y2 = size.height - (size.height * (f0[i + 1] - minF0) / range);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  @override
  bool shouldRepaint(_F0Painter old) => old.f0 != f0;
}
