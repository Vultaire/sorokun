import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soroban_app/l10n/generated/app_localizations.dart';
import 'package:soroban_app/models/hands_free_anzan.dart';
import 'package:soroban_app/models/hands_free_anzan_session.dart';
import 'package:soroban_app/models/hands_free_anzan_setup.dart';
import 'package:soroban_app/models/level_definitions.dart';
import 'package:soroban_app/models/level_localizations.dart';
import 'package:soroban_app/screens/components/appbar.dart';
import 'package:soroban_app/screens/components/mitori_display.dart';

enum _SessionPhase { solving, reveal, error }

class HandsFreeAnzanSessionPage extends StatefulWidget {
  const HandsFreeAnzanSessionPage({
    super.key,
    required this.config,
    this.durationForLevel,
    this.random,
  });

  final HandsFreeAnzanSetupConfig config;

  /// Optional timing seam for tests; production uses the configured exam pace.
  final Duration Function(PaperProblemLevel level, int speedPercent)?
  durationForLevel;
  final Random? random;

  @override
  State<HandsFreeAnzanSessionPage> createState() =>
      _HandsFreeAnzanSessionPageState();
}

class _HandsFreeAnzanSessionPageState extends State<HandsFreeAnzanSessionPage> {
  final Stopwatch _sessionStopwatch = Stopwatch();
  final Stopwatch _attemptStopwatch = Stopwatch();
  final Stopwatch _phaseStopwatch = Stopwatch();
  HandsFreeAnzanProblemQueue? _queue;
  HandsFreeAnzanProblem? _currentProblem;
  Timer? _phaseTimer;
  Timer? _ticker;
  _SessionPhase _phase = _SessionPhase.solving;
  Duration _phaseDuration = Duration.zero;
  Duration _lastAttemptDuration = Duration.zero;
  int _completedAttempts = 0;

  @override
  void initState() {
    super.initState();
    try {
      _queue = HandsFreeAnzanProblemQueue(widget.config, random: widget.random);
      _sessionStopwatch.start();
      _beginProblem(update: false);
    } catch (_) {
      _fail();
    }
  }

  void _beginProblem({HandsFreeAnzanProblem? problem, bool update = true}) {
    _cancelPhaseTimers();
    try {
      _currentProblem = problem ?? _queue!.next();
      _phase = _SessionPhase.solving;
      _attemptStopwatch
        ..reset()
        ..start();
      _startPhase(
        widget.durationForLevel?.call(
              _currentProblem!.level,
              widget.config.speedPercent,
            ) ??
            _currentProblem!.solveDuration(widget.config.speedPercent),
        _revealAnswer,
      );
      if (update && mounted) setState(() {});
    } catch (_) {
      _fail();
    }
  }

