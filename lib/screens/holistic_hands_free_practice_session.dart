import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soroban_app/l10n/generated/app_localizations.dart';
import 'package:soroban_app/models/holistic_hands_free_practice.dart';
import 'package:soroban_app/models/holistic_hands_free_session.dart';
import 'package:soroban_app/models/level_definitions.dart';
import 'package:soroban_app/models/level_localizations.dart';
import 'package:soroban_app/screens/components/appbar.dart';
import 'package:soroban_app/screens/components/mitori_display.dart';

enum _HolisticSessionPhase { problem, thinking, answer, error }

/// Runs a typed holistic playlist independently from the existing hands-free
/// Flash and Combined Subjects flows.
class HolisticHandsFreePracticeSessionPage extends StatefulWidget {
  const HolisticHandsFreePracticeSessionPage({
    super.key,
    required this.config,
    this.random,
    this.problemSetGenerator,
    this.durationForEntry,
  });

  final HolisticHandsFreePracticeConfig config;

  /// Injection seams keep the queue and phase timing deterministic in tests.
  final Random? random;
  final HolisticHandsFreeProblemSetGenerator? problemSetGenerator;
  final Duration Function(
    HolisticPracticePlaylistEntry entry,
    int speedPercent,
  )?
  durationForEntry;

  @override
  State<HolisticHandsFreePracticeSessionPage> createState() =>
      _HolisticHandsFreePracticeSessionPageState();
}

