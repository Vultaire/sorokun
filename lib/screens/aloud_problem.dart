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
    this.examDisplayString,
  });
  final bool isSingleProblem;
  final AloudSpec selectedLevel;
  final Character character;
  final String? examDisplayString;

  @override
  State<AloudProblemScreen> createState() => _AloudProblemScreenState();
}

class _AloudProblemScreenState extends State<AloudProblemScreen> {
  int _currentPageIndex = 0;
  int _currentProblemIndex = 0;
  final Stopwatch _stopwatch = Stopwatch();
  late List<List<int>> _allProblems;
  late List<String> _allAnswers;
  late List<List<String>> _allFormattedProblems;
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
    _allFormattedProblems = fullProblemSet.formattedProblems;
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
        'allProblems': _allFormattedProblems,
        'allAnswers': _allAnswers,
        'textFieldDataList': _textFieldDataList,
        'character': widget.character,
        'examDisplayString': widget.examDisplayString,
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
    const negaimasitehaTime = 2.3;

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
    final requiredLeadMs = ((n * g - (n - 1) * d) - negaimasitehaTime).round();
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
          onComplete: showInput,
          readyToPlay: _isRepeat ? true : _readyToPlay,
          negaimasitehaPath: widget.character.negaimasiteha,
          isSingleProblem: widget.isSingleProblem,
          msPerInterval: widget.selectedLevel.msPerInterval,
        );
      case 1:
        return FlashAndAloudProblemInput<int>(
          showResult: setInputAndShowResult,
          showTimer: !widget.isSingleProblem,
          delayOver: _delayOver,
          duration: 29500,
          maxDigits: 17,
        );
      case 2:
        return FlashAndAloudResult<int>(
          onNextProblem: startNextProblem,
          onRepeatProblem: repeatProblem,
          onNewProblem: newProblem,
          onShowResults: showResults,
          inputTime: _inputTime,
          isSingleProblem: widget.isSingleProblem,
          homeRoute: '/aloud-level-menu',
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
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(
            MediaQuery.of(context).orientation == Orientation.landscape
                ? 40
                : kToolbarHeight,
          ),
          child: AppBar(
            title: const Text('読み上げ算'),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () async {
                await showExitDialog(
                  context,
                  homeRoute: '/aloud-level-menu',
                  onSubmit: showResults,
                );
              },
            ),
          ),
        ),
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
    required this.onComplete,
    required this.readyToPlay,
    required this.negaimasitehaPath,
    required this.isSingleProblem,
    required this.msPerInterval,
  });

  final List<Uint8List> chunks;
  final VoidCallback onComplete;
  final bool readyToPlay;
  final String negaimasitehaPath;
  final bool isSingleProblem;
  final int msPerInterval;

  @override
  State<AloudProblem> createState() => _AloudProblemState();
}

class _AloudProblemState extends State<AloudProblem> {
  bool _isPlaying = false;
  bool _isPressed = false;
  bool _isCompleted = false;
  bool _disposed = false;
  int _playSession = 0;

  Timer? _playbackMonitorTimer;

  int _scheduledChunkCount = 0;
  Duration _timelineCursor = Duration.zero;
  SoundHandle? _lastScheduledHandle;

  final List<SoundHandle> _scheduledHandles = [];
  final List<AudioSource> _activeSources = [];

  @override
  void dispose() {
    _disposed = true;
    _stopPlayback();
    super.dispose();
  }

  void _stopPlayback() {
    _playSession++;
    _playbackMonitorTimer?.cancel();
    _playbackMonitorTimer = null;

    _scheduledChunkCount = 0;
    _lastScheduledHandle = null;

    for (final handle in _scheduledHandles) {
      if (SoLoud.instance.getIsValidVoiceHandle(handle)) {
        SoLoud.instance.stop(handle);
      }
    }
    _scheduledHandles.clear();

    for (final source in _activeSources) {
      SoLoud.instance.disposeSource(source);
    }
    _activeSources.clear();
  }

