// Modified by Vultaire on 2026-11-01.
// Fork: https://github.com/Vultaire/sorokun
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soroban_app/models/level_definitions.dart';
import 'package:soroban_app/screens/components/appbar.dart';
import 'package:soroban_app/screens/components/labeled_sliding_segment.dart';
import 'package:soroban_app/screens/components/start_button.dart';
import 'package:soroban_app/screens/paper_menu.dart';

class FlashLevelMenuPage extends StatefulWidget {
  const FlashLevelMenuPage({super.key});

  @override
  State<FlashLevelMenuPage> createState() => _FlashLevelMenuPageState();
}

class _FlashLevelMenuPageState extends State<FlashLevelMenuPage> {
  Kyuui _kyuui = .zsk20;
  KyuuiDenomination _kyuuiDenomination = .zsFlash;
  int _zsIndex = 0;
  int _kkIndex = 0;
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
          'flash_kyuui',
          'flash_kyuuiDenomination',
          'flash_zsIndex',
          'flash_kkIndex',
        },
      ),
    );
    final kyuuiIndex = _prefs.getInt('flash_kyuui');
    final denominationIndex = _prefs.getInt('flash_kyuuiDenomination');
    final zsIndex = _prefs.getInt('flash_zsIndex');
    final kkIndex = _prefs.getInt('flash_kkIndex');
    if (zsIndex != null) {
      _zsIndex = zsIndex;
    }
    if (kkIndex != null) {
      _kkIndex = kkIndex;
    }
    if (kyuuiIndex != null) {
      _kyuui = Kyuui.values[kyuuiIndex];
    }
    if (denominationIndex != null) {
      _kyuuiDenomination = KyuuiDenomination.values[denominationIndex];
    }
  }

  void _savePrefs() {
    _prefs.setInt('flash_kyuui', _kyuui.index);
    _prefs.setInt('flash_kyuuiDenomination', _kyuuiDenomination.index);
    _prefs.setInt('flash_zsIndex', _zsIndex);
    _prefs.setInt('flash_kkIndex', _kkIndex);
  }

  List<Kyuui> _buildFlashKyuuiList(KyuuiDenomination denomination) => [
    denomination.k20,
    denomination.k19,
    denomination.k18,
    denomination.k17,
    denomination.k16,
    denomination.k15,
    denomination.k14,
    denomination.k13,
    denomination.k12,
    denomination.k11,
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
    _savePrefs();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'フラッシュ暗算もぎ検定', context: context),
      body: SafeArea(
        child: FutureBuilder(
          future: _prefsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: OrientationBuilder(
                    builder: (context, orientation) {
                      final bool isPortrait =
                          orientation == Orientation.portrait;

                      final selectorStack = KyuuiSelectorStack(
                        primaryDenomination: KyuuiDenomination.zsFlash,
                        secondaryDenomination: KyuuiDenomination.kkFlash,
                        initialPrimaryIndex: _zsIndex,
                        initialSecondaryIndex: _kkIndex,
                        kyuuiListBuilder: _buildFlashKyuuiList,
                        activeDenomination: _kyuuiDenomination,
                        onChanged: (denomination, index, kyuui) {
                          setState(() {
                            _kyuui = kyuui;
                            if (denomination == KyuuiDenomination.zsFlash) {
                              _zsIndex = index;
                            } else {
                              _kkIndex = index;
                            }
                          });
                        },
                      );

                      final denominationSelector =
                          LabeledSlidingSegmentedControl<KyuuiDenomination>(
                            groupValue: _kyuuiDenomination,
                            options: const [
                              (KyuuiDenomination.zsFlash, '全珠連'),
                              (KyuuiDenomination.kkFlash, '協会'),
                            ],
                            onValueChanged: (value) {
                              setState(() {
                                _kyuuiDenomination = value;
                                final newList = _buildFlashKyuuiList(value);
                                final newIndex =
                                    value == KyuuiDenomination.zsFlash
                                    ? _zsIndex
                                    : _kkIndex;
                                _kyuui = newList[newIndex];
                              });
                            },
                          );

                      return isPortrait
                          ? Column(
                              crossAxisAlignment: .stretch,
                              children: [
                                denominationSelector,
                                const SizedBox(height: 6),
                                SizedBox(height: 80, child: selectorStack),
                                const SizedBox(height: 6),
                                Expanded(
                                  child: FlashInfoDialog(
                                    selectedLevel: _kyuui.flash!,
                                    isPortrait: isPortrait,
                                    examDisplayString:
                                        '${_kyuui.kyuuString}のフラッシュ暗算',
                                    savePrefs: _savePrefs,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: .stretch,
                              children: [
                                Expanded(flex: 1, child: selectorStack),
                                Expanded(
                                  flex: 6,
                                  child: Column(
                                    crossAxisAlignment: .stretch,
                                    children: [
                                      denominationSelector,
                                      const SizedBox(height: 6),
                                      Expanded(
                                        child: Center(
                                          child: ConstrainedBox(
                                            constraints:
                                                const BoxConstraints.tightFor(
                                                  height: 600,
                                                ),
                                            child: FlashInfoDialog(
                                              selectedLevel: _kyuui.flash!,
                                              isPortrait: isPortrait,
                                              examDisplayString:
                                                  '${_kyuui.kyuuString}のフラッシュ暗算',
                                              savePrefs: _savePrefs,
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

class FlashInfoDialog extends StatelessWidget {
  const FlashInfoDialog({
    super.key,
    required this.selectedLevel,
    required this.isPortrait,
    required this.examDisplayString,
    required this.savePrefs,
  });
  final FlashLevel selectedLevel;
  final bool isPortrait;
  final String examDisplayString;
  final VoidCallback savePrefs;

  @override
  Widget build(BuildContext context) {
    final int probCount = selectedLevel.probCount;
    final double secondsPerProblem = selectedLevel.secondsPerProblem;
    final int digits = selectedLevel.digits;
    final int kuchi = selectedLevel.kuchi;
    final bool kuriagariNashi = selectedLevel.kuriagariNashi;
    final String denominationString =
        selectedLevel.levelInfo.denomination.denominationString;
    final int passThreshold =
        (selectedLevel.levelInfo.passThreshold * probCount).round() * 10;

    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final infoTextStyle = textTheme.titleLarge;

    return Material(
      color: colorScheme.surfaceContainerLow,
      borderRadius: .circular(24),
      elevation: 4,
      child: Padding(
        padding: const .all(12.0),
        child: Column(
          mainAxisAlignment: .spaceEvenly,
          spacing: 16,
          crossAxisAlignment: .center,
          children: [
            Flexible(
              child: SizedBox(
                width: isPortrait ? 500 : 700,
                child: FittedBox(
                  fit: .contain,
                  child: Column(
                    spacing: 16,
                    children: [
                      SizedBox(
                        width: 300,
                        child: FittedBox(
                          fit: .contain,
                          child: Text(
                            textAlign: .center,
                            denominationString,
                            style: textTheme.headlineLarge,
                          ),
                        ),
                      ),
                      Material(
                        color: colorScheme.surfaceContainerHigh,
                        borderRadius: .circular(24),
                        elevation: 8,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: SizedBox(
                            width: isPortrait ? 200 : 500,
                            child: Flex(
                              direction: isPortrait ? .vertical : .horizontal,
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                statCell(context, '$digits', '桁'),
                                divider(context, isPortrait),
                                statCell(context, '$kuchi', '口'),
                                divider(context, isPortrait),
                                statCell(context, '$secondsPerProblem', '秒'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      isPortrait
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('全$probCount問 各10点', style: infoTextStyle),
                                Text(
                                  '$passThreshold点で合格',
                                  style: infoTextStyle,
                                ),
                                if (kuriagariNashi)
                                  Text('くりあがりなし', style: infoTextStyle),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('全$probCount問 各10点', style: infoTextStyle),
                                Text('  ・  ', style: infoTextStyle),
                                Text(
                                  '$passThreshold点で合格',
                                  style: infoTextStyle,
                                ),
                                if (kuriagariNashi) ...[
                                  Text('  ・  ', style: infoTextStyle),
                                  Text('くりあがりなし', style: infoTextStyle),
                                ],
                              ],
                            ),
                    ],
                  ),
                ),
              ),
            ),
            StartButton(
              onPressed: () {
                savePrefs();
                context.push(
                  '/flash-problem',
                  extra: {
                    'selectedLevel': selectedLevel,
                    'isSingleProblem': false,
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

Widget statCell(BuildContext context, String value, String unit) {
  final textTheme = Theme.of(context).textTheme;
  return Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.baseline,
    textBaseline: TextBaseline.alphabetic,
    children: [
      Text(
        value,
        style: textTheme.displayLarge!.copyWith(
          fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
        ),
      ),
      Text(unit, style: textTheme.displaySmall),
    ],
  );
}

Widget divider(BuildContext context, bool isPortrait) {
  return isPortrait
      ? SizedBox(
          width: 140,
          child: Divider(
            color: Theme.of(context).colorScheme.outline,
            thickness: 1,
          ),
        )
      : SizedBox(
          height: 48,
          child: VerticalDivider(
            color: Theme.of(context).colorScheme.outline,
            thickness: 1,
          ),
        );
}
