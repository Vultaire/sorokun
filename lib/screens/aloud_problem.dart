import 'dart:async';
import 'package:async/async.dart';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:go_router/go_router.dart';
import 'package:soroban_app/main.dart';
import 'package:soroban_app/models/level_definitions.dart';
import 'package:soroban_app/models/singer_config.dart';
import 'package:soroban_app/problem_generation/aloud.dart';
import 'package:soroban_app/problem_generation/aloud_set.dart';
import 'package:soroban_app/screens/components/keypad.dart';
import 'package:soroban_app/screens/flash_problem.dart';
import 'package:soroban_app/src/voicevox_sing.dart';

class AloudProblemScreen extends StatefulWidget {
  const AloudProblemScreen({
    super.key,
    required this.isSingleProblem,
    required this.selectedLevel,
    required this.character,
  });
  final bool isSingleProblem;
  final AloudSpec selectedLevel;
  final Character character;

  @override
  State<AloudProblemScreen> createState() => _AloudProblemScreenState();
}

class _AloudProblemScreenState extends State<AloudProblemScreen> {
  int _currentPageIndex = 0;
  int _currentProblemIndex = 0;
  final Stopwatch _stopwatch = Stopwatch();
  late List<List<int>> _allProblems;
  late List<String> _allAnswers;
  late List<TextFieldData> _textFieldDataList;
  late List<List<String>> _scores;
  late final String dictDir;
  late final String vvmPath;
  late String _inputTime;
  bool _delayOver = false;
  Stream<Uint8List>? _chunkStream;
  StreamSubscription? _chunkSubscription;
  final List<Uint8List> _wavChunks = [];
  final Stopwatch _genStopwatch = Stopwatch();
  bool _readyToPlay = false;
  int? _totalChunksExpected;
  Timer? _readyTimer;
  List<Uint8List> _previousWavChunks = [];
  bool _isRepeat = false;

  void _initProblems() {
    AloudProblemSet fullProblemSet = AloudProblemSet(
      spec: widget.selectedLevel,
    );
    _allProblems = fullProblemSet.unformattedProblems;
    _allAnswers = fullProblemSet.formattedAnswers;
    _textFieldDataList = List.generate(
      _allAnswers.length,
      (_) => TextFieldData(),
    );
    _scores = _initScore();
  }

  void _initSingleProblem() {
    final AloudProblemSet problemSet = AloudProblemSet(
      spec: widget.selectedLevel,
    );
    final List<int> problem = problemSet.unformattedProblems.first;
    final String answer = problemSet.formattedAnswers.first;
    final List<Mora> problemMora = scoreMora(problem);
    final List<String> score = moraListToJsonChunks(
      moraList: problemMora,
      moraPerSecond: widget.selectedLevel.moraPerSecond,
      msPerInterval: widget.selectedLevel.msPerInterval,
      baseNote: widget.character.baseNote,
    );

    _allProblems = [problem];
    _allAnswers = [answer];
    _scores = [score];
    _textFieldDataList = [TextFieldData()];
    _currentProblemIndex = 0;
  }

  List<List<String>> _initScore() {
    List<List<String>> scores = [];
    for (List<int> unformattedProblem in _allProblems) {
      List<Mora> problemMora = scoreMora(unformattedProblem);
      scores.add(
        moraListToJsonChunks(
          moraList: problemMora,
          moraPerSecond: widget.selectedLevel.moraPerSecond,
          msPerInterval: widget.selectedLevel.msPerInterval,
          baseNote: widget.character.baseNote,
        ),
      );
    }
    return scores;
  }

  Isolate? _synthIsolate;

  Stream<Uint8List> _synthesizeChunks(List<String> scores) async* {
    final mainReceivePort = ReceivePort();
    _synthIsolate = await Isolate.spawn(
      _synthWorkerEntry,
      mainReceivePort.sendPort,
    );

    final events = StreamQueue<dynamic>(mainReceivePort);

    // First message from the worker is its SendPort.
    final workerSendPort = await events.next as SendPort;

    // Send init args (dictDir/vvmPath) — triggers the one-time dictionary load.
    workerSendPort.send([dictDir, vvmPath]);

    // Now request each chunk in order and await its result before requesting
    // the next — this keeps memory bounded and preserves chunk ordering.
    for (final score in scores) {
      workerSendPort.send(
        _SynthRequest(
          scoreJson: score,
          speed: 1.6,
          character: widget.character,
        ),
      );
      final result = await events.next as Uint8List;
      yield result;
    }

    workerSendPort.send(const _SynthDone());
    await events.cancel();
    mainReceivePort.close();
    _synthIsolate = null;
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

    if (_isRepeat) {
      return;
    }

    _previousWavChunks = List<Uint8List>.of(_wavChunks);

    if (widget.isSingleProblem) {
      _appendNewProblem();
    }
    _resetChunkGeneration(_scores[_currentProblemIndex + 1]);
  }