  Future<void> _play() async {
    if (_isPlaying) {
      _stopPlayback();
      setState(() {
        _isPlaying = false;
      });
      return;
    }

    if (!widget.readyToPlay && widget.chunks.isEmpty) {
      return;
    }

    _stopPlayback();
    final session = ++_playSession;

    setState(() {
      _isPlaying = true;
      _isCompleted = false;
    });

    try {
      // 1. Load & Schedule Preamble (negaimasiteha)
      final preambleSource = await SoLoud.instance.loadAsset(
        widget.negaimasitehaPath,
      );
      if (_disposed || session != _playSession) {
        await SoLoud.instance.disposeSource(preambleSource);
        return;
      }
      _activeSources.add(preambleSource);

      final preambleDuration = SoLoud.instance.getLength(preambleSource);
      final engineNow = SoLoud.instance.getEngineTime();

      _timelineCursor = engineNow + const Duration(milliseconds: 50);

      final preambleHandle = SoLoud.instance.playScheduled(
        preambleSource,
        _timelineCursor,
      );
      _scheduledHandles.add(preambleHandle);
      _lastScheduledHandle = preambleHandle;

      _timelineCursor += preambleDuration;

      // 2. Schedule any chunks already available in widget.chunks
      await _schedulePendingChunks(session);

      // 3. Start monitoring for newly arrived stream chunks and handle completion
      _startPlaybackMonitor(session);
    } catch (e, stack) {
      print('[_play] Playback error: $e\n$stack');
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
      _stopPlayback();
    }
  }

  Future<void> _schedulePendingChunks(int session) async {
    while (_scheduledChunkCount < widget.chunks.length) {
      if (_disposed || session != _playSession) return;

      final chunkIndex = _scheduledChunkCount;
      final chunkBytes = widget.chunks[chunkIndex];

      final source = await SoLoud.instance.loadMem(
        'chunk_${session}_$chunkIndex.wav',
        chunkBytes,
      );

      if (_disposed || session != _playSession) {
        await SoLoud.instance.disposeSource(source);
        return;
      }

      _activeSources.add(source);
      final duration = SoLoud.instance.getLength(source);

      // Apply msPerInterval ONLY for subsequent chunks (chunkIndex > 0)
      if (chunkIndex > 0) {
        _timelineCursor += Duration(milliseconds: widget.msPerInterval);
      }

      final chunkHandle = SoLoud.instance.playScheduled(
        source,
        _timelineCursor,
      );

      _scheduledHandles.add(chunkHandle);
      _lastScheduledHandle = chunkHandle;

      _timelineCursor += duration;
      _scheduledChunkCount++;
    }
  }

  void _startPlaybackMonitor(int session) {
    _playbackMonitorTimer = Timer.periodic(const Duration(milliseconds: 100), (
      timer,
    ) async {
      if (_disposed || session != _playSession) {
        timer.cancel();
        return;
      }

      // Automatically schedule any new chunks added to widget.chunks by the parent stream
      if (_scheduledChunkCount < widget.chunks.length) {
        await _schedulePendingChunks(session);
      }

      final finalHandle = _lastScheduledHandle;
      if (finalHandle == null) return;

      final isValid = SoLoud.instance.getIsValidVoiceHandle(finalHandle);

      // Trigger completion ONLY when:
      // 1. The last scheduled handle has finished playing (!isValid)
      // 2. All chunks currently in widget.chunks have been scheduled
      if (!isValid && _scheduledChunkCount >= widget.chunks.length) {
        timer.cancel();

        // 300ms buffer for hardware audio output buffer flush
        Future.delayed(const Duration(milliseconds: 300), () {
          if (_disposed || session != _playSession) return;

          if (mounted) {
            setState(() {
              _isPlaying = false;
              _isCompleted = true;
            });
          }

          for (final source in List<AudioSource>.from(_activeSources)) {
            SoLoud.instance.disposeSource(source);
          }
          _activeSources.clear();
          _scheduledHandles.clear();

          widget.onComplete();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget icon;
    VoidCallback? onPressed;

    if (!_isCompleted && !widget.readyToPlay) {
      icon = const SizedBox(
        width: 40,
        height: 40,
        child: CircularProgressIndicator(strokeWidth: 4),
      );
      onPressed = null;
    } else if (_isCompleted || _isPlaying) {
      icon = widget.isSingleProblem
          ? const Icon(Icons.replay, size: 64)
          : const Icon(Icons.volume_up, size: 64);
      onPressed = (_isCompleted || !widget.isSingleProblem) ? null : _play;
    } else {
      icon = const Icon(Icons.play_arrow, size: 64);
      onPressed = _play;
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTapDown: onPressed == null
                ? null
                : (_) => setState(() => _isPressed = true),
            onTapUp: onPressed == null
                ? null
                : (_) {
                    setState(() => _isPressed = false);
                    onPressed!();
                  },
            onTapCancel: () => setState(() => _isPressed = false),
            child: AnimatedScale(
              scale: _isPressed ? 0.9 : 1.0,
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOut,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.surfaceContainerHighest,
                ),
                child: Center(child: icon),
              ),
            ),
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
