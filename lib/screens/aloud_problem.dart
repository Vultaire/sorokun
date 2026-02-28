import 'dart:async';
import 'dart:isolate';
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
  late final Future<Uint8List> _wavBytesFuture;
  late final KeypadSounds _sound;
  late final List<List<int>> _allProblems;
  late final List<String> _allAnswers;
  static const int _singingTeacher = 6000;
  late final List<List<String>> _scores;
  bool _delayOver = false;
  late final Stream<Uint8List> _chunkStream;
  List<Uint8List> _wavChunks = [];
  StreamSubscription<Uint8List>? _chunkSubscription;

  void _initProblem(AloudSpec spec) {
    AloudProblemSet fullProblemSet = AloudProblemSet(spec: spec);
    _allProblems = fullProblemSet.unformattedProblems;
    _allAnswers = fullProblemSet.formattedAnswers;
    _scores = _initScore();
  }

  List<List<String>> _initScore() {
    List<List<String>> scores = [];
    for (List<int> unformattedProblem in _allProblems) {
      List<Mora> problemMora = scoreMora(unformattedProblem);
      scores.add(
        moraListToJsonChunks(
          moraList: problemMora,
          speed: 4,
          msPerInterval: 1000,
        ),
      );
    }
    return scores;
  }

  Stream<Uint8List> _synthesizeChunks(
    List<String> scores,
    String dictDir,
    String vvmPath,
  ) async* {
    for (final score in scores) {
      yield await Isolate.run(() {
        final singer = VoicevoxSing(dictDir: dictDir, vvmPath: vvmPath);
        singer.initialize();
        return speedUpWav(
          singer.synthesizeWithF0(
            scoreJson: score,
            singingTeacherStyleId: _singingTeacher,
            singerStyleId: 3029,
            keyRangeAdjustment: 2,
          ),
          1.2,
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _initProblem(widget.selectedLevel);
    _sound = KeypadSounds();
    _sound.init();

    final dictDir = widget.paths.dictDir;
    final vvmPath = '${widget.paths.vvmDir}/s0.vvm';
    final scores = _scores[0];
    print(scores);

    _wavChunks = [];
    _chunkStream = _synthesizeChunks(scores, dictDir, vvmPath);
    _chunkSubscription = _chunkStream.listen((chunk) {
      setState(() => _wavChunks.add(chunk));
    });
  }

  @override
  void dispose() {
    _chunkSubscription?.cancel();
    super.dispose();
  }

  Widget _buildPage(
    int index,
    Size screenSize,
    bool isPortrait,
    bool isCorrect,
  ) {
    switch (index) {
      case 0:
        return AloudProblem(chunks: _wavChunks, chunkStream: _chunkStream);
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
        appBar: AppBar(title: Text('Aloud Problem')),
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
  const AloudProblem({
    super.key,
    required this.chunks,
    required this.chunkStream,
  });
  final List<Uint8List> chunks;
  final Stream<Uint8List> chunkStream;

  @override
  State<AloudProblem> createState() => _AloudProblemState();
}

class _AloudProblemState extends State<AloudProblem> {
  bool _isPlaying = false;
  int _currentChunk = 0;

  SoundHandle? _currentHandle;
  AudioSource? _currentSource;

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    if (_currentHandle != null) {
      SoLoud.instance.stop(_currentHandle!);
    }
    if (_currentSource != null) {
      SoLoud.instance.disposeSource(_currentSource!);
    }
    super.dispose();
  }

  Future<void> _playNextChunk() async {
    if (_disposed || !_isPlaying || _currentChunk >= widget.chunks.length) {
      if (!_disposed)
        setState(() {
          _isPlaying = false;
          _currentChunk = 0;
        });
      return;
    }

    final source = await SoLoud.instance.loadMem(
      'chunk_$_currentChunk.wav',
      widget.chunks[_currentChunk],
    );

    if (_disposed) {
      SoLoud.instance.disposeSource(source);
      return;
    }

    _currentSource = source;
    final handle = await SoLoud.instance.play(source);
    _currentHandle = handle;

    final duration = SoLoud.instance.getLength(source);
    _currentChunk++;

    Future.delayed(duration, () async {
      await SoLoud.instance.disposeSource(source);
      if (!_disposed && _isPlaying) _playNextChunk();
    });
  }

  Future<void> _play() async {
    if (_isPlaying) {
      if (_currentHandle != null) {
        await SoLoud.instance.stop(_currentHandle!);
      }
      setState(() {
        _isPlaying = false;
        _currentChunk = 0;
      });
      return;
    }
    setState(() {
      _isPlaying = true;
      _currentChunk = 0;
    });
    _playNextChunk();
  }

  @override
  Widget build(BuildContext context) {
    final hasFirstChunk = widget.chunks.isNotEmpty;
    return Column(
      children: [
        IconButton(
          iconSize: 64,
          icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
          onPressed: hasFirstChunk ? _play : null,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

Uint8List speedUpWav(Uint8List wavBytes, double speed) {
  final byteData = ByteData.sublistView(wavBytes);
  final numChannels = byteData.getUint16(22, Endian.little);
  final sampleRate = byteData.getUint32(24, Endian.little);
  final bitsPerSample = byteData.getUint16(34, Endian.little);
  final bytesPerSample = bitsPerSample ~/ 8;
  final blockAlign = numChannels * bytesPerSample;

  final audioData = wavBytes.sublist(44);
  final totalFrames = audioData.length ~/ blockAlign;

  // Read all samples interleaved
  final samples = Int16List(totalFrames * numChannels);
  for (int i = 0; i < samples.length; i++) {
    samples[i] = byteData.getInt16(44 + i * bytesPerSample, Endian.little);
  }

  // WSOLA parameters — larger window reduces buzzing
  final windowFrames = (sampleRate * 0.08).round(); // 80ms window
  final outputHop = (sampleRate * 0.04).round(); // 40ms hop (50% overlap)
  final inputHop = (outputHop * speed).round();
  final searchRadius = (sampleRate * 0.02).round(); // 20ms search

  // Hann window
  final window = Float64List(windowFrames);
  for (int i = 0; i < windowFrames; i++) {
    window[i] = 0.5 * (1 - cos(2 * pi * i / (windowFrames - 1)));
  }

  final estimatedOutputFrames = (totalFrames / speed).ceil() + windowFrames * 2;
  final output = Float64List(estimatedOutputFrames * numChannels);
  final normalization = Float64List(estimatedOutputFrames * numChannels);

  // Cross-correlation on channel 0 only, but compare against the
  // *normalized* output so far (i.e. what the waveform actually looks like)
  int findBestOffset(int inputPos, int outputPos) {
    double bestCorr = double.negativeInfinity;
    int bestOffset = 0;

    for (int offset = -searchRadius; offset <= searchRadius; offset++) {
      final candidatePos = inputPos + offset;
      if (candidatePos < 0 || candidatePos + windowFrames > totalFrames)
        continue;

      double corr = 0;
      for (int frame = 0; frame < windowFrames; frame++) {
        final outIdx = (outputPos + frame) * numChannels;
        final inIdx = (candidatePos + frame) * numChannels;
        if (outIdx >= output.length) break;

        // Normalize the output sample before correlating
        final norm = normalization[outIdx] > 0 ? normalization[outIdx] : 1.0;
        final outSample = output[outIdx] / norm;
        corr += outSample * samples[inIdx];
      }

      if (corr > bestCorr) {
        bestCorr = corr;
        bestOffset = offset;
      }
    }
    return bestOffset;
  }

  int inputPos = 0;
  int outputPos = 0;

  while (inputPos + windowFrames <= totalFrames) {
    final offset = outputPos == 0 ? 0 : findBestOffset(inputPos, outputPos);
    final alignedInput = (inputPos + offset).clamp(
      0,
      totalFrames - windowFrames,
    );

    for (int frame = 0; frame < windowFrames; frame++) {
      final w = window[frame];
      for (int ch = 0; ch < numChannels; ch++) {
        final inIdx = (alignedInput + frame) * numChannels + ch;
        final outIdx = (outputPos + frame) * numChannels + ch;
        if (inIdx >= samples.length || outIdx >= output.length) continue;
        output[outIdx] += samples[inIdx] * w;
        normalization[outIdx] += w;
      }
    }

    inputPos += inputHop;
    outputPos += outputHop;
  }

  // Normalize and convert back to Int16
  final outFrameCount = outputPos + windowFrames;
  final outSamples = Int16List(outFrameCount * numChannels);
  for (int i = 0; i < outSamples.length; i++) {
    if (i >= output.length) break;
    final norm = normalization[i] > 0 ? normalization[i] : 1.0;
    outSamples[i] = (output[i] / norm).round().clamp(-32768, 32767);
  }

  // Rebuild WAV
  final newAudioBytes = outSamples.buffer.asUint8List();
  final newFileSize = 44 + newAudioBytes.length;
  final outputWav = Uint8List(newFileSize);
  outputWav.setRange(0, 44, wavBytes);
  final outByteData = ByteData.sublistView(outputWav);
  outByteData.setUint32(4, newFileSize - 8, Endian.little);
  outByteData.setUint32(40, newAudioBytes.length, Endian.little);
  outputWav.setRange(44, newFileSize, newAudioBytes);
  return outputWav;
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
