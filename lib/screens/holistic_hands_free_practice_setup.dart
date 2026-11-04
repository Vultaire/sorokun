import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soroban_app/l10n/generated/app_localizations.dart';
import 'package:soroban_app/models/holistic_hands_free_practice.dart';
import 'package:soroban_app/models/level_definitions.dart';
import 'package:soroban_app/models/level_localizations.dart';
import 'package:soroban_app/screens/components/appbar.dart';

/// Configures an ordered playlist without creating a problem or starting a run.
class HolisticHandsFreePracticeSetupPage extends StatefulWidget {
  const HolisticHandsFreePracticeSetupPage({super.key});

  @override
  State<HolisticHandsFreePracticeSetupPage> createState() =>
      _HolisticHandsFreePracticeSetupPageState();
}

class _HolisticHandsFreePracticeSetupPageState
    extends State<HolisticHandsFreePracticeSetupPage> {
  static const _minimumSpeed = 50;
  static const _maximumSpeed = 200;
  static const _minimumDelaySeconds = 1;
  static const _maximumDelaySeconds = 15;

  final List<_PlaylistDraft> _playlist = [
    _PlaylistDraft(
      activity: HolisticPracticeActivity.mitoriAnzan,
      denomination: Denomination.zenshuren,
      kyuui: Kyuui.zsk10,
    ),
  ];
  int _speedPercent = 100;
  int _thinkingDelaySeconds = 5;
  int _answerDisplayDwellSeconds = 5;

  List<Kyuui> _availableGrades(
    HolisticPracticeActivity activity,
    Denomination denomination,
  ) {
    final mapping = _mappingFor(activity, denomination);
    if (mapping == null) return const [];

    final candidates = [
      mapping.k20,
      mapping.k19,
      mapping.k18,
      mapping.k17,
      mapping.k16,
      mapping.k15,
      mapping.k14,
      mapping.k13,
      mapping.k12,
      mapping.k11,
      mapping.k10,
      mapping.k9,
      mapping.k8,
      mapping.k7,
      mapping.k6,
      mapping.k5,
      mapping.k4,
      mapping.kj3,
      mapping.k3,
      mapping.kj2,
      mapping.k2,
      mapping.kj1,
      mapping.k1,
      mapping.d1,
      mapping.d2,
      mapping.d3,
      mapping.d4,
      mapping.d5,
      mapping.d6,
      mapping.d7,
      mapping.d8,
      mapping.d9,
      mapping.d10,
      mapping.dan,
    ].whereType<Kyuui>();

    return [
      for (final kyuui in candidates)
        if (_tryCreateEntry(activity, denomination, kyuui) != null) kyuui,
    ];
  }

  KyuuiDenomination? _mappingFor(
    HolisticPracticeActivity activity,
    Denomination denomination,
  ) => switch ((activity, denomination)) {
    (HolisticPracticeActivity.flashAnzan, Denomination.zenshuren) =>
      KyuuiDenomination.zsFlash,
    (HolisticPracticeActivity.flashAnzan, Denomination.kyoukai) =>
      KyuuiDenomination.kkFlash,
    (HolisticPracticeActivity.flashAnzan, Denomination.nisshou) => null,
    (_, Denomination.zenshuren) => KyuuiDenomination.zs,
    (_, Denomination.nisshou) => KyuuiDenomination.ns,
    (_, Denomination.kyoukai) => null,
  };

  HolisticPracticePlaylistEntry? _tryCreateEntry(
    HolisticPracticeActivity activity,
    Denomination denomination,
    Kyuui kyuui,
  ) {
    try {
      return activity == HolisticPracticeActivity.flashAnzan
          ? HolisticPracticePlaylistEntry.flashAnzan(
              denomination: denomination,
              kyuui: kyuui,
            )
          : HolisticPracticePlaylistEntry.paperAnzan(
              activity: activity,
              denomination: denomination,
              kyuui: kyuui,
            );
    } on ArgumentError {
      return null;
    }
  }

  List<Denomination> _availableOrganizations(
    HolisticPracticeActivity activity,
  ) {
    final candidates = activity == HolisticPracticeActivity.flashAnzan
        ? [Denomination.zenshuren, Denomination.kyoukai]
        : [Denomination.zenshuren, Denomination.nisshou];
    return [
      for (final denomination in candidates)
        if (_availableGrades(activity, denomination).isNotEmpty) denomination,
    ];
  }

  HolisticPracticePlaylistEntry _entryFor(_PlaylistDraft draft) =>
      _tryCreateEntry(draft.activity, draft.denomination, draft.kyuui)!;

  void _updateActivity(
    _PlaylistDraft draft,
    HolisticPracticeActivity activity,
  ) {
    final organizations = _availableOrganizations(activity);
    final denomination = organizations.contains(draft.denomination)
        ? draft.denomination
        : organizations.first;
    final grades = _availableGrades(activity, denomination);
    setState(() {
      draft
        ..activity = activity
        ..denomination = denomination
        ..kyuui = grades.contains(draft.kyuui) ? draft.kyuui : grades.first;
    });
  }

  void _updateOrganization(_PlaylistDraft draft, Denomination denomination) {
    final grades = _availableGrades(draft.activity, denomination);
    setState(() {
      draft
        ..denomination = denomination
        ..kyuui = grades.contains(draft.kyuui) ? draft.kyuui : grades.first;
    });
  }

  void _addItem() {
    setState(() {
      if (_playlist.isNotEmpty) {
        final previous = _playlist.last;
        // A duplicate is intentional: each occurrence contributes weight.
        _playlist.add(
          _PlaylistDraft(
            activity: previous.activity,
            denomination: previous.denomination,
            kyuui: previous.kyuui,
          ),
        );
      } else {
        final activity = HolisticPracticeActivity.mitoriAnzan;
        final denomination = Denomination.zenshuren;
        _playlist.add(
          _PlaylistDraft(
            activity: activity,
            denomination: denomination,
            kyuui: _availableGrades(activity, denomination).first,
          ),
        );
      }
    });
  }

  void _continue(BuildContext context) {
    if (_playlist.isEmpty) return;
    final config = HolisticHandsFreePracticeConfig(
      playlist: _playlist.map(_entryFor),
      speedPercent: _speedPercent,
      thinkingDelay: Duration(seconds: _thinkingDelaySeconds),
      answerDisplayDwell: Duration(seconds: _answerDisplayDwellSeconds),
    );
    context.push('/holistic-hands-free-session', extra: config);
  }

  String _activityLabel(
    AppLocalizations l10n,
    HolisticPracticeActivity activity,
  ) => switch (activity) {
    HolisticPracticeActivity.mitoriAnzan => l10n.mitoriAnzan,
    HolisticPracticeActivity.multiplicationAnzan => l10n.multiplicationAnzan,
    HolisticPracticeActivity.divisionAnzan => l10n.divisionAnzan,
    HolisticPracticeActivity.flashAnzan => l10n.flashAnzanSubject,
  };

  String _durationLabel(AppLocalizations l10n, Duration duration) {
    final seconds = duration.inMilliseconds / Duration.millisecondsPerSecond;
    final formatted = seconds == seconds.roundToDouble()
        ? seconds.toStringAsFixed(0)
        : seconds.toStringAsFixed(1);
    return l10n.holisticSecondsValue(formatted);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: CustomAppBar(
        title: l10n.holisticHandsFreeSetupTitle,
        context: context,
        onBackPressed: () => context.pop(),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.holisticHandsFreeSetupSubtitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(l10n.holisticDuplicateHint),
                      const SizedBox(height: 16),
                      for (
                        var index = 0;
                        index < _playlist.length;
                        index++
                      ) ...[
                        _buildPlaylistItem(
                          context,
                          l10n,
                          index,
                          constraints.maxWidth,
                        ),
                        const SizedBox(height: 12),
                      ],
                      OutlinedButton.icon(
                        key: const ValueKey('holistic-add-item'),
                        onPressed: _addItem,
                        icon: const Icon(Icons.add_rounded),
                        label: Text(l10n.holisticAddItem),
                      ),
                      const SizedBox(height: 12),
                      _SetupCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.holisticSpeedHeading,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(l10n.holisticSpeedHint),
                            Row(
                              children: [
                                const Text('$_minimumSpeed%'),
                                Expanded(
                                  child: Slider(
                                    key: const ValueKey(
                                      'holistic-speed-slider',
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
                                const Text('$_maximumSpeed%'),
                              ],
                            ),
                            Center(
                              child: Text(
                                l10n.holisticCurrentSpeed(_speedPercent),
                                key: const ValueKey('holistic-current-speed'),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDelayCard(
                        context,
                        heading: l10n.holisticThinkingDelayHeading,
                        hint: l10n.holisticThinkingDelayHint,
                        keyName: 'holistic-thinking-delay-slider',
                        valueKeyName: 'holistic-thinking-delay-value',
                        seconds: _thinkingDelaySeconds,
                        onChanged: (value) =>
                            setState(() => _thinkingDelaySeconds = value),
                      ),
                      const SizedBox(height: 12),
                      _buildDelayCard(
                        context,
                        heading: l10n.holisticAnswerDwellHeading,
                        hint: l10n.holisticAnswerDwellHint,
                        keyName: 'holistic-answer-dwell-slider',
                        valueKeyName: 'holistic-answer-dwell-value',
                        seconds: _answerDisplayDwellSeconds,
                        onChanged: (value) =>
                            setState(() => _answerDisplayDwellSeconds = value),
                      ),
                      const SizedBox(height: 12),
                      _SetupCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.holisticDurationHeading,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            for (
                              var index = 0;
                              index < _playlist.length;
                              index++
                            )
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  l10n.handsFreeAnzanDurationPreview(
                                    '${index + 1}. ${_activityLabel(l10n, _playlist[index].activity)}',
                                    _durationLabel(
                                      l10n,
                                      _entryFor(
                                        _playlist[index],
                                      ).displayedProblemDuration(
                                        speedPercent: _speedPercent,
                                      ),
                                    ),
                                  ),
                                  key: ValueKey('holistic-duration-$index'),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.holisticSetupOnlyNotice,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      FilledButton.icon(
                        key: const ValueKey('holistic-setup-continue'),
                        onPressed: _playlist.isEmpty
                            ? null
                            : () => _continue(context),
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: Text(l10n.holisticContinue),
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

  Widget _buildPlaylistItem(
    BuildContext context,
    AppLocalizations l10n,
    int index,
    double viewportWidth,
  ) {
    final draft = _playlist[index];
    final activityOptions = HolisticPracticeActivity.values;
    final organizationOptions = _availableOrganizations(draft.activity);
    final gradeOptions = _availableGrades(draft.activity, draft.denomination);
    final availableWidth = (viewportWidth - 64).clamp(220.0, 896.0);
    final fieldWidth = availableWidth >= 760
        ? (availableWidth - 24) / 3
        : availableWidth >= 480
        ? (availableWidth - 12) / 2
        : availableWidth;

    return _SetupCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.holisticPlaylistItem(index + 1),
                  key: ValueKey('holistic-playlist-item-$index'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                key: ValueKey('holistic-remove-item-$index'),
                tooltip: l10n.holisticRemoveItem,
                onPressed: () => setState(() => _playlist.removeAt(index)),
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: fieldWidth,
                child: DropdownButtonFormField<HolisticPracticeActivity>(
                  key: ValueKey('holistic-activity-$index'),
                  initialValue: draft.activity,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: l10n.holisticActivity),
                  items: [
                    for (final activity in activityOptions)
                      DropdownMenuItem(
                        value: activity,
                        child: Text(
                          _activityLabel(l10n, activity),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (activity) {
                    if (activity != null) _updateActivity(draft, activity);
                  },
                ),
              ),
              SizedBox(
                width: fieldWidth,
                child: DropdownButtonFormField<Denomination>(
                  key: ValueKey('holistic-organization-$index'),
                  initialValue: draft.denomination,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l10n.holisticOrganization,
                  ),
                  items: [
                    for (final denomination in organizationOptions)
                      DropdownMenuItem(
                        value: denomination,
                        child: Text(
                          denomination.localizedName(l10n),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (denomination) {
                    if (denomination != null) {
                      _updateOrganization(draft, denomination);
                    }
                  },
                ),
              ),
              SizedBox(
                width: fieldWidth,
                child: DropdownButtonFormField<Kyuui>(
                  key: ValueKey('holistic-grade-$index'),
                  initialValue: draft.kyuui,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: l10n.grade),
                  items: [
                    for (final kyuui in gradeOptions)
                      DropdownMenuItem(
                        value: kyuui,
                        child: Text(kyuui.localizedLabel(l10n)),
                      ),
                  ],
                  onChanged: (kyuui) {
                    if (kyuui != null) {
                      setState(() => draft.kyuui = kyuui);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDelayCard(
    BuildContext context, {
    required String heading,
    required String hint,
    required String keyName,
    required String valueKeyName,
    required int seconds,
    required ValueChanged<int> onChanged,
  }) {
    final l10n = AppLocalizations.of(context);
    return _SetupCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(heading, style: Theme.of(context).textTheme.titleLarge),
          Text(hint),
          Row(
            children: [
              Text(l10n.holisticSecondsValue('$_minimumDelaySeconds')),
              Expanded(
                child: Slider(
                  key: ValueKey(keyName),
                  min: _minimumDelaySeconds.toDouble(),
                  max: _maximumDelaySeconds.toDouble(),
                  divisions: _maximumDelaySeconds - _minimumDelaySeconds,
                  label: l10n.holisticSecondsValue('$seconds'),
                  value: seconds.toDouble(),
                  onChanged: (value) => onChanged(value.round()),
                ),
              ),
              Text(l10n.holisticSecondsValue('$_maximumDelaySeconds')),
            ],
          ),
          Center(
            child: Text(
              l10n.holisticDelayValue(seconds),
              key: ValueKey(valueKeyName),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaylistDraft {
  _PlaylistDraft({
    required this.activity,
    required this.denomination,
    required this.kyuui,
  });

  HolisticPracticeActivity activity;
  Denomination denomination;
  Kyuui kyuui;
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
