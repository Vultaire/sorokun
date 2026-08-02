import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soroban_app/models/level_definitions.dart';
import 'package:soroban_app/models/singer_config.dart';
import 'package:soroban_app/screens/aloud_free_menu.dart';
import 'package:soroban_app/screens/components/appbar.dart';
import 'package:soroban_app/screens/components/start_button.dart';
import 'package:soroban_app/screens/paper_menu.dart';
import 'package:soroban_app/screens/flash_level_menu.dart';

class AloudLevelMenuPage extends StatefulWidget {
  const AloudLevelMenuPage({super.key});

  @override
  State<AloudLevelMenuPage> createState() => _AloudLevelMenuPageState();
}

class _AloudLevelMenuPageState extends State<AloudLevelMenuPage> {
  Kyuui _kyuui = .zsk9;
  KyuuiDenomination _kyuuiDenomination = .zsAloudAndFlash;
  int _zsIndex = 0;
  Character _character = .shikokuMetan;
  late final SharedPreferencesWithCache _prefs;

  @override
  void initState() {
    super.initState();
    _prefsFuture = _loadPrefs();
  }

  late final Future<void> _prefsFuture;

  Future<void> _loadPrefs() async {
    _prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: <String>{
          'aloud_kyuui',
          'aloud_kyuuiDenomination',
          'aloud_zsIndex',
          'character',
        },
      ),
    );
    final kyuuiIndex = _prefs.getInt('aloud_kyuui');
    final characterIndex = _prefs.getInt('character');
    final denominationIndex = _prefs.getInt('aloud_kyuuiDenomination');
    final zsIndex = _prefs.getInt('aloud_zsIndex');
    if (zsIndex != null) {
      _zsIndex = zsIndex;
    }
    if (kyuuiIndex != null) {
      _kyuui = Kyuui.values[kyuuiIndex];
    }
    if (denominationIndex != null) {
      _kyuuiDenomination = KyuuiDenomination.values[denominationIndex];
    }
    if (characterIndex != null) {
      _character = Character.values[characterIndex];
    }
  }

  List<Kyuui> _buildKyuuiList(KyuuiDenomination denomination) => [
    denomination.k10,
    denomination.k9,
    denomination.k8,
    denomination.k7,
    denomination.k6,
    denomination.k5,
    denomination.k4,
    denomination.k3,
    denomination.k2,
    denomination.k1,
    denomination.d1,
    denomination.d2,
    denomination.d3,
    denomination.d4,
    denomination.d5,
    denomination.d6,
    denomination.d7,
    denomination.d8,
    denomination.d9,
    denomination.d10,
  ].whereType<Kyuui>().toList();

  @override
  void dispose() {
    _prefs.setInt('aloud_kyuui', _kyuui.index);
    _prefs.setInt('aloud_kyuuiDenomination', _kyuuiDenomination.index);
    _prefs.setInt('aloud_zsIndex', _zsIndex);
    _prefs.setInt('character', _character.index);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: '読み上げ算検定', context: context),
      body: SafeArea(
        child: FutureBuilder(
          future: _prefsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: OrientationBuilder(
                    builder: (context, orientation) {
                      final isPortrait = orientation == .portrait;
                      final selector = KyuuiSelector(
                        kyuuiList: _buildKyuuiList(
                          KyuuiDenomination.zsAloudAndFlash,
                        ),
                        currentIndex: _zsIndex,
                        onChanged: (index, kyuui) {
                          setState(() {
                            _zsIndex = index;
                            _kyuui = kyuui;
                          });
                        },
                      );

                      return Column(
                        mainAxisAlignment: .center,
                        crossAxisAlignment: .stretch,
                        children: [
                          Expanded(
                            flex: 6,
                            child: Flex(
                              direction: isPortrait ? .vertical : .horizontal,
                              crossAxisAlignment: .stretch,
                              children: [
                                isPortrait
                                    ? SizedBox(height: 80, child: selector)
                                    : Expanded(flex: 1, child: selector),
                                Expanded(
                                  flex: isPortrait ? 1 : 6,
                                  child: Center(
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints.tightFor(
                                        height: isPortrait
                                            ? double.infinity
                                            : 600,
                                      ),
                                      child: AloudInfoDialog(
                                        selectedLevel: _kyuui.aloud!,
                                        isPortrait: isPortrait,
                                        character: _character,
                                        onCharacterChanged: (selected) {
                                          setState(() => _character = selected);
                                        },
                                        examDisplayString:
                                            '${_kyuui.kyuuString}の読み上げ算',
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class AloudInfoDialog extends StatelessWidget {
  const AloudInfoDialog({
    super.key,
    required this.selectedLevel,
    required this.isPortrait,
    required this.character,
    required this.onCharacterChanged,
    required this.examDisplayString,
  });

  final AloudLevel selectedLevel;
  final bool isPortrait;
  final Character character;
  final ValueChanged<Character> onCharacterChanged;
  final String examDisplayString;

  @override
  Widget build(BuildContext context) {
    final int probCount = selectedLevel.probCount;
    final int moraPerSecond = selectedLevel.moraPerSecond;
    final bool hasMinus = selectedLevel.hasMinus;
    final int minDigits = selectedLevel.minDigits;
    final int maxDigits = selectedLevel.maxDigits;
    final int kuchi = selectedLevel.kuchi;
    final int msPerInterval = selectedLevel.msPerInterval;
    final String denominationString =
        selectedLevel.levelInfo.denomination.denominationString;
    final int passThreshold =
        (selectedLevel.levelInfo.passThreshold * probCount).round() * 10;

    final String digitsString;
    if (minDigits != maxDigits) {
      digitsString = '$minDigits〜$maxDigits';
    } else {
      digitsString = '$minDigits';
    }
    final String minusString = hasMinus ? '加減算' : '加算';
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final infoTextStyle = textTheme.titleLarge!.copyWith(
      fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
    );

    return Material(
      color: colorScheme.surfaceContainer,
      borderRadius: .circular(24),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: .min,
          mainAxisAlignment: .spaceEvenly,
          crossAxisAlignment: .center,
          children: [
            FittedBox(
              child: Text(denominationString, style: textTheme.headlineLarge),
            ),
            FittedBox(
              fit: .scaleDown,
              child: Material(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: .circular(24),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: isPortrait ? 250 : 900,
                    child: Flex(
                      direction: isPortrait ? .vertical : .horizontal,
                      mainAxisAlignment: .spaceEvenly,
                      children: [
                        Text(minusString, style: textTheme.displayMedium),
                        divider(context, isPortrait),
                        statCell(context, digitsString, '桁'),
                        divider(context, isPortrait),
                        statCell(context, '$kuchi', '口'),
                        divider(context, isPortrait),
                        statCell(context, '$moraPerSecond', '拍/秒'),
                        divider(context, isPortrait),
                        statCell(context, '${msPerInterval / 1000}', '秒間隔'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('全$probCount問 各10点', style: infoTextStyle),
                Text('  ・  ', style: infoTextStyle),
                Text('$passThreshold点で合格', style: infoTextStyle),
              ],
            ),
            VoiceSelectionButton(
              character: character,
              onChanged: onCharacterChanged,
            ),
            StartButton(
              onPressed: () {
                context.push(
                  '/aloud-problem',
                  extra: {
                    'isSingleProblem': false,
                    'selectedLevel': selectedLevel,
                    'character': character,
                    'examDisplayString': examDisplayString,
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
