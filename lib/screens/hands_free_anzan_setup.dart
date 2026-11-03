import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soroban_app/l10n/generated/app_localizations.dart';
import 'package:soroban_app/models/hands_free_anzan.dart';
import 'package:soroban_app/models/hands_free_anzan_setup.dart';
import 'package:soroban_app/models/level_definitions.dart';
import 'package:soroban_app/models/level_localizations.dart';
import 'package:soroban_app/screens/components/appbar.dart';

class HandsFreeAnzanSetupPage extends StatefulWidget {
  const HandsFreeAnzanSetupPage({
    super.key,
    required this.kyuui,
    required this.denomination,
    required this.onContinue,
  });

  final Kyuui kyuui;
  final KyuuiDenomination denomination;
  final ValueChanged<HandsFreeAnzanSetupConfig> onContinue;

  @override
  State<HandsFreeAnzanSetupPage> createState() =>
      _HandsFreeAnzanSetupPageState();
}

class _HandsFreeAnzanSetupPageState extends State<HandsFreeAnzanSetupPage> {
  static const _minimumSpeed = 50;
  static const _maximumSpeed = 200;
  static const _defaultAnswerDwell = 5;

  late final Map<HandsFreeAnzanSubject, PaperProblemLevel> _availableSubjects =
      handsFreeAnzanSubjectsFor(widget.kyuui);
  late HandsFreeAnzanMode? _mode = _availableSubjects.isEmpty
      ? null
      : _modeForSubject(_availableSubjects.keys.first);
  late final Set<HandsFreeAnzanSubject> _mixedSubjects = Set.of(
    _availableSubjects.keys,
  );
  int _speedPercent = 100;
  int _answerDisplayDwellSeconds = _defaultAnswerDwell;

  HandsFreeAnzanMode _modeForSubject(HandsFreeAnzanSubject subject) =>
      switch (subject) {
        HandsFreeAnzanSubject.mitori => HandsFreeAnzanMode.mitori,
        HandsFreeAnzanSubject.multiplication =>
          HandsFreeAnzanMode.multiplication,
        HandsFreeAnzanSubject.division => HandsFreeAnzanMode.division,
      };

  HandsFreeAnzanSubject? get _singleSubject => switch (_mode) {
    HandsFreeAnzanMode.mitori => HandsFreeAnzanSubject.mitori,
    HandsFreeAnzanMode.multiplication => HandsFreeAnzanSubject.multiplication,
    HandsFreeAnzanMode.division => HandsFreeAnzanSubject.division,
    HandsFreeAnzanMode.mixed || null => null,
  };

  List<HandsFreeAnzanSubject> get _selectedSubjects {
    final single = _singleSubject;
    if (single != null) return [single];
    return _availableSubjects.keys
        .where(_mixedSubjects.contains)
        .toList(growable: false);
  }

  String _organizationLabel(AppLocalizations l10n) =>
      switch (widget.denomination) {
        KyuuiDenomination.zs => l10n.selectorZenshuren,
        KyuuiDenomination.ns => l10n.selectorNisshuren,
        KyuuiDenomination.zsFlash => l10n.selectorZenshuren,
        KyuuiDenomination.kkFlash => l10n.selectorFlashAnzan,
      };

  String _subjectLabel(AppLocalizations l10n, HandsFreeAnzanSubject subject) =>
      switch (subject) {
        HandsFreeAnzanSubject.mitori => l10n.handsFreeAnzanMitori,
        HandsFreeAnzanSubject.multiplication => l10n.multiplicationAnzan,
        HandsFreeAnzanSubject.division => l10n.divisionAnzan,
      };

  String _durationLabel(AppLocalizations l10n, Duration duration) {
    final milliseconds = duration.inMilliseconds;
    final seconds = milliseconds / Duration.millisecondsPerSecond;
    final formatted = seconds == seconds.roundToDouble()
        ? seconds.toStringAsFixed(0)
        : seconds.toStringAsFixed(1);
    return l10n.handsFreeAnzanSecondsValue(formatted);
  }

