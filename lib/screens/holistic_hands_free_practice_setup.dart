import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  static const _settingsKey = 'holistic_hands_free_setup';
  static const _settingsVersion = 1;
  static const _minimumSpeed = 50;
  static const _maximumSpeed = 200;
  static const _speedDivisions = 30;
  static const _speedStep = (_maximumSpeed - _minimumSpeed) ~/ _speedDivisions;
  static const _minimumDelaySeconds = 1;
  static const _maximumDelaySeconds = 15;

  final List<_PlaylistDraft> _playlist = [
    _PlaylistDraft(
      activity: HolisticPracticeActivity.mitoriAnzan,
      denomination: Denomination.zenshuren,
      kyuui: Kyuui.zsk10,
    ),
  ];
  final FocusNode _speedSliderFocusNode = FocusNode();
  final FocusNode _thinkingDelaySliderFocusNode = FocusNode();
  final FocusNode _answerDwellSliderFocusNode = FocusNode();
  int _speedPercent = 100;
  int _thinkingDelaySeconds = 5;
  int _answerDisplayDwellSeconds = 5;
  HolisticHandsFreeSelectionOrder _selectionOrder =
      HolisticHandsFreeSelectionOrder.randomSelection;
  SharedPreferencesWithCache? _prefs;
  late final Future<void> _settingsFuture;
  Future<void> _pendingSave = Future<void>.value();

  @override
  void initState() {
    super.initState();
    _settingsFuture = _loadSettings();
  }

  @override
  void dispose() {
    _saveSettings();
    _speedSliderFocusNode.dispose();
    _thinkingDelaySliderFocusNode.dispose();
    _answerDwellSliderFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferencesWithCache.create(
        cacheOptions: const SharedPreferencesWithCacheOptions(
          allowList: <String>{
            _settingsKey,
            'paper_kyuui',
            'paper_kyuuiDenomination',
            'flash_kyuui',
            'flash_kyuuiDenomination',
          },
        ),
      );
      _prefs = prefs;
      final savedSettings = prefs.getString(_settingsKey);
      if (savedSettings == null) {
        _initializePlaylistFromSavedPractice();
      } else {
        _restoreSettings(savedSettings);
      }
    } catch (error) {
      // Keep the default setup usable if preferences are unavailable.
      debugPrint('Unable to load hands-free practice settings: $error');
    }
  }

  void _restoreSettings(String? serializedSettings) {
    if (serializedSettings == null) return;

    try {
      final decoded = jsonDecode(serializedSettings);
      if (decoded is! Map<String, dynamic> ||
          decoded['version'] != _settingsVersion) {
        return;
      }

      final savedPlaylist = decoded['playlist'];
      if (savedPlaylist is List) {
        final restoredPlaylist = <_PlaylistDraft>[];
        for (final savedEntry in savedPlaylist) {
          if (savedEntry is! Map) continue;
          final activity = _enumByName(
            HolisticPracticeActivity.values,
            savedEntry['activity'],
          );
          final denomination = _enumByName(
            Denomination.values,
            savedEntry['denomination'],
          );
          final kyuui = _enumByName(Kyuui.values, savedEntry['kyuui']);
          if (activity == null || denomination == null || kyuui == null) {
            continue;
          }
          if (_tryCreateEntry(activity, denomination, kyuui) == null) continue;
          restoredPlaylist.add(
            _PlaylistDraft(
              activity: activity,
              denomination: denomination,
              kyuui: kyuui,
            ),
          );
        }

        // Preserve an intentional empty playlist, but ignore a non-empty list
        // if every entry is malformed or no longer supported.
        if (savedPlaylist.isEmpty || restoredPlaylist.isNotEmpty) {
          _playlist
            ..clear()
            ..addAll(restoredPlaylist);
        }
      }

      final savedSelectionOrder = _enumByName(
        HolisticHandsFreeSelectionOrder.values,
        decoded['selectionOrder'],
      );
      if (savedSelectionOrder != null) {
        _selectionOrder = savedSelectionOrder;
      }
      _speedPercent = _storedInt(
        decoded['speedPercent'],
        minimum: _minimumSpeed,
        maximum: _maximumSpeed,
        fallback: _speedPercent,
      );
      _thinkingDelaySeconds = _storedInt(
        decoded['thinkingDelaySeconds'],
        minimum: _minimumDelaySeconds,
        maximum: _maximumDelaySeconds,
        fallback: _thinkingDelaySeconds,
      );
      _answerDisplayDwellSeconds = _storedInt(
        decoded['answerDisplayDwellSeconds'],
        minimum: _minimumDelaySeconds,
        maximum: _maximumDelaySeconds,
        fallback: _answerDisplayDwellSeconds,
      );
    } on FormatException catch (error) {
      debugPrint('Ignoring invalid hands-free practice settings: $error');
    }
  }

  void _initializePlaylistFromSavedPractice() {
    final draft = _playlist.first;
    final savedPreference = _savedFlowPreference(draft.activity);
    final denomination = savedPreference.denomination;
    if (denomination == null ||
        !_availableOrganizations(draft.activity).contains(denomination)) {
      return;
    }

    final grades = _availableGrades(draft.activity, denomination);
    draft
      ..denomination = denomination
      ..kyuui = grades.contains(savedPreference.kyuui)
          ? savedPreference.kyuui!
          : grades.first;
  }

  int _storedInt(
    Object? value, {
    required int minimum,
    required int maximum,
    required int fallback,
  }) => value is int && value >= minimum && value <= maximum ? value : fallback;

  T? _enumByName<T extends Enum>(List<T> values, Object? name) {
    if (name is! String) return null;
    for (final value in values) {
      if (value.name == name) return value;
    }
    return null;
  }

  void _saveSettings() {
    final prefs = _prefs;
    if (prefs == null) return;

    final serializedSettings = jsonEncode({
      'version': _settingsVersion,
      'playlist': [
        for (final draft in _playlist)
          {
            'activity': draft.activity.name,
            'denomination': draft.denomination.name,
            'kyuui': draft.kyuui.name,
          },
      ],
      'selectionOrder': _selectionOrder.name,
      'speedPercent': _speedPercent,
      'thinkingDelaySeconds': _thinkingDelaySeconds,
      'answerDisplayDwellSeconds': _answerDisplayDwellSeconds,
    });

    final write = _pendingSave.then<void>((_) async {
      await prefs.setString(_settingsKey, serializedSettings);
    });
    _pendingSave = write.catchError((Object error, StackTrace stackTrace) {
      debugPrint('Unable to save hands-free practice settings: $error');
    });
  }

  Future<void> _finishSaving() => _pendingSave;

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

  ({Denomination? denomination, Kyuui? kyuui}) _savedFlowPreference(
    HolisticPracticeActivity activity,
  ) {
    final prefs = _prefs;
    if (prefs == null) return (denomination: null, kyuui: null);

    final isFlashAnzan = activity == HolisticPracticeActivity.flashAnzan;
    final kyuuiIndex = prefs.getInt(
      isFlashAnzan ? 'flash_kyuui' : 'paper_kyuui',
    );
    final denominationIndex = prefs.getInt(
      isFlashAnzan ? 'flash_kyuuiDenomination' : 'paper_kyuuiDenomination',
    );
    if (kyuuiIndex == null ||
        kyuuiIndex < 0 ||
        kyuuiIndex >= Kyuui.values.length ||
        denominationIndex == null ||
        denominationIndex < 0 ||
        denominationIndex >= KyuuiDenomination.values.length) {
      return (denomination: null, kyuui: null);
    }

    final denomination = switch ((
      isFlashAnzan,
      KyuuiDenomination.values[denominationIndex],
    )) {
      (true, KyuuiDenomination.zsFlash) => Denomination.zenshuren,
      (true, KyuuiDenomination.kkFlash) => Denomination.kyoukai,
      (false, KyuuiDenomination.zs) => Denomination.zenshuren,
      (false, KyuuiDenomination.ns) => Denomination.nisshou,
      _ => null,
    };

    return (denomination: denomination, kyuui: Kyuui.values[kyuuiIndex]);
  }

  HolisticPracticePlaylistEntry _entryFor(_PlaylistDraft draft) =>
      _tryCreateEntry(draft.activity, draft.denomination, draft.kyuui)!;

  void _updateActivity(
    _PlaylistDraft draft,
    HolisticPracticeActivity activity,
  ) {
    final organizations = _availableOrganizations(activity);
    final savedPreference = _savedFlowPreference(activity);
    final denomination = organizations.contains(savedPreference.denomination)
        ? savedPreference.denomination!
        : organizations.contains(draft.denomination)
        ? draft.denomination
        : organizations.first;
    final grades = _availableGrades(activity, denomination);
    final savedKyuui = savedPreference.denomination == denomination
        ? savedPreference.kyuui
        : null;
    setState(() {
      draft
        ..activity = activity
        ..denomination = denomination
        ..kyuui = grades.contains(savedKyuui)
            ? savedKyuui!
            : grades.contains(draft.kyuui)
            ? draft.kyuui
            : grades.first;
    });
    _saveSettings();
  }

  void _updateOrganization(_PlaylistDraft draft, Denomination denomination) {
    final grades = _availableGrades(draft.activity, denomination);
    setState(() {
      draft
        ..denomination = denomination
        ..kyuui = grades.contains(draft.kyuui) ? draft.kyuui : grades.first;
    });
    _saveSettings();
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
    _saveSettings();
  }

  Future<void> _continue(BuildContext context) async {
    if (_playlist.isEmpty) return;
    _saveSettings();
    await _finishSaving();
    if (!context.mounted) return;
    final config = HolisticHandsFreePracticeConfig(
      playlist: _playlist.map(_entryFor),
      selectionOrder: _selectionOrder,
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
        child: FutureBuilder<void>(
          future: _settingsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            return LayoutBuilder(
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
                                  l10n.holisticSelectionOrderHeading,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Text(l10n.holisticSelectionOrderHint),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<
                                  HolisticHandsFreeSelectionOrder
                                >(
                                  key: const ValueKey(
                                    'holistic-selection-order',
                                  ),
                                  initialValue: _selectionOrder,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    labelText:
                                        l10n.holisticSelectionOrderHeading,
                                  ),
                                  items: [
                                    DropdownMenuItem(
                                      value: HolisticHandsFreeSelectionOrder
                                          .playlistOrder,
                                      child: Text(
                                        l10n.holisticSelectionOrderPlaylist,
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: HolisticHandsFreeSelectionOrder
                                          .randomSelection,
                                      child: Text(
                                        l10n.holisticSelectionOrderRandom,
                                      ),
                                    ),
                                  ],
                                  onChanged: (selectionOrder) {
                                    if (selectionOrder != null) {
                                      setState(
                                        () => _selectionOrder = selectionOrder,
                                      );
                                      _saveSettings();
                                    }
                                  },
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
                                  l10n.holisticSpeedHeading,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Text(l10n.holisticSpeedHint),
                                Row(
                                  children: [
                                    const Text('$_minimumSpeed%'),
                                    Expanded(
                                      child: _buildAccessibleSlider(
                                        name: l10n.holisticSpeedHeading,
                                        value: l10n.holisticCurrentSpeed(
                                          _speedPercent,
                                        ),
                                        increasedValue: l10n
                                            .holisticCurrentSpeed(
                                              (_speedPercent + _speedStep)
                                                  .clamp(
                                                    _minimumSpeed,
                                                    _maximumSpeed,
                                                  )
                                                  .toInt(),
                                            ),
                                        decreasedValue: l10n
                                            .holisticCurrentSpeed(
                                              (_speedPercent - _speedStep)
                                                  .clamp(
                                                    _minimumSpeed,
                                                    _maximumSpeed,
                                                  )
                                                  .toInt(),
                                            ),
                                        focusNode: _speedSliderFocusNode,
                                        onIncrease: () => _updateSpeed(
                                          (_speedPercent + _speedStep)
                                              .clamp(
                                                _minimumSpeed,
                                                _maximumSpeed,
                                              )
                                              .toInt(),
                                        ),
                                        onDecrease: () => _updateSpeed(
                                          (_speedPercent - _speedStep)
                                              .clamp(
                                                _minimumSpeed,
                                                _maximumSpeed,
                                              )
                                              .toInt(),
                                        ),
                                        slider: Slider(
                                          // Slider.label is the transient visible
                                          // thumb indicator, so keep it value-based.
                                          key: const ValueKey(
                                            'holistic-speed-slider',
                                          ),
                                          min: _minimumSpeed.toDouble(),
                                          max: _maximumSpeed.toDouble(),
                                          divisions: _speedDivisions,
                                          label: l10n.holisticCurrentSpeed(
                                            _speedPercent,
                                          ),
                                          value: _speedPercent.toDouble(),
                                          focusNode: _speedSliderFocusNode,
                                          onChanged: (value) =>
                                              _updateSpeed(value.round()),
                                        ),
                                      ),
                                    ),
                                    const Text('$_maximumSpeed%'),
                                  ],
                                ),
                                Center(
                                  child: Text(
                                    l10n.holisticCurrentSpeed(_speedPercent),
                                    key: const ValueKey(
                                      'holistic-current-speed',
                                    ),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
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
                            focusNode: _thinkingDelaySliderFocusNode,
                            seconds: _thinkingDelaySeconds,
                            onChanged: _updateThinkingDelay,
                          ),
                          const SizedBox(height: 12),
                          _buildDelayCard(
                            context,
                            heading: l10n.holisticAnswerDwellHeading,
                            hint: l10n.holisticAnswerDwellHint,
                            keyName: 'holistic-answer-dwell-slider',
                            valueKeyName: 'holistic-answer-dwell-value',
                            focusNode: _answerDwellSliderFocusNode,
                            seconds: _answerDisplayDwellSeconds,
                            onChanged: _updateAnswerDisplayDwell,
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
            );
          },
        ),
      ),
    );
  }

  void _updateSpeed(int speedPercent) {
    setState(() => _speedPercent = speedPercent);
    _saveSettings();
  }

  void _updateThinkingDelay(int seconds) {
    setState(() => _thinkingDelaySeconds = seconds);
    _saveSettings();
  }

  void _updateAnswerDisplayDwell(int seconds) {
    setState(() => _answerDisplayDwellSeconds = seconds);
    _saveSettings();
  }

  void _removeItem(int index) {
    setState(() => _playlist.removeAt(index));
    _saveSettings();
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
                key: ValueKey('holistic-move-up-$index'),
                tooltip: l10n.holisticMoveItemUp(index + 1),
                onPressed: index == 0 ? null : () => _moveItem(index, -1),
                icon: const Icon(Icons.arrow_upward_rounded),
              ),
              IconButton(
                key: ValueKey('holistic-move-down-$index'),
                tooltip: l10n.holisticMoveItemDown(index + 1),
                onPressed: index == _playlist.length - 1
                    ? null
                    : () => _moveItem(index, 1),
                icon: const Icon(Icons.arrow_downward_rounded),
              ),
              IconButton(
                key: ValueKey('holistic-remove-item-$index'),
                tooltip: l10n.holisticRemoveItem,
                onPressed: () => _removeItem(index),
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
                  decoration: InputDecoration(labelText: l10n.holisticLevel),
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
                      _saveSettings();
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

  void _moveItem(int index, int offset) {
    final targetIndex = index + offset;
    if (targetIndex < 0 || targetIndex >= _playlist.length) return;
    setState(() {
      final item = _playlist.removeAt(index);
      _playlist.insert(targetIndex, item);
    });
    _saveSettings();
  }

  Widget _buildDelayCard(
    BuildContext context, {
    required String heading,
    required String hint,
    required String keyName,
    required String valueKeyName,
    required FocusNode focusNode,
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
                child: _buildAccessibleSlider(
                  name: heading,
                  value: l10n.holisticDelayValue(seconds),
                  increasedValue: l10n.holisticDelayValue(
                    (seconds + 1)
                        .clamp(_minimumDelaySeconds, _maximumDelaySeconds)
                        .toInt(),
                  ),
                  decreasedValue: l10n.holisticDelayValue(
                    (seconds - 1)
                        .clamp(_minimumDelaySeconds, _maximumDelaySeconds)
                        .toInt(),
                  ),
                  focusNode: focusNode,
                  onIncrease: () => onChanged(
                    (seconds + 1)
                        .clamp(_minimumDelaySeconds, _maximumDelaySeconds)
                        .toInt(),
                  ),
                  onDecrease: () => onChanged(
                    (seconds - 1)
                        .clamp(_minimumDelaySeconds, _maximumDelaySeconds)
                        .toInt(),
                  ),
                  slider: Slider(
                    key: ValueKey(keyName),
                    min: _minimumDelaySeconds.toDouble(),
                    max: _maximumDelaySeconds.toDouble(),
                    divisions: _maximumDelaySeconds - _minimumDelaySeconds,
                    label: l10n.holisticDelayValue(seconds),
                    value: seconds.toDouble(),
                    focusNode: focusNode,
                    onChanged: (value) => onChanged(value.round()),
                  ),
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

  Widget _buildAccessibleSlider({
    required String name,
    required String value,
    required String increasedValue,
    required String decreasedValue,
    required FocusNode focusNode,
    required VoidCallback onIncrease,
    required VoidCallback onDecrease,
    required Slider slider,
  }) => AnimatedBuilder(
    animation: focusNode,
    builder: (context, _) => Semantics(
      // Slider.label drives both the painted value indicator and the native
      // slider's semantic label. Keep the display value on the Slider itself
      // and expose its focused semantics as a separate proxy node here.
      container: true,
      label: name,
      value: value,
      increasedValue: increasedValue,
      decreasedValue: decreasedValue,
      enabled: slider.onChanged != null && slider.max > slider.min,
      slider: true,
      focusable: true,
      focused: focusNode.hasFocus,
      onFocus: focusNode.requestFocus,
      onDidGainAccessibilityFocus: focusNode.requestFocus,
      onIncrease: onIncrease,
      onDecrease: onDecrease,
      child: ExcludeSemantics(child: slider),
    ),
  );
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