class _HolisticHandsFreePracticeSessionPageState
    extends State<HolisticHandsFreePracticeSessionPage> {
  final Stopwatch _sessionStopwatch = Stopwatch();
  final Stopwatch _phaseStopwatch = Stopwatch();
  HolisticHandsFreeProblemQueue? _queue;
  HolisticHandsFreeProblem? _currentProblem;
  Timer? _phaseTimer;
  Timer? _ticker;
  _HolisticSessionPhase _phase = _HolisticSessionPhase.problem;
  Duration _phaseDuration = Duration.zero;
  int _completedAttempts = 0;

  @override
  void initState() {
    super.initState();
    try {
      _queue = HolisticHandsFreeProblemQueue(
        widget.config,
        random: widget.random,
        problemSetGenerator: widget.problemSetGenerator,
      );
      _beginProblem(update: false);
    } catch (_) {
      _fail(update: false);
    }
  }

  Duration _durationFor(HolisticPracticePlaylistEntry entry) =>
      widget.durationForEntry?.call(entry, widget.config.speedPercent) ??
      entry.displayedProblemDuration(speedPercent: widget.config.speedPercent);

  void _beginProblem({HolisticHandsFreeProblem? problem, bool update = true}) {
    _cancelPhaseTimers();
    try {
      _currentProblem = problem ?? _queue!.next();
      _phase = _HolisticSessionPhase.problem;
      final duration = _durationFor(_currentProblem!.entry);
      if (duration <= Duration.zero) {
        throw ArgumentError.value(duration, 'duration', 'Must be positive');
      }
      if (!_sessionStopwatch.isRunning) _sessionStopwatch.start();
      _startPhase(
        duration,
        _onProblemComplete,
        isFlash: _currentProblem!.isFlash,
      );
      if (update && mounted) setState(() {});
    } catch (_) {
      _fail(update: update);
    }
  }

  void _startPhase(
    Duration duration,
    VoidCallback onComplete, {
    bool isFlash = false,
  }) {
    if (duration <= Duration.zero) {
      throw ArgumentError.value(duration, 'duration', 'Must be positive');
    }
    _phaseDuration = duration;
    _phaseStopwatch
      ..reset()
      ..start();
    _phaseTimer = Timer(duration, () {
      _cancelPhaseTimers();
      if (mounted) onComplete();
    });
    _ticker = Timer.periodic(
      isFlash ? const Duration(milliseconds: 25) : const Duration(seconds: 1),
      (_) {
        if (mounted) setState(() {});
      },
    );
  }

  void _onProblemComplete() {
    final problem = _currentProblem;
    if (problem?.isFlash ?? false) {
      _phase = _HolisticSessionPhase.thinking;
      setState(() {});
      try {
        _startPhase(widget.config.thinkingDelay, _revealAnswer);
      } catch (_) {
        _fail();
      }
    } else {
      _revealAnswer();
    }
  }

  void _revealAnswer() {
    _phase = _HolisticSessionPhase.answer;
    _completedAttempts++;
    setState(() {});
    try {
      _startPhase(widget.config.answerDisplayDwell, _advanceProblem);
    } catch (_) {
      _fail();
    }
  }

  void _advanceProblem() => _beginProblem();

  void _tryAgain() {
    final problem = _currentProblem;
    if (problem != null) _beginProblem(problem: problem);
  }

  void _cancelPhaseTimers() {
    _phaseTimer?.cancel();
    _phaseTimer = null;
    _ticker?.cancel();
    _ticker = null;
    _phaseStopwatch
      ..stop()
      ..reset();
  }

  void _fail({bool update = true}) {
    _cancelPhaseTimers();
    _sessionStopwatch.stop();
    if (!mounted) {
      _phase = _HolisticSessionPhase.error;
      return;
    }
    if (update) {
      setState(() => _phase = _HolisticSessionPhase.error);
    } else {
      _phase = _HolisticSessionPhase.error;
    }
  }

  void _stop() {
    _cancelPhaseTimers();
    _sessionStopwatch.stop();
    if (mounted) context.pop();
  }

  @override
  void dispose() {
    _cancelPhaseTimers();
    _sessionStopwatch.stop();
    super.dispose();
  }

  int _remainingSeconds() {
    final remaining = _phaseDuration - _phaseStopwatch.elapsed;
    return remaining.isNegative ? 0 : (remaining.inMilliseconds / 1000).ceil();
  }

  String _elapsedTime(Duration duration) =>
      '${duration.inMinutes}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}';

  String _activityLabel(
    AppLocalizations l10n,
    HolisticPracticeActivity activity,
  ) => switch (activity) {
    HolisticPracticeActivity.mitoriAnzan => l10n.mitoriAnzan,
    HolisticPracticeActivity.multiplicationAnzan => l10n.multiplicationAnzan,
    HolisticPracticeActivity.divisionAnzan => l10n.divisionAnzan,
    HolisticPracticeActivity.flashAnzan => l10n.flashAnzanSubject,
  };

  String _organizationLabel(
    AppLocalizations l10n,
    HolisticPracticePlaylistEntry entry,
  ) => switch (entry.denomination) {
    Denomination.zenshuren => l10n.selectorZenshuren,
    Denomination.nisshou => l10n.selectorNisshuren,
    Denomination.kyoukai => l10n.selectorFlashAnzan,
  };

  String? _flashNumberToShow(HolisticHandsFreeProblem problem) {
    if (_phase != _HolisticSessionPhase.problem || !problem.isFlash) {
      return null;
    }
    final numbers = problem.flashNumbers;
    if (numbers == null || numbers.isEmpty) return null;

    final elapsed = _phaseStopwatch.elapsed.inMicroseconds;
    final total = _phaseDuration.inMicroseconds;
    final hideInterval = total / (2.5 * numbers.length - 1);
    final showInterval = hideInterval * 1.5;
    var cursor = 0.0;
    for (var index = 0; index < numbers.length; index++) {
      if (elapsed >= cursor && elapsed < cursor + showInterval) {
        return numbers[index];
      }
      cursor += showInterval + hideInterval;
    }
    return null;
  }

  Widget _problemDisplay(
    BuildContext context,
    HolisticHandsFreeProblem problem, {
    required bool revealFlashSequence,
  }) {
    if (problem.isFlash) {
      final text = revealFlashSequence
          ? (problem.flashNumbers ?? const []).join('   ')
          : _flashNumberToShow(problem);
      if (text == null || text.isEmpty) return const SizedBox.shrink();
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          key: const ValueKey('holistic-flash-current-number'),
          style: const TextStyle(
            fontFamily: 'abacusFont',
            fontSize: 120,
            color: Colors.lightGreenAccent,
          ),
          textScaler: TextScaler.noScaling,
        ),
      );
    }

    final entry = problem.entry as PaperAnzanPlaylistEntry;
    if (entry.activity == HolisticPracticeActivity.mitoriAnzan) {
      final rows = problem.formattedPrompt as List<String>;
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MitoriDisplay(
                currentProblem: rows,
                isSimpleMitori: entry.level is SimpleMitoriLevel,
              ),
              Container(
                height: 2,
                color: Theme.of(context).colorScheme.onSurface,
                margin: const EdgeInsets.only(top: 5),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              problem.formattedPrompt as String,
              key: const ValueKey('holistic-paper-prompt'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 42, fontFamily: 'abacusFont'),
              textScaler: TextScaler.noScaling,
            ),
          ),
          const SizedBox(height: 12),
          const Text('||', style: TextStyle(fontSize: 26)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final problem = _currentProblem;
    final phase = _phase;
    final isAnswer = phase == _HolisticSessionPhase.answer;
    final entry = problem?.entry;

    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _stop();
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: l10n.holisticHandsFreePractice,
          context: context,
          onBackPressed: _stop,
        ),
        body: SafeArea(
          child: Column(
            children: [
              if (entry != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                  child: Column(
                    children: [
                      Text(
                        _activityLabel(l10n, entry.activity),
                        key: const ValueKey('holistic-session-subject'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        l10n.handsFreeAnzanKyuuiContext(
                          entry.kyuui.localizedLabel(l10n),
                          _organizationLabel(l10n, entry),
                        ),
                        key: const ValueKey('holistic-session-level'),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: Center(
                  child: phase == _HolisticSessionPhase.error
                      ? Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            l10n.handsFreeAnzanGenerationError,
                            key: const ValueKey('holistic-session-error'),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : problem == null
                      ? const SizedBox.shrink()
                      : _problemDisplay(
                          context,
                          problem,
                          revealFlashSequence: isAnswer,
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isAnswer && problem != null) ...[
                      Text(
                        l10n.handsFreeAnzanAnswer(problem.formattedAnswer),
                        key: const ValueKey('holistic-session-answer'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.handsFreeQuestionsCompleted(_completedAttempts),
                        key: const ValueKey('holistic-session-attempt-count'),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    Text(
                      l10n.handsFreePracticeTime(
                        _elapsedTime(_sessionStopwatch.elapsed),
                      ),
                      key: const ValueKey('holistic-session-elapsed'),
                      textAlign: TextAlign.center,
                    ),
                    if (phase == _HolisticSessionPhase.problem)
                      Text(
                        l10n.holisticProblemCountdown(_remainingSeconds()),
                        key: const ValueKey(
                          'holistic-session-problem-countdown',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    if (phase == _HolisticSessionPhase.thinking)
                      Text(
                        l10n.handsFreeRevealCountdown(_remainingSeconds()),
                        key: const ValueKey(
                          'holistic-session-thinking-countdown',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    if (isAnswer)
                      Text(
                        l10n.handsFreeNextProblemCountdown(_remainingSeconds()),
                        key: const ValueKey('holistic-session-next-countdown'),
                        textAlign: TextAlign.center,
                      ),
                    if (isAnswer)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            OutlinedButton.icon(
                              key: const ValueKey('holistic-session-try-again'),
                              onPressed: _tryAgain,
                              icon: const Icon(Icons.replay_rounded),
                              label: Text(l10n.repeatProblem),
                            ),
                            FilledButton.icon(
                              key: const ValueKey('holistic-session-next'),
                              onPressed: _advanceProblem,
                              icon: const Icon(Icons.skip_next_rounded),
                              label: Text(l10n.nextProblem),
                            ),
                          ],
                        ),
                      ),
                    TextButton.icon(
                      key: const ValueKey('holistic-session-stop'),
                      onPressed: _stop,
                      icon: const Icon(Icons.stop_circle_outlined),
                      label: Text(l10n.handsFreeStop),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
