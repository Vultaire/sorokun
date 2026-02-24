import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:soroban_app/models/level_definitions.dart';
import 'package:soroban_app/problem_generation/mitori.dart';
import 'package:soroban_app/problem_generation/mitori_set.dart';
import 'package:soroban_app/screens/components/keypad.dart';
import 'package:soroban_app/src/voicevox_paths.dart';
import 'package:soroban_app/src/voicevox_sing.dart';

class AloudProblemScreen extends StatefulWidget {
  const AloudProblemScreen({
    super.key,
    required this.paths,
    required this.selectedLevel,
  });
  final VoicevoxPaths paths;
  final MitoriLevel selectedLevel;

  @override
  State<AloudProblemScreen> createState() => _AloudProblemScreenState();
}

class _AloudProblemScreenState extends State<AloudProblemScreen> {
  late final VoicevoxSing _singer;
  SoundHandle? _soundHandle;
  bool _isPlaying = false;
  late final Future<List<double>> _f0Future;
  late final KeypadSounds _sound;
  late final List<MitoriProblem> allProblems;
  late final List<String> allAnswers;
  static const int _singingTeacher = 6000;
  static const _score = '''
{
  "notes": [
    { "key": null, "frame_length": 15, "lyric": "" },
    { "key": 60, "frame_length": 45, "lyric": "ド" },
    { "key": 62, "frame_length": 45, "lyric": "レ" },
    { "key": 64, "frame_length": 45, "lyric": "ミ" },
    { "key": null, "frame_length": 15, "lyric": "" }
  ]
}
''';

  void _initializeProblem(MitoriLevel level) {
    MitoriProblemSet fullProblemSet = MitoriProblemSet(
      level: widget.selectedLevel,
    );
    allProblems = fullProblemSet.unformattedProblems;
    allAnswers = fullProblemSet.formattedAnswers;
  }

  @override
  void initState() {
    super.initState();
    _singer = VoicevoxSing(
      dictDir: widget.paths.dictDir,
      vvmPath: '${widget.paths.vvmDir}/s0.vvm',
    );
    _initializeProblem(widget.selectedLevel);
    _sound = KeypadSounds();
    _sound.init();
    _f0Future = Future(() {
      _singer.initialize();
      return _singer.getF0(
        scoreJson: _score,
        singingTeacherStyleId: _singingTeacher,
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
    _singer.dispose();
  }

  Future<void> _play() async {
    if (_isPlaying) {
      await SoLoud.instance.stop(_soundHandle!);
      setState(() => _isPlaying = false);
      return;
    }
    final wavBytes = await Future(
      () => _singer.synthesizeWithF0(
        scoreJson: _score,
        singingTeacherStyleId: _singingTeacher,
        singerStyleId: 3074,
      ),
    );
    final source = await SoLoud.instance.loadMem('voicevox_out.wav', wavBytes);
    final handle = await SoLoud.instance.play(source);
    setState(() {
      _soundHandle = handle;
      _isPlaying = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aloud Problem')),
      body: FutureBuilder<List<double>>(
        future: _f0Future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final f0 = snapshot.data!;

          return Column(
            children: [
              Expanded(child: F0Graph(f0: f0)),
              IconButton(
                iconSize: 64,
                icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
                onPressed: _play,
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
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