  void setInputAndShowResult() {
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

  void repeatProblem() {
    _isRepeat = true;
    playProblem();
  }

  void startNextProblem() {
    _currentProblemIndex++;
    _isRepeat = false;
    playProblem();
  }

  void playProblem() {
    setState(() {
      _currentPageIndex = 0;
      _delayOver = false;
    });
  }

  void newProblem() {
    _isRepeat = false;
    playProblem();
  }

  void _appendNewProblem() {
    final AloudProblemSet newProblemSet = AloudProblemSet(
      spec: widget.selectedLevel,
    );
    final List<int> newProblem = newProblemSet.unformattedProblems.first;
    final String newAnswer = newProblemSet.formattedAnswers.first;
    final List<Mora> problemMora = scoreMora(newProblem);
    final List<String> newScore = moraListToJsonChunks(
      moraList: problemMora,
      moraPerSecond: widget.selectedLevel.moraPerSecond,
      msPerInterval: widget.selectedLevel.msPerInterval,
      baseNote: widget.character.baseNote,
    );

    _allProblems.add(newProblem);
    _allAnswers.add(newAnswer);
    _scores.add(newScore);
    _textFieldDataList.add(TextFieldData());

    // Keep only [current, next]. currentProblemIndex is always 0 in
    // single-problem mode — it never needs adjusting, since trimming
    // from the front just promotes "next" into the "current" slot.
    const maxKept = 2;
    while (_allProblems.length > maxKept) {
      _allProblems.removeAt(0);
      _allAnswers.removeAt(0);
      _scores.removeAt(0);
      _textFieldDataList.removeAt(0);
    }
    _currentProblemIndex = 0;
  }

  void showResults() {
    context.go(
      '/paper-results',
      extra: {
        'selectedLevel': widget.selectedLevel,
        'isExam': true,
        'allProblems': _allProblems,
        'allAnswers': _allAnswers,
        'textFieldDataList': _textFieldDataList,
      },
    );
  }

  Duration _wavDuration(Uint8List wavBytes) {
    final data = ByteData.sublistView(wavBytes);
    final numChannels = data.getUint16(22, Endian.little);
    final sampleRate = data.getUint32(24, Endian.little);
    final bitsPerSample = data.getUint16(34, Endian.little);
    final dataSize = data.getUint32(40, Endian.little);
    final byteRate = sampleRate * numChannels * (bitsPerSample ~/ 8);
    if (byteRate == 0) return Duration.zero;
    final seconds = dataSize / byteRate;
    return Duration(milliseconds: (seconds * 1000).round());
  }

  void _resetChunkGeneration(List<String> scores) {
    _chunkSubscription?.cancel();
    _readyTimer?.cancel();
    _synthIsolate?.kill(priority: Isolate.immediate);
    _synthIsolate = null;
    _wavChunks.clear();
    _readyToPlay = false;
    _genStopwatch
      ..reset()
      ..start();
    _chunkStream = _synthesizeChunks(scores);
    _chunkSubscription = _chunkStream!.listen(
      _onChunkReceived,
      onDone: () {
        if (mounted && !_readyToPlay) {
          setState(() => _readyToPlay = true);
        }
      },
    );
  }

  void _onChunkReceived(Uint8List chunk) {
    final isFirstChunk = _wavChunks.isEmpty;
    setState(() => _wavChunks.add(chunk));
    if (!isFirstChunk) return;

    final g = _genStopwatch.elapsedMilliseconds; // time to generate chunk 1
    final playDuration = _wavDuration(chunk);
    final d = playDuration.inMilliseconds;
    final n = _totalChunksExpected ?? 1;

    print('[chunkReady] genTime=${g}ms playDuration=${d}ms totalChunks=$n');

    if (d <= 0) {
      print(
        '[chunkReady] could not parse WAV duration, falling back to onDone',
      );
      return; // couldn't parse duration; fall back to onDone
    }

    if (g <= d) {
      // Generation is at least real-time — safe right now.
      print('[chunkReady] g <= d, unlocking immediately (no wait)');
      setState(() => _readyToPlay = true);
      return;
    }

    // Worst-case lead time needed, per the derivation above, is driven
    // by the last chunk: s_min = N*G - (N-1)*D.
    final requiredLeadMs = (n * g - (n - 1) * d).round();
    final remainingWaitMs = requiredLeadMs - g; // g ms have already elapsed

    print(
      '[chunkReady] g > d, requiredLeadMs=$requiredLeadMs '
      '(elapsed so far=${g}ms) -> remainingWaitMs=$remainingWaitMs',
    );

    if (remainingWaitMs <= 0) {
      print('[chunkReady] remainingWaitMs <= 0, unlocking immediately');
      setState(() => _readyToPlay = true);
    } else {
      print('[chunkReady] scheduling unlock timer for ${remainingWaitMs}ms');
      _readyTimer = Timer(Duration(milliseconds: remainingWaitMs), () {
        if (mounted && !_readyToPlay) {
          print(
            '[chunkReady] timer fired after ${remainingWaitMs}ms, unlocking',
          );
          setState(() => _readyToPlay = true);
        } else {
          print(
            '[chunkReady] timer fired but already ready or unmounted, skipping',
          );
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    dictDir = VoicevoxService.paths.dictDir;
    vvmPath = '${VoicevoxService.paths.vvmDir}/s0.vvm';
    if (widget.isSingleProblem) {
      _initSingleProblem();
    } else {
      _initProblems();
    }
    _resetChunkGeneration(_scores[0]);
  }

  @override
  void dispose() {
    _chunkSubscription?.cancel();
    _readyTimer?.cancel();
    _synthIsolate?.kill(priority: Isolate.immediate);
    super.dispose();
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return AloudProblem(
          chunks: _isRepeat ? _previousWavChunks : _wavChunks,
          chunkStream: _isRepeat ? null : _chunkStream,
          onComplete: showInput,
          readyToPlay: _isRepeat ? true : _readyToPlay,
        );
      case 1:
        return FlashAndAloudProblemInput<int>(
          showResult: setInputAndShowResult,
          showTimer: !widget.isSingleProblem,
          delayOver: _delayOver,
          duration: 29500,
          maxDigits: 16,
        );
      case 2:
        return FlashAndAloudResult<int>(
          onNextProblem: startNextProblem,
          onRepeatProblem: repeatProblem,
          onNewProblem: newProblem,
          onShowResults: showResults,
          inputTime: _inputTime,
          isSingleProblem: widget.isSingleProblem,
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

    return FlashAndAloudProblemData<int>(
      screenSize: screenSize,
      isPortrait: isPortrait,
      currentProblemIndex: _currentProblemIndex,
      allAnswers: _allAnswers,
      allProblems: _allProblems,
      textFieldDataList: _textFieldDataList,
      child: Scaffold(
        appBar: AppBar(title: Text('Aloud Problem')),
        body: PageTransitionSwitcher(
          duration: const Duration(milliseconds: 300),
          reverse: _currentPageIndex == 0,
          transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
            return FadeThroughTransition(
              animation: primaryAnimation,
              secondaryAnimation: secondaryAnimation,
              fillColor: Colors.black,
              child: child,
            );
          },
          child: _buildPage(_currentPageIndex),
        ),
      ),
    );
  }
}

// Messages sent TO the worker isolate
class _SynthRequest {
  final String scoreJson;
  final double speed;
  final Character character;
  const _SynthRequest({
    required this.scoreJson,
    required this.speed,
    required this.character,
  });
}

// Sentinel to tell the worker there's no more work
class _SynthDone {
  const _SynthDone();
}

void _synthWorkerEntry(SendPort mainSendPort) async {
  final workerReceivePort = ReceivePort();
  mainSendPort.send(workerReceivePort.sendPort);

  VoicevoxSing? singer; // null until init message arrives

  workerReceivePort.listen((message) async {
    if (singer == null) {
      // First message we receive must be the init args.
      final initArgs = message as List<String>;
      final dictDir = initArgs[0];
      final vvmPath = initArgs[1];
      singer = VoicevoxSing(dictDir: dictDir, vvmPath: vvmPath);
      singer!.initialize();
      return;
    }

    if (message is _SynthRequest) {
      final wav = singer!.synthesizeWithF0(
        scoreJson: message.scoreJson,
        character: message.character,
      );
      final sped = speedUpWav(wav, message.speed);
      mainSendPort.send(sped);
    } else if (message is _SynthDone) {
      workerReceivePort.close();
      Isolate.exit();
    }
  });
}

class AloudProblem extends StatefulWidget {
  const AloudProblem({
    super.key,
    required this.chunks,
    required this.chunkStream,
    required this.onComplete,
    required this.readyToPlay,
  });
  final List<Uint8List> chunks;
  final Stream<Uint8List>? chunkStream;
  final VoidCallback onComplete;
  final bool readyToPlay;

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
    return Center(
      child: Column(
        children: [
          IconButton(
            iconSize: 64,
            icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
            onPressed: widget.readyToPlay ? _play : null,
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
