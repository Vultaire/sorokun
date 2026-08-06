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
import 'package:soroban_app/screens/components/mitori_display.dart';
import 'package:soroban_app/screens/components/navigation_button.dart';
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
  SendPort? _workerSendPort;
  Completer<void>? _workerExitCompleter;
  bool _generationComplete = false;
  final ValueNotifier<String> debugStatus = ValueNotifier('idle');

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
    _allFormattedProblems = problemSet.formattedProblems;
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

  Future<dynamic> _nextNonLog(
    StreamQueue events, {
    required Duration timeout,
    required String label,
  }) async {
    while (true) {
      final msg = await events.next.timeout(
        timeout,
        onTimeout: () => throw TimeoutException('$label timed out'),
      );
      if (msg is _SynthLog) {
        debugStatus.value = msg.message; // safe here — this IS the main isolate
        continue;
      }
      return msg;
    }
  }

  Stream<Uint8List> _synthesizeChunks(List<String> scores) async* {
    final mainReceivePort = ReceivePort();
    final exitPort = ReceivePort();
    final errorPort = ReceivePort();
    final exitCompleter = Completer<void>();
    _workerExitCompleter = exitCompleter;
    exitPort.listen((_) {
      if (!exitCompleter.isCompleted) exitCompleter.complete();
      exitPort.close();
    });
    errorPort.listen((error) {
      debugStatus.value = '[isolate onError] $error'; // see below
    });

    await Isolate.spawn(
      _synthWorkerEntry,
      mainReceivePort.sendPort,
      onExit: exitPort.sendPort,
      onError: errorPort.sendPort,
    );
    final events = StreamQueue<dynamic>(mainReceivePort);

    debugStatus.value = 'Waiting for isolate handshake...';
    final workerSendPort =
        await _nextNonLog(
              events,
              timeout: const Duration(seconds: 10),
              label: 'Isolate handshake',
            )
            as SendPort;
    _workerSendPort = workerSendPort;

    debugStatus.value = 'Sending init args: dictDir=$dictDir vvmPath=$vvmPath';
    workerSendPort.send([dictDir, vvmPath]);

    debugStatus.value = 'Waiting for init confirmation...';
    final initResult = await _nextNonLog(
      events,
      timeout: const Duration(seconds: 15),
      label: 'VOICEVOX initialize()',
    );
    if (initResult is _SynthError) {
      debugStatus.value = 'INIT FAILED: ${initResult.message}';
      throw Exception(initResult.message);
    }
    debugStatus.value = 'Init OK, starting synthesis';

    try {
      for (final score in scores) {
        workerSendPort.send(
          _SynthRequest(
            scoreJson: score,
            speed: 1.6,
            character: widget.character,
          ),
        );
        final result = await _nextNonLog(
          events,
          timeout: const Duration(seconds: 15),
          label: 'Synth worker',
        );
        if (result is _SynthError) {
          debugStatus.value = 'SYNTH FAILED: ${result.message}';
          throw Exception(result.message);
        }
        debugStatus.value = 'Got chunk (${(result as Uint8List).length} bytes)';
        yield result;
      }
      workerSendPort.send(const _SynthDone());
      _generationComplete = true;
    } catch (e, st) {
      debugStatus.value = 'GENERATION FAILED: $e';
      workerSendPort.send(const _SynthDone());
      rethrow;
    } finally {
      await events.cancel();
      mainReceivePort.close();
      errorPort.close();
      _workerSendPort = null;
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

  void _appendNewProblem() {
    final AloudProblemSet newProblemSet = AloudProblemSet(
      spec: widget.selectedLevel,
    );
    final List<int> newProblem = newProblemSet.unformattedProblems.first;
    final String newAnswer = newProblemSet.formattedAnswers.first;
    final List<String> newFormattedProblem =
        newProblemSet.formattedProblems.first;
    final List<Mora> problemMora = scoreMora(newProblem);
    final List<String> newScore = moraListToJsonChunks(
      moraList: problemMora,
      moraPerSecond: widget.selectedLevel.moraPerSecond,
      msPerInterval: widget.selectedLevel.msPerInterval,
      baseNote: widget.character.baseNote,
    );

    _allProblems.add(newProblem);
    _allAnswers.add(newAnswer);
    _allFormattedProblems.add(newFormattedProblem);
    _scores.add(newScore);
    _textFieldDataList.add(TextFieldData());

    // Keep only [current, next]. currentProblemIndex is always 0 in
    // single-problem mode — it never needs adjusting, since trimming
    // from the front just promotes "next" into the "current" slot.
    const maxKept = 2;
    while (_allProblems.length > maxKept) {
      _allProblems.removeAt(0);
      _allAnswers.removeAt(0);
      _allFormattedProblems.removeAt(0);
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

  Future<void> _resetChunkGeneration(List<String> scores) async {
    _chunkSubscription?.cancel();
    _readyTimer?.cancel();
    _generationComplete = false;

    // Tell the old worker to clean up, then WAIT for it to actually exit
    // before spawning a new one — prevents two isolates racing for the
    // same native ONNX/VOICEVOX singleton.
    _workerSendPort?.send(const _SynthDone());
    if (_workerExitCompleter != null) {
      try {
        await _workerExitCompleter!.future.timeout(const Duration(seconds: 10));
      } catch (e) {
        print('[resetChunkGeneration] old isolate did not exit cleanly: $e');
      }
    }
    _workerSendPort = null;
    _workerExitCompleter = null;

    _wavChunks.clear();
    _readyToPlay = false;
    _genStopwatch
      ..reset()
      ..start();

    _chunkStream = _synthesizeChunks(scores);
    _chunkSubscription = _chunkStream!.listen(
      _onChunkReceived,
      onError: (e) {
        print('[resetChunkGeneration] chunk stream error: $e');
        // Surface this to the UI instead of silently hanging — e.g. show a
        // retry button. At minimum, avoid leaving readyToPlay stuck false
        // forever with no explanation.
      },
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
    _workerSendPort?.send(const _SynthDone());
    _workerSendPort = null;
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
          chunkStream: _isRepeat ? null : _chunkStream,
          singleProblem: _allFormattedProblems[_currentProblemIndex],
          generationComplete: _isRepeat ? true : _generationComplete,
          debugStatus: debugStatus,
        );
      case 1:
        return FlashAndAloudProblemInput<int>(
          showResult: setInputAndShowResult,
          showTimer: !widget.isSingleProblem,
          delayOver: _delayOver,
          duration: 14500,
          maxDigits: 17,
        );
      case 2:
        return FlashAndAloudResult<int>(
          onNextProblem: startNextProblem,
          onRepeatProblem: repeatProblem,
          onNewProblem: startNextProblem,
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

class _SynthError {
  final String message;
  const _SynthError(this.message);
}

class _SynthLog {
  final String message;
  const _SynthLog(this.message);
}

void _synthWorkerEntry(SendPort mainSendPort) async {
  final workerReceivePort = ReceivePort();
  mainSendPort.send(workerReceivePort.sendPort);
  VoicevoxSing? singer;
  workerReceivePort.listen((message) async {
    if (singer == null) {
      final initArgs = message as List<String>;
      final dictDir = initArgs[0];
      final vvmPath = initArgs[1];
      try {
        singer = VoicevoxSing(
          dictDir: dictDir,
          vvmPath: vvmPath,
          onLog: (msg) => mainSendPort.send(_SynthLog(msg)),
        );
        singer!.initialize();
        mainSendPort.send('INIT_OK');
      } catch (e, st) {
        mainSendPort.send(_SynthError('init failed: $e\n$st'));
      }
      return;
    }
    if (message is _SynthRequest) {
      try {
        final wav = singer!.synthesizeWithF0(
          scoreJson: message.scoreJson,
          character: message.character,
        );
        final sped = speedUpWav(wav, message.speed);
        mainSendPort.send(sped);
      } catch (e, st) {
        mainSendPort.send(_SynthError('synth failed: $e\n$st'));
      }
    } else if (message is _SynthDone) {
      singer?.dispose();
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
    required this.negaimasitehaPath,
    required this.isSingleProblem,
    required this.singleProblem,
    required this.generationComplete,
    required this.debugStatus,
  });

  final List<Uint8List> chunks;
  final Stream<Uint8List>? chunkStream;
  final VoidCallback onComplete;
  final bool readyToPlay;
  final String negaimasitehaPath;
  final bool isSingleProblem;
  final List<String> singleProblem;
  final bool generationComplete;
  final ValueNotifier<String> debugStatus;

  @override
  State<AloudProblem> createState() => _AloudProblemState();
}

class _AloudProblemState extends State<AloudProblem> {
  bool _isPlaying = false;
  bool _isPressed = false;
  int _currentChunk = 0;
  SoundHandle? _currentHandle;
  AudioSource? _currentSource;
  bool _disposed = false;
  int _playSession = 0;
  bool _isCompleted = false;
  bool _isMitoriExpanded = false;

  @override
  void dispose() {
    _disposed = true;
    _playSession++;
    if (_currentHandle != null) {
      SoLoud.instance.stop(_currentHandle!);
    }
    if (_currentSource != null) {
      SoLoud.instance.disposeSource(_currentSource!);
    }
    super.dispose();
  }

  Future<void> _playPreamble(int session) async {
    final source = await SoLoud.instance.loadAsset(widget.negaimasitehaPath);
    if (_disposed || session != _playSession) {
      SoLoud.instance.disposeSource(source);
      return;
    }
    _currentSource = source;
    final handle = SoLoud.instance.play(source);
    if (session != _playSession) {
      await SoLoud.instance.stop(handle);
      await SoLoud.instance.disposeSource(source);
      return;
    }
    _currentHandle = handle;
    final duration = SoLoud.instance.getLength(source);
    await Future.delayed(duration);
    if (session == _playSession) {
      await SoLoud.instance.disposeSource(source);
    }
  }

  Future<void> _playNextChunk(int session) async {
    if (_disposed ||
        session != _playSession ||
        !_isPlaying ||
        _currentChunk >= widget.chunks.length) {
      // If we've run out of chunks but generation isn't finished yet,
      // this is NOT completion — just wait for more chunks to arrive.
      if (!_disposed &&
          session == _playSession &&
          _isPlaying &&
          _currentChunk >= widget.chunks.length &&
          !widget.generationComplete) {
        // Retry shortly instead of declaring completion.
        Future.delayed(const Duration(milliseconds: 200), () {
          if (!_disposed && session == _playSession) {
            _playNextChunk(session);
          }
        });
        return;
      }

      final completed =
          !_disposed &&
          session == _playSession &&
          _isPlaying &&
          _currentChunk >= widget.chunks.length &&
          widget.generationComplete; // now requires real completion
      if (!_disposed && session == _playSession) {
        setState(() {
          _isPlaying = false;
          _currentChunk = 0;
          if (completed) _isCompleted = true;
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
    if (_disposed || session != _playSession) {
      SoLoud.instance.disposeSource(source);
      return;
    }
    _currentSource = source;
    final handle = SoLoud.instance.play(source);
    if (session != _playSession) {
      await SoLoud.instance.stop(handle);
      await SoLoud.instance.disposeSource(source);
      return;
    }
    _currentHandle = handle;
    final duration = SoLoud.instance.getLength(source);
    _currentChunk++;
    Future.delayed(duration, () async {
      await SoLoud.instance.disposeSource(source);
      if (!_disposed && session == _playSession && _isPlaying) {
        _playNextChunk(session);
      }
    });
  }

  Future<void> _play() async {
    if (_isPlaying) {
      _playSession++;
      if (_currentHandle != null) {
        await SoLoud.instance.stop(_currentHandle!);
      }
      setState(() {
        _isPlaying = false;
        _currentChunk = 0;
      });
      return;
    }

    _playSession++;
    final session = _playSession;

    setState(() {
      _isPlaying = true;
      _currentChunk = 0;
    });

    await _playPreamble(session);
    if (_disposed || session != _playSession || !_isPlaying) return;
    _playNextChunk(session);
  }

  @override
  Widget build(BuildContext context) {
    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final double buttonSize = _isMitoriExpanded ? 80.0 : 120.0;

    Widget icon;
    VoidCallback? onPressed;

    if (!_isCompleted && !widget.readyToPlay) {
      icon = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(strokeWidth: 4),
          ),
          const SizedBox(height: 12),
          ValueListenableBuilder<String>(
            valueListenable: widget.debugStatus,
            builder: (context, value, _) => Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
      onPressed = null;
    } else if (_isCompleted || _isPlaying) {
      icon = widget.isSingleProblem
          ? const Icon(Icons.replay_rounded, size: 120)
          : const Icon(Icons.volume_up, size: 120);
      onPressed = (_isCompleted || !widget.isSingleProblem) ? null : _play;
    } else {
      icon = const Icon(Icons.play_arrow_rounded, size: 120);
      onPressed = _play;
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              child: SafeArea(
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => context.pop(),
                  color: Colors.white,
                  iconSize: 24,
                ),
              ),
            ),
            if (widget.isSingleProblem)
              Positioned(
                top: 0,
                right: 0,
                child: SafeArea(
                  child: NavigationButton(
                    onPressed: () =>
                        setState(() => _isMitoriExpanded = !_isMitoriExpanded),
                    color: Colors.white,
                    child: SizedBox(
                      width: 140,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Row(
                          children: [
                            Icon(
                              _isMitoriExpanded
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              size: 32,
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  _isMitoriExpanded ? '問題を非表示' : '問題を表示',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: ValueListenableBuilder<String>(
                valueListenable: widget.debugStatus,
                builder: (context, value, _) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    value,
                    style: const TextStyle(color: Colors.yellow, fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Center(
              child: Flex(
                direction: isPortrait ? Axis.vertical : Axis.horizontal,
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
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        width: buttonSize,
                        height: buttonSize,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: FittedBox(fit: BoxFit.contain, child: icon),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (isPortrait)
                    const SizedBox(height: 16)
                  else
                    const SizedBox(width: 16),
                  if (widget.isSingleProblem)
                    CollapsibleMitoriDisplay(
                      problemIndex: null,
                      currentProblem: widget.singleProblem,
                      isPortrait: isPortrait,
                      isExpanded: _isMitoriExpanded,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CollapsibleMitoriDisplay extends StatelessWidget {
  const CollapsibleMitoriDisplay({
    super.key,
    required this.problemIndex,
    required this.currentProblem,
    required this.isPortrait,
    required this.isExpanded,
  });

  final int? problemIndex;
  final dynamic currentProblem;
  final bool isPortrait;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return ClipRect(
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        widthFactor: isExpanded ? 1.0 : 0.0,
        heightFactor: isExpanded ? 1.0 : 0.0,
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: isPortrait
                    ? screenHeight * 0.65
                    : screenHeight * 0.90,
                maxWidth: screenWidth * 0.9,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: MitoriDisplay(
                  problemIndex: problemIndex,
                  currentProblem: currentProblem,
                  isSimpleMitori: false,
                ),
              ),
            ),
          ),
        ),
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
