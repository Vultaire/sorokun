import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soroban_app/models/level_definitions.dart';
import 'package:soroban_app/models/singer_config.dart';
import 'package:soroban_app/problem_generation/voicevox_synth_worker.dart';
import 'package:soroban_app/screens/components/appbar.dart';
import 'package:soroban_app/screens/components/incrementer.dart';
import 'package:soroban_app/screens/components/labeled_sliding_segment.dart';
import 'package:soroban_app/screens/components/start_button.dart';

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
    VoicevoxSynthWorker.instance.acquire();
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
    VoicevoxSynthWorker.instance.release();

    _prefs.setInt('moraPerSecond', _moraPerSecond);
    _prefs.setInt('msPerInterval', _msPerInterval);
    _prefs.setBool('hasMinus', _hasMinus);
    _prefs.setInt('kuchi', _kuchi);
    _prefs.setInt('minDigits', _minDigits);
    _prefs.setInt('maxDigits', _maxDigits);
    _prefs.setInt('character', _character.index);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: '読み上げ算フリー', context: context),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: OrientationBuilder(
              builder: (context, orientation) {
                final isPortrait = orientation == Orientation.portrait;

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final incrementers = Flex(
                      direction: isPortrait ? Axis.vertical : Axis.horizontal,
                      spacing: 16,
                      children: [
                        FittedBox(
                          fit: BoxFit.contain,
                          child: Row(
                            children: [
                              Incrementer(
                                value: _kuchi,
                                label: '口数',
                                onChanged: (newValue) =>
                                    setState(() => _kuchi = newValue.toInt()),
                                min: 1,
                                max: 30,
                              ),
                              const SizedBox(width: 16),
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
                          fit: BoxFit.contain,
                          child: Row(
                            children: [
                              Incrementer(
                                value: _moraPerSecond,
                                label: '読上速度',
                                onChanged: (newValue) => setState(
                                  () => _moraPerSecond = newValue.toInt(),
                                ),
                                min: 3,
                                max: 14,
                              ),
                              const SizedBox(width: 16),
                              Incrementer(
                                value: _msPerInterval,
                                label: '読上間隔',
                                onChanged: (newValue) =>
                                    setState(() => _msPerInterval = newValue),
                                min: 100,
                                max: 3000,
                                step: 100,
                                displayValue: '${_msPerInterval / 1000}',
                              ),
                            ],
                          ),
                        ),
                      ],
                    );

                    final minusAndVoiceSelection = Flex(
                      direction: isPortrait ? Axis.vertical : Axis.horizontal,
                      spacing: 16,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '引き算',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(width: 16),
                            ConstrainedBox(
                              constraints: BoxConstraints(minWidth: 240),
                              child: LabeledSlidingSegmentedControl<bool>(
                                groupValue: _hasMinus,
                                options: const [(false, 'なし'), (true, 'あり')],
                                onValueChanged: (value) {
                                  setState(() {
                                    _hasMinus = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        VoiceSelectionButton(
                          character: _character,
                          onChanged: (selected) {
                            setState(() => _character = selected);
                          },
                        ),
                      ],
                    );

                    final startButton = StartButton(
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
                    );

                    // Portrait Layout
                    if (isPortrait) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        spacing: 16,
                        children: [
                          Flexible(
                            child: SizedBox(
                              width: 490,
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  spacing: 16,
                                  children: [
                                    incrementers,
                                    minusAndVoiceSelection,
                                  ],
                                ),
                              ),
                            ),
                          ),
                          startButton,
                        ],
                      );
                    }

                    // Landscape Layout
                    final content = Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        incrementers,
                        const SizedBox(height: 24),
                        minusAndVoiceSelection,
                        const SizedBox(height: 24),
                      ],
                    );

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Flexible(
                          child: SizedBox(
                            width: 800,
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: content,
                            ),
                          ),
                        ),
                        startButton,
                      ],
                    );
                  },
                );
              },
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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
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
      child: Material(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(24),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 12, 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '声: ${character.displayString}',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Symbols.arrow_forward_ios_rounded,
                size: 28,
                fontWeight: .w700,
                color: colorScheme.onSecondaryContainer,
              ),
            ],
          ),
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
      appBar: CustomAppBar(
        title: '声を選択',
        context: context,
        onBackPressed: () => context.pop(),
      ),
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            final screenWidth = MediaQuery.sizeOf(context).width;
            final isLandscape = orientation == Orientation.landscape;
            final isLargeScreen = screenWidth >= 600;

            final int crossAxisCount;
            if (isLandscape) {
              crossAxisCount = 6;
            } else if (isLargeScreen) {
              crossAxisCount = 5;
            } else {
              crossAxisCount = 3;
            }

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
    SoLoud.instance.play(source);
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
      child: Material(
        color: isSelected
            ? colorScheme.surfaceContainerHighest
            : colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: FittedBox(
            fit: .scaleDown,
            child: Column(
              mainAxisAlignment: .spaceEvenly,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.surfaceContainerHigh,
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.outlineVariant,
                      width: isSelected ? 4 : 3,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundImage: AssetImage(character.icon),
                    backgroundColor: isSelected
                        ? colorScheme.surfaceContainer
                        : colorScheme.surface,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: SizedBox(
                    width: 110,
                    child: FittedBox(
                      fit: .scaleDown,
                      child: Text(
                        character.displayString,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: isSelected
                              ? colorScheme.onSecondaryContainer
                              : null,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Symbols.play_circle_rounded,
                    size: 60,
                    fill: 0,
                    weight: 300,
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
