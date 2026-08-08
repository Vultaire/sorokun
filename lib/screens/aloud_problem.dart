import 'dart:async';
import 'dart:typed_data';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:go_router/go_router.dart';
import 'package:soroban_app/models/level_definitions.dart';
import 'package:soroban_app/models/singer_config.dart';
import 'package:soroban_app/problem_generation/aloud.dart';
import 'package:soroban_app/problem_generation/aloud_set.dart';
import 'package:soroban_app/problem_generation/voicevox_synth_worker.dart';
import 'package:soroban_app/screens/components/exit_button.dart';
import 'package:soroban_app/screens/components/keypad.dart';
import 'package:soroban_app/screens/components/mitori_display.dart';
import 'package:soroban_app/screens/components/navigation_button.dart';
import 'package:soroban_app/screens/flash_problem.dart';

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
  bool _generationComplete = false;

  double get speed {
    if (widget.selectedLevel.moraPerSecond <= 9) return 1.0;
    return 1.0 + (widget.selectedLevel.moraPerSecond - 9) * 0.1;
  }

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
      frameStretchFactor: speed,
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
          frameStretchFactor: speed,
        ),
      );
    }
    return scores;
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
      frameStretchFactor: speed,
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

  void showResultPage() {
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

  Stream<Uint8List> _synthesizeChunks(List<String> scores) {
    return VoicevoxSynthWorker.instance.synthesizeChunks(
      scores,
      widget.character,
    );
  }

  Future<void> _resetChunkGeneration(List<String> scores) async {
    _chunkSubscription?.cancel();
    _readyTimer?.cancel();
    _generationComplete = false;
    _wavChunks.clear();
    _readyToPlay = false;
    _genStopwatch
      ..reset()
      ..start();
    _chunkStream = _synthesizeChunks(scores);
    _chunkSubscription = _chunkStream!.listen(
      _onChunkReceived,
      onError: (e) {
        VoicevoxSynthWorker.instance.debugStatus.value =
            '[resetChunkGeneration] chunk stream error: $e';
      },
      onDone: () {
        if (mounted) {
          setState(() {
            _generationComplete = true;
            if (!_readyToPlay) _readyToPlay = true;
          });
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
    VoicevoxSynthWorker.instance.acquire();
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
    VoicevoxSynthWorker.instance.release();
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
          debugStatus: VoicevoxSynthWorker.instance.debugStatus,
          speed: speed,
        );
      case 1:
        return FlashAndAloudProblemInput<int>(
          showAnswer: setInputAndShowResult,
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
          onShowResults: showResultPage,
          inputTime: _inputTime,
          isSingleProblem: widget.isSingleProblem,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);
    final bool isPortrait =
        MediaQuery.orientationOf(context) == Orientation.portrait;

    return FlashAndAloudProblemData<int>(
      screenSize: screenSize,
      isPortrait: isPortrait,
      currentProblemIndex: _currentProblemIndex,
      allAnswers: _allAnswers,
      allProblems: _allProblems,
      textFieldDataList: _textFieldDataList,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: PageTransitionSwitcher(
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
            child: Stack(
              key: ValueKey('${_currentProblemIndex}_$_currentPageIndex'),
              children: [
                _buildPage(_currentPageIndex),
                ExitButton(
                  homeRoute: widget.isSingleProblem
                      ? 'aloud-free-menu'
                      : '/aloud-level-menu',
                  onShowResults: showResultPage,
                  isSingleProblem: widget.isSingleProblem,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
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
    this.speed = 1.0,
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
  final double speed;
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
    _deactivatePitchShiftIfNeeded();
    super.dispose();
  }

  /// Applies the current speed + compensating pitch shift to a freshly
  /// started handle. Call this right after obtaining a new SoundHandle.
  void _applySpeed(SoundHandle handle) {
    final speed = widget.speed;
    SoLoud.instance.setRelativePlaySpeed(handle, speed);
    if (speed == 1.0) {
      _deactivatePitchShiftIfNeeded();
    } else {
      if (!SoLoud.instance.filters.pitchShiftFilter.isActive) {
        SoLoud.instance.filters.pitchShiftFilter.activate();
      }
      final pitch = 1.0 / speed;
      SoLoud.instance.filters.pitchShiftFilter.shift.value = pitch;
    }
  }

  Duration _actualPlaybackDuration(Duration nominal) {
    final speed = widget.speed;
    if (speed == 1.0) return nominal;
    return Duration(microseconds: (nominal.inMicroseconds / speed).round());
  }

  void _deactivatePitchShiftIfNeeded() {
    if (SoLoud.instance.filters.pitchShiftFilter.isActive) {
      SoLoud.instance.filters.pitchShiftFilter.deactivate();
    }
  }

  Future<void> _playPreamble(int session) async {
    final source = await SoLoud.instance.loadAsset(widget.negaimasitehaPath);
    if (_disposed || session != _playSession) {
      SoLoud.instance.disposeSource(source);
      return;
    }
    _currentSource = source;
    _deactivatePitchShiftIfNeeded();
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
      if (!_disposed &&
          session == _playSession &&
          _isPlaying &&
          _currentChunk >= widget.chunks.length &&
          !widget.generationComplete) {
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
          widget.generationComplete;
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
    _applySpeed(handle);
    final duration = SoLoud.instance.getLength(source);
    _currentChunk++;
    Future.delayed(_actualPlaybackDuration(duration), () async {
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
        MediaQuery.orientationOf(context) == Orientation.portrait;
    final double buttonSize = _isMitoriExpanded ? 80.0 : 120.0;

    Widget icon;
    VoidCallback? onPressed;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    if (!_isCompleted && !widget.readyToPlay) {
      icon = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              strokeWidth: 8,
              strokeCap: .round,
              color: Colors.black,
            ),
          ),
        ],
      );
      onPressed = null;
    } else if (_isCompleted || _isPlaying) {
      icon = widget.isSingleProblem
          ? const Icon(Icons.replay_rounded, size: 120, color: Colors.black)
          : const Icon(
              Icons.graphic_eq_rounded,
              size: 120,
              color: Colors.black,
            );
      onPressed = (_isCompleted || !widget.isSingleProblem) ? null : _play;
    } else {
      icon = const Icon(
        Icons.play_arrow_rounded,
        size: 120,
        color: Colors.black,
      );
      onPressed = _play;
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            if (widget.isSingleProblem)
              Positioned(
                top: 0,
                right: 0,
                child: SafeArea(
                  child: NavigationButton(
                    onPressed: () =>
                        setState(() => _isMitoriExpanded = !_isMitoriExpanded),
                    color: colorScheme.surface,
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
                              color: colorScheme.onSurface,
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  _isMitoriExpanded ? '問題を非表示' : '問題を表示',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(color: colorScheme.onSurface),
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
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Center(
                          child: FittedBox(fit: BoxFit.contain, child: icon),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16, width: 16),
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
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double screenHeight = MediaQuery.sizeOf(context).height;

    return ClipRect(
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        widthFactor: isExpanded ? 1.0 : 0.0,
        heightFactor: isExpanded ? 1.0 : 0.0,
        child: Material(
          color: Theme.of(context).colorScheme.surface,
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
