import 'dart:async';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:soroban_app/models/level_definitions.dart';
import 'package:soroban_app/problem_generation/aloud.dart';
import 'package:soroban_app/problem_generation/aloud_set.dart';
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
  final Stopwatch _stopwatch = Stopwatch();
  late final List<List<int>> _allProblems;
  late final List<String> _allAnswers;
  late final List<List<String>> _scores;
  late final String dictDir;
  late final String vvmPath;
  late String _inputTime;
  bool _delayOver = false;
  Stream<Uint8List>? _chunkStream;
  StreamSubscription? _chunkSubscription;
  final List<Uint8List> _wavChunks = [];

  void _initProblems() {
    AloudProblemSet fullProblemSet = AloudProblemSet(
      spec: widget.selectedLevel,
    );
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
          speed: 3,
          msPerInterval: 1500,
        ),
      );
    }
    return scores;
  }

  Stream<Uint8List> _synthesizeChunks(List<String> scores) async* {
    for (final score in scores) {
      yield await Isolate.run(() {
        final singer = VoicevoxSing(dictDir: dictDir, vvmPath: vvmPath);
        singer.initialize();
        return speedUpWav(
          singer.synthesizeWithF0(
            scoreJson: score,
            singingTeacherStyleId: 6000,
            singerStyleId: 3029,
            keyRangeAdjustment: 2,
          ),
          1.3,
        );
      });
    }
  }

  void showInput() {
    _stopwatch.start();
    setState(() {
      _delayOver = true;
    });
    Future.delayed(Duration(milliseconds: 500)).then((_) {
      if (mounted) {
        setState(() {
          _currentPageIndex = 1;
        });
      }
    });
    _chunkSubscription?.cancel();
    _wavChunks.clear();
    _chunkStream = _synthesizeChunks(_scores[_currentProblemIndex + 1]);
    _chunkSubscription = _chunkStream!.listen((chunk) {
      setState(() => _wavChunks.add(chunk));
    });
  }

  void setInputAndShowResult(String userInputted) {
    _userInputted = userInputted;
    _stopwatch.stop();
    final elapsedSeconds = _stopwatch.elapsedMilliseconds / 1000;
    _inputTime = (!widget.isSingleProblem && elapsedSeconds > 30)
        ? '30.00'
        : elapsedSeconds.toStringAsFixed(2);
    setState(() {
      _currentPageIndex = 2;
    });
    _stopwatch.reset();
  }

  void startNextProblem() {
    _currentProblemIndex++;
    playProblem();
  }

  void playProblem() {
    setState(() {
      _currentPageIndex = 0;
      _delayOver = false;
    });
  }

  void newProblem() {
    _initProblems();
    playProblem();
  }

  @override
  void initState() {
    super.initState();
    dictDir = widget.paths.dictDir;
    vvmPath = '${widget.paths.vvmDir}/s0.vvm';
    _initProblems();

    final List<String> firstScore = _scores[0];

    _chunkStream = _synthesizeChunks(firstScore);
    _chunkSubscription = _chunkStream?.listen((chunk) {
      setState(() => _wavChunks.add(chunk));
    });
  }

  @override
  void dispose() {
    _chunkSubscription?.cancel();
    super.dispose();
  }

  Widget _buildPage(int index, bool isCorrect) {
    switch (index) {
      case 0:
        return AloudProblem(
          chunks: _wavChunks,
          chunkStream: _chunkStream,
          onComplete: showInput,
        );
      case 1:
        return FlashAndAloudProblemInput<int>(
          showResult: setInputAndShowResult,
          showTimer: !widget.isSingleProblem,
          delayOver: _delayOver,
          duration: 29500,
        );
      case 2:
        return FlashAndAloudResult<int>(
          onNextProblem: startNextProblem,
          onRepeatProblem: playProblem,
          onNewProblem: newProblem,
          inputTime: _inputTime,
          isCorrect: isCorrect,
          isSingleProblem: widget.isSingleProblem,
          answer: _allAnswers[_currentProblemIndex],
        );
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

    return FlashAndAloudProblemData<int>(
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
          child: _buildPage(_currentPageIndex, isCorrect),
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
    required this.onComplete,
  });
  final List<Uint8List> chunks;
  final Stream<Uint8List>? chunkStream;
  final VoidCallback onComplete;

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
      final completed =
          !_disposed && _isPlaying && _currentChunk >= widget.chunks.length;
      if (!_disposed) {
        setState(() {
          _isPlaying = false;
          _currentChunk = 0;
        });
        if (completed) {
          widget.onComplete.call();
        }
      }
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
    return Center(
      child: Column(
        children: [
          IconButton(
            iconSize: 64,
            icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
            onPressed: hasFirstChunk ? _play : null,
          ),
          const SizedBox(height: 16),
        ],
      ),
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