  void _startPhase(Duration duration, VoidCallback onComplete) {
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
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  void _revealAnswer() {
    _attemptStopwatch.stop();
    _lastAttemptDuration = _attemptStopwatch.elapsed;
    _completedAttempts++;
    setState(() => _phase = _SessionPhase.reveal);
    try {
      _startPhase(widget.config.answerDisplayDwell, _advanceProblem);
    } catch (_) {
      _fail();
    }
  }

  void _advanceProblem() => _beginProblem();

  void _tryAgain() => _beginProblem(problem: _currentProblem);

  void _cancelPhaseTimers() {
    _phaseTimer?.cancel();
    _phaseTimer = null;
    _ticker?.cancel();
    _ticker = null;
    _phaseStopwatch
      ..stop()
      ..reset();
  }

  void _fail() {
    _cancelPhaseTimers();
    _attemptStopwatch.stop();
    _sessionStopwatch.stop();
    if (!mounted) {
      _phase = _SessionPhase.error;
      return;
    }
    setState(() => _phase = _SessionPhase.error);
  }

  void _stop() {
    _cancelPhaseTimers();
    _attemptStopwatch.stop();
    _sessionStopwatch.stop();
    if (mounted) context.go('/paper-menu');
  }

  @override
  void dispose() {
    _cancelPhaseTimers();
    _attemptStopwatch.stop();
    _sessionStopwatch.stop();
    super.dispose();
  }

  String _subjectLabel(AppLocalizations l10n, HandsFreeAnzanSubject subject) =>
      switch (subject) {
        HandsFreeAnzanSubject.mitori => l10n.handsFreeAnzanMitori,
        HandsFreeAnzanSubject.multiplication => l10n.multiplicationAnzan,
        HandsFreeAnzanSubject.division => l10n.divisionAnzan,
      };

  String _modeLabel(AppLocalizations l10n) => switch (widget.config.mode) {
    HandsFreeAnzanMode.mitori => l10n.handsFreeAnzanMitori,
    HandsFreeAnzanMode.multiplication => l10n.multiplicationAnzan,
    HandsFreeAnzanMode.division => l10n.divisionAnzan,
    HandsFreeAnzanMode.mixed => l10n.handsFreeAnzanMixed,
  };

  String _organizationLabel(AppLocalizations l10n) =>
      switch (widget.config.denomination) {
        KyuuiDenomination.zs ||
        KyuuiDenomination.zsFlash => l10n.selectorZenshuren,
        KyuuiDenomination.ns => l10n.selectorNisshuren,
        KyuuiDenomination.kkFlash => l10n.selectorFlashAnzan,
      };

  String _durationLabel(Duration duration) {
    final milliseconds = duration.inMilliseconds;
    final seconds = milliseconds / Duration.millisecondsPerSecond;
    final text = seconds == seconds.roundToDouble()
        ? seconds.toStringAsFixed(0)
        : seconds.toStringAsFixed(1);
    return text;
  }

  String _elapsedTime(Duration duration) =>
      '${duration.inMinutes}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}';

  int _remainingSeconds() {
    final remaining = _phaseDuration - _phaseStopwatch.elapsed;
    return remaining.isNegative ? 0 : (remaining.inMilliseconds / 1000).ceil();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final problem = _currentProblem;
    final subject = problem?.subject;
    final isRevealed = _phase == _SessionPhase.reveal;
    final modeLabel = _modeLabel(l10n);
    final solving = _phase == _SessionPhase.solving;

    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _stop();
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: l10n.handsFreeAnzanEntry,
          context: context,
          onBackPressed: _stop,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  children: [
                    Text(
                      l10n.handsFreeAnzanKyuuiContext(
                        widget.config.kyuui.localizedLabel(l10n),
                        _organizationLabel(l10n),
                      ),
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      modeLabel,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (subject != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _subjectLabel(l10n, subject),
                        key: const ValueKey('hands-free-current-subject'),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: _phase == _SessionPhase.error
                      ? Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            l10n.handsFreeAnzanGenerationError,
                            textAlign: TextAlign.center,
                          ),
                        )
                      : problem == null
                      ? const SizedBox.shrink()
                      : _ProblemView(problem: problem),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    if (isRevealed)
                      Text(
                        l10n.handsFreeAnzanAnswer(
                          problem?.formattedAnswer ?? '',
                        ),
                        key: const ValueKey('hands-free-revealed-answer'),
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                    if (isRevealed) ...[
                      const SizedBox(height: 8),
                      Text(
                        l10n.handsFreeQuestionsCompleted(_completedAttempts),
                        key: const ValueKey('hands-free-attempt-count'),
                      ),
                      Text(
                        l10n.handsFreeAnzanAttemptTime(
                          l10n.handsFreeAnzanSecondsValue(
                            _durationLabel(_lastAttemptDuration),
                          ),
                        ),
                        key: const ValueKey('hands-free-attempt-time'),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      l10n.handsFreePracticeTime(
                        _elapsedTime(_sessionStopwatch.elapsed),
                      ),
                      key: const ValueKey('hands-free-practice-time'),
                    ),
                    if (solving)
                      Text(
                        l10n.handsFreeRevealCountdown(_remainingSeconds()),
                        key: const ValueKey('hands-free-solve-countdown'),
                      ),
                    if (isRevealed)
                      Text(
                        l10n.handsFreeNextProblemCountdown(_remainingSeconds()),
                        key: const ValueKey('hands-free-next-countdown'),
                      ),
                    const SizedBox(height: 10),
                    if (isRevealed)
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            key: const ValueKey('hands-free-try-again'),
                            onPressed: _tryAgain,
                            icon: const Icon(Icons.replay_rounded),
                            label: Text(l10n.repeatProblem),
                          ),
                          FilledButton.icon(
                            key: const ValueKey('hands-free-next-problem'),
                            onPressed: _advanceProblem,
                            icon: const Icon(Icons.skip_next_rounded),
                            label: Text(l10n.nextProblem),
                          ),
                        ],
                      ),
                    if (_phase == _SessionPhase.error)
                      FilledButton(
                        key: const ValueKey('hands-free-error-stop'),
                        onPressed: _stop,
                        child: Text(l10n.handsFreeStop),
                      ),
                    if (_phase != _SessionPhase.error)
                      TextButton.icon(
                        key: const ValueKey('hands-free-stop'),
                        onPressed: _stop,
                        icon: const Icon(Icons.stop_circle_outlined),
                        label: Text(l10n.handsFreeStop),
                      ),
                    const SizedBox(height: 8),
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

class _ProblemView extends StatelessWidget {
  const _ProblemView({required this.problem});

  final HandsFreeAnzanProblem problem;

  @override
  Widget build(BuildContext context) {
    final level = problem.level;
    if (level is MitoriLevel) {
      final formattedProblem = problem.formattedProblem as List<String>;
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MitoriDisplay(
                currentProblem: formattedProblem,
                isSimpleMitori: level is SimpleMitoriLevel,
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
              problem.formattedProblem as String,
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
}
