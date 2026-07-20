import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soroban_app/models/level_definitions.dart';
import 'package:soroban_app/models/singer_config.dart';
import 'package:soroban_app/screens/components/incrementer.dart';
import 'package:soroban_app/screens/components/navigation_button.dart';

class AloudFreeMenuPage extends StatefulWidget {
  const AloudFreeMenuPage({super.key});

  @override
  State<AloudFreeMenuPage> createState() => AloudFreeMenuPageState();
}

class AloudFreeMenuPageState extends State<AloudFreeMenuPage> {
  int _moraPerSecond = 5;
  int _msPerInterval = 1500;
  int _kuchi = 5;
  int _minDigits = 2;
  int _maxDigits = 5;
  bool _hasMinus = true;
  Character _character = .shikokuMetan;
  late final SharedPreferencesWithCache _prefs;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    _prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: <String>{
          'moraPerSecond',
          'msPerInterval',
          'kuchi',
          'minDigits',
          'maxDigits',
          'hasMinus',
        },
      ),
    );

    setState(() {
      _moraPerSecond = _prefs.getInt('moraPerSecond') ?? 5;
      _msPerInterval = _prefs.getInt('msPerInterval') ?? 1500;
      _kuchi = _prefs.getInt('kuchi') ?? 5;
      _minDigits = _prefs.getInt('minDigits') ?? 2;
      _maxDigits = _prefs.getInt('maxDigits') ?? 5;
      _hasMinus = _prefs.getBool('hasMinus') ?? true;
    });
  }

  TextStyle _segmentStyle(BuildContext context, bool isSelected) {
    return Theme.of(context).textTheme.headlineMedium!.copyWith(
      color: isSelected
          ? Theme.of(context).colorScheme.onSurface
          : Theme.of(context).colorScheme.onSurface.withAlpha(80),
    );
  }

  void _showVoicePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: Character.values.map((c) {
            return ListTile(
              title: Text(c.displayString),
              trailing: c == _character ? const Icon(Icons.check) : null,
              onTap: () {
                setState(() => _character = c);
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  @override
  void dispose() {
    _prefs.setInt('moraPerSecond', _moraPerSecond);
    _prefs.setInt('msPerInterval', _msPerInterval);
    _prefs.setBool('hasMinus', _hasMinus);
    _prefs.setInt('kuchi', _kuchi);
    _prefs.setInt('minDigits', _minDigits);
    _prefs.setInt('maxDigits', _maxDigits);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('読み上げ算フリー'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: .center,
              children: [
                Wrap(
                  alignment: .center,
                  runSpacing: 16,
                  spacing: 16,
                  children: [
                    FittedBox(
                      fit: .contain,
                      child: Row(
                        children: [
                          Incrementer(
                            value: _kuchi,
                            label: '口数',
                            onChanged: (newValue) =>
                                setState(() => _kuchi = newValue.toInt()),
                            min: 2,
                            max: 30,
                          ),
                          SizedBox(width: 16),
                          RangeIncrementer(
                            minValue: _minDigits,
                            maxValue: _maxDigits,
                            label: '桁数',
                            onChanged: (newValue) {
                              final (newMin, newMax) = newValue;
                              setState(() {
                                _minDigits = newMin;
                                _maxDigits = newMax;
                              });
                            },
                            min: 1,
                            max: 16,
                          ),
                        ],
                      ),
                    ),
                    FittedBox(
                      child: Row(
                        children: [
                          Incrementer(
                            value: _moraPerSecond,
                            label: '読上速度',
                            onChanged: (newValue) => setState(
                              () => _moraPerSecond = newValue.toInt(),
                            ),
                            min: 1,
                            max: 12,
                          ),
                          SizedBox(width: 16),
                          Incrementer(
                            value: _msPerInterval,
                            label: '読上間隔',
                            onChanged: (newValue) =>
                                setState(() => _msPerInterval = newValue),
                            min: 100,
                            max: 5000,
                            step: 100,
                            displayValue: '${_msPerInterval / 1000}',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Wrap(
                  alignment: .center,
                  runSpacing: 16,
                  spacing: 16,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: .all(12),

                      child: Row(
                        mainAxisSize: .min,
                        mainAxisAlignment: .center,
                        crossAxisAlignment: .center,
                        children: [
                          Text(
                            '引き算',
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                          SizedBox(width: 16),
                          CupertinoSlidingSegmentedControl<bool>(
                            groupValue: _hasMinus,
                            children: {
                              false: Text(
                                'なし',
                                style: _segmentStyle(context, !_hasMinus),
                              ),
                              true: Text(
                                'あり',
                                style: _segmentStyle(context, _hasMinus),
                              ),
                            },
                            onValueChanged: (bool? value) {
                              if (value != null) {
                                setState(() {
                                  _hasMinus = value;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showVoicePicker(context),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '声: ${_character.displayString}',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.chevron_right,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                NavigationButton(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  onPressed: () {
                    AloudSingleProblemSpec spec = AloudSingleProblemSpec(
                      kuchi: _kuchi,
                      moraPerSecond: _moraPerSecond,
                      msPerInterval: _msPerInterval,
                      minDigits: _minDigits,
                      maxDigits: _maxDigits,
                      minusCount: _hasMinus ? (_kuchi * 0.3).round() : 0,
                    );
                    context.push(
                      '/aloud-problem',
                      extra: {
                        'isSingleProblem': true,
                        'selectedLevel': spec,
                        'character': _character,
                      },
                    );
                  },
                  label: 'スタート',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