  void _continue() {
    final mode = _mode;
    final subjects = _selectedSubjects.toSet();
    if (mode == null || subjects.isEmpty) return;

    widget.onContinue(
      HandsFreeAnzanSetupConfig(
        kyuui: widget.kyuui,
        denomination: widget.denomination,
        mode: mode,
        selectedSubjects: subjects,
        speedPercent: _speedPercent,
        answerDisplayDwell: Duration(seconds: _answerDisplayDwellSeconds),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selectedSubjects = _selectedSubjects;

    return Scaffold(
      appBar: CustomAppBar(
        title: l10n.handsFreeAnzanSetupTitle,
        context: context,
        onBackPressed: () => context.pop(),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.handsFreeAnzanSetupSubtitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.handsFreeAnzanKyuuiContext(
                          widget.kyuui.localizedLabel(l10n),
                          _organizationLabel(l10n),
                        ),
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      _SetupCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.handsFreeAnzanSubjectsHeading,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                for (final subject in _availableSubjects.keys)
                                  ChoiceChip(
                                    label: Text(_subjectLabel(l10n, subject)),
                                    selected: _mode == _modeForSubject(subject),
                                    onSelected: (_) => setState(
                                      () => _mode = _modeForSubject(subject),
                                    ),
                                  ),
                                ChoiceChip(
                                  label: Text(l10n.handsFreeAnzanMixed),
                                  selected: _mode == HandsFreeAnzanMode.mixed,
                                  onSelected: (_) => setState(
                                    () => _mode = HandsFreeAnzanMode.mixed,
                                  ),
                                ),
                              ],
                            ),
                            if (_mode == HandsFreeAnzanMode.mixed) ...[
                              const SizedBox(height: 8),
                              Text(l10n.handsFreeAnzanMixedSubjectsHint),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  for (final subject in _availableSubjects.keys)
                                    FilterChip(
                                      key: ValueKey(
                                        'hands-free-subject-${subject.name}',
                                      ),
                                      label: Text(_subjectLabel(l10n, subject)),
                                      selected: _mixedSubjects.contains(
                                        subject,
                                      ),
                                      onSelected: (selected) {
                                        if (!selected &&
                                            _mixedSubjects.length == 1) {
                                          return;
                                        }
                                        setState(() {
                                          if (selected) {
                                            _mixedSubjects.add(subject);
                                          } else {
                                            _mixedSubjects.remove(subject);
                                          }
                                        });
                                      },
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _SetupCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.handsFreeAnzanSpeedHeading,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(l10n.handsFreeAnzanSpeedHint),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text('$_minimumSpeed%'),
                                Expanded(
                                  child: Slider(
                                    key: const ValueKey(
                                      'hands-free-speed-slider',
                                    ),
                                    min: _minimumSpeed.toDouble(),
                                    max: _maximumSpeed.toDouble(),
                                    divisions: 30,
                                    label: '$_speedPercent%',
                                    value: _speedPercent.toDouble(),
                                    onChanged: (value) => setState(
                                      () => _speedPercent = value.round(),
                                    ),
                                  ),
                                ),
                                Text('$_maximumSpeed%'),
                              ],
                            ),
                            Center(
                              child: Text(
                                l10n.handsFreeAnzanCurrentSpeed(_speedPercent),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _SetupCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.handsFreeAnzanDurationHeading,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            for (final subject in selectedSubjects)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  l10n.handsFreeAnzanDurationPreview(
                                    _subjectLabel(l10n, subject),
                                    _durationLabel(
                                      l10n,
                                      handsFreeProblemDuration(
                                        _availableSubjects[subject]!,
                                        speedPercent: _speedPercent.toDouble(),
                                      ),
                                    ),
                                  ),
                                  key: ValueKey(
                                    'hands-free-duration-${subject.name}',
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _SetupCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.handsFreeAnzanAnswerDwellHeading,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(l10n.handsFreeAnzanAnswerDwellHint),
                            Row(
                              children: [
                                Text(l10n.handsFreeAnzanSecondsValue('1')),
                                Expanded(
                                  child: Slider(
                                    key: const ValueKey(
                                      'hands-free-answer-dwell-slider',
                                    ),
                                    min: 1,
                                    max: 15,
                                    divisions: 14,
                                    label: l10n.handsFreeAnzanSecondsValue(
                                      '$_answerDisplayDwellSeconds',
                                    ),
                                    value: _answerDisplayDwellSeconds
                                        .toDouble(),
                                    onChanged: (value) => setState(
                                      () => _answerDisplayDwellSeconds = value
                                          .round(),
                                    ),
                                  ),
                                ),
                                Text(l10n.handsFreeAnzanSecondsValue('15')),
                              ],
                            ),
                            Center(
                              child: Text(
                                l10n.handsFreeAnzanAnswerDwellValue(
                                  _answerDisplayDwellSeconds,
                                ),
                                key: const ValueKey(
                                  'hands-free-answer-dwell-value',
                                ),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.handsFreeAnzanSetupOnlyNotice,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      FilledButton.icon(
                        key: const ValueKey('hands-free-setup-continue'),
                        onPressed: selectedSubjects.isEmpty ? null : _continue,
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: Text(l10n.handsFreeAnzanContinue),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SetupCard extends StatelessWidget {
  const _SetupCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    child: Padding(padding: const EdgeInsets.all(16), child: child),
  );
}
