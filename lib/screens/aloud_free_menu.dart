import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soroban_app/models/level_definitions.dart';
import 'package:soroban_app/models/singer_config.dart';
import 'package:soroban_app/screens/components/incrementer.dart';
import 'package:soroban_app/screens/components/labeled_sliding_segment.dart';
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
          'character',
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
      final int? characterIndex = _prefs.getInt('character');

      _character = characterIndex != null
          ? Character.values[characterIndex]
          : Character.shikokuMetan;
    });
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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          MediaQuery.of(context).orientation == Orientation.landscape
              ? 40
              : kToolbarHeight,
        ),
        child: AppBar(
          title: const Text('読み上げ算フリー'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/home'),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: .center,
              spacing: 16,
              children: [
                Wrap(
                  alignment: .center,
                  runSpacing: 16,
                  spacing: 16,
                  crossAxisAlignment: .center,
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
                            min: 3,
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
                    Column(
                      spacing: 16,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainer,
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
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium,
                              ),
                              SizedBox(width: 16),
                              LabeledSlidingSegmentedControl<bool>(
                                groupValue: _hasMinus,
                                options: const [(false, 'なし'), (true, 'あり')],
                                onValueChanged: (value) {
                                  setState(() {
                                    _hasMinus = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        VoiceSelectionButton(
                          character: _character,
                          onChanged: (selected) {
                            setState(() => _character = selected);
                          },
                        ),
                      ],
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
                  child: const Text('スタート'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VoiceSelectionButton extends StatelessWidget {
  const VoiceSelectionButton({
    super.key,
    required this.character,
    required this.onChanged,
  });

  final Character character;
  final ValueChanged<Character> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final selected = await Navigator.push<Character>(
          context,
          MaterialPageRoute(
            builder: (context) => VoiceSelectionPage(current: character),
          ),
        );
        if (selected != null) {
          onChanged(selected);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '声: ${character.displayString}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class VoiceSelectionPage extends StatelessWidget {
  const VoiceSelectionPage({super.key, required this.current});
  final Character current;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('声を選択')),
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            final crossAxisCount = orientation == Orientation.landscape ? 6 : 3;

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.6,
              ),
              itemCount: Character.values.length,
              itemBuilder: (context, index) {
                final character = Character.values[index];
                final isSelected = character == current;
                return _VoiceGridItem(
                  character: character,
                  isSelected: isSelected,
                  onTap: () => Navigator.pop(context, character),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _VoiceGridItem extends StatelessWidget {
  const _VoiceGridItem({
    required this.character,
    required this.isSelected,
    required this.onTap,
  });

  final Character character;
  final bool isSelected;
  final VoidCallback onTap;

  Future<void> _playSample(String assetPath) async {
    final source = await SoLoud.instance.loadAsset(assetPath);
    await SoLoud.instance.play(source);
    final duration = SoLoud.instance.getLength(source);
    Future.delayed(duration, () {
      SoLoud.instance.disposeSource(source);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.surfaceContainerHighest
              : colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.surfaceContainerHigh,
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.primary
                          : Colors.grey.withAlpha(80),
                      width: isSelected ? 4 : 3,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundImage: AssetImage(character.icon),
                    backgroundColor: colorScheme.surfaceContainerHigh,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Text(
                    character.displayString,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isSelected ? colorScheme.primary : null,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Symbols.play_circle,
                    weight: 200,
                    size: 60,
                    fill: 0,
                  ),
                  onPressed: () => _playSample(character.negaimasiteha),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
