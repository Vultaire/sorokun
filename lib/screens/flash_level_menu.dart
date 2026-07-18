import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soroban_app/models/level_definitions.dart';
import 'package:soroban_app/screens/components/navigation_button.dart';
import 'package:soroban_app/screens/paper_menu.dart';

class FlashLevelMenuPage extends StatefulWidget {
  const FlashLevelMenuPage({super.key});

  @override
  State<FlashLevelMenuPage> createState() => _FlashLevelMenuPageState();
}

class _FlashLevelMenuPageState extends State<FlashLevelMenuPage> {
  Kyuui _kyuui = .zsk20;
  KyuuiDenomination _kyuuiDenomination = .zsAloudAndFlash;
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
    _prefs.setInt('flash_kyuui', _kyuui.index);
    _prefs.setInt('flash_kyuuiDenomination', _kyuuiDenomination.index);
    _prefs.setInt('flash_zsIndex', _zsIndex);
    _prefs.setInt('flash_kkIndex', _kkIndex);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('フラッシュ暗算検定'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: _prefsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: OrientationBuilder(
                    builder: (context, orientation) {
                      final bool isPortrait =
                          orientation == Orientation.portrait;

                      final TextTheme textStyle = Theme.of(context).textTheme;

                      final selectorStack = KyuuiSelectorStack(
                        primaryDenomination: KyuuiDenomination.zsAloudAndFlash,
                        secondaryDenomination: KyuuiDenomination.kkFlash,
                        initialPrimaryIndex: _zsIndex,
                        initialSecondaryIndex: _kkIndex,
                        kyuuiListBuilder: _buildFlashKyuuiList,
                        activeDenomination: _kyuuiDenomination,
                        onChanged: (denomination, index, kyuui) {
                          setState(() {
                            _kyuui = kyuui;
                            if (denomination ==
                                KyuuiDenomination.zsAloudAndFlash) {
                              _zsIndex = index;
                            } else {
                              _kkIndex = index;
                            }
                          });
                        },
                      );

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 6,
                            child: Flex(
                              direction: isPortrait
                                  ? Axis.vertical
                                  : Axis.horizontal,
                              children: [
                                isPortrait
                                    ? SizedBox(
                                        height: 100,
                                        child: selectorStack,
                                      )
                                    : Expanded(flex: 1, child: selectorStack),
                                Expanded(
                                  flex: isPortrait ? 1 : 5,
                                  child: Flex(
                                    direction: isPortrait
                                        ? .vertical
                                        : .horizontal,
                                    children: [
                                      Expanded(
                                        child: FlashInfoDialog(
                                          selectedLevel: _kyuui.flash!,
                                          isPortrait: isPortrait,
                                        ),
                                      ),
                                      Container(
                                        margin: .symmetric(
                                          horizontal: 24,
                                          vertical: 6,
                                        ),
                                        child: NavigationButton(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.surfaceContainerHighest,
                                          label: 'スタート',
                                          onPressed: () {
                                            context.push(
                                              '/flash-problem',
                                              extra: {
                                                'selectedLevel': _kyuui.flash,
                                                'isSingleProblem': false,
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 6),
                          Flex(
                            mainAxisAlignment: .spaceEvenly,
                            direction: isPortrait
                                ? Axis.vertical
                                : Axis.horizontal,
                            children: [
                              SegmentedButton<KyuuiDenomination>(
                                segments: <ButtonSegment<KyuuiDenomination>>[
                                  ButtonSegment(
                                    value: KyuuiDenomination.zsAloudAndFlash,
                                    label: Text(
                                      '全国珠算教育連盟',
                                      style: textStyle.titleMedium,
                                    ),
                                  ),
                                  ButtonSegment(
                                    value: KyuuiDenomination.kkFlash,
                                    label: Text(
                                      '日本フラッシュ暗算協会',
                                      style: textStyle.titleMedium,
                                    ),
                                  ),
                                ],
                                selected: {_kyuuiDenomination},
                                showSelectedIcon: false,
                                onSelectionChanged:
                                    (Set<KyuuiDenomination> newSelection) {
                                      setState(() {
                                        _kyuuiDenomination = newSelection.first;
                                        final newList = _buildFlashKyuuiList(
                                          newSelection.first,
                                        );
                                        final newIndex =
                                            newSelection.first ==
                                                KyuuiDenomination
                                                    .zsAloudAndFlash
                                            ? _zsIndex
                                            : _kkIndex;
                                        _kyuui = newList[newIndex];
                                      });
                                    },
                              ),
                            ],
                          ),
                          SizedBox(height: 6),
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
  });
  final FlashLevel selectedLevel;
  final bool isPortrait;

  @override
  Widget build(BuildContext context) {
    final int probCount = selectedLevel.probCount;
    final double secondsPerProblem = selectedLevel.secondsPerProblem;
    final int digits = selectedLevel.digits;
    final int kuchi = selectedLevel.kuchi;
    final bool kuriagariNashi = selectedLevel.kuriagariNashi;
    final String denominationString =
        selectedLevel.levelInfo.denomination.denominationString;

    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const .all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: .circular(16),
      ),
      child: Column(
        mainAxisSize: .min,
        mainAxisAlignment: .center,
        crossAxisAlignment: .center,
        children: [
          FittedBox(
            child: Text(denominationString, style: textTheme.displaySmall),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const .symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: .circular(12),
            ),
            child: Flex(
              direction: isPortrait ? .vertical : .horizontal,
              mainAxisAlignment: .spaceEvenly,
              children: [
                statCell(context, '$digits', '桁'),
                divider(context, isPortrait),
                statCell(context, '$kuchi', '口'),
                divider(context, isPortrait),
                statCell(context, '$secondsPerProblem', '秒'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: .center,
            spacing: 6,
            children: [
              Text('$probCount問', style: textTheme.titleLarge),
              if (kuriagariNashi) ...[
                const SizedBox(height: 6),
                Text('くり上がりなし', style: textTheme.titleMedium),
              ],
            ],
          ),
        ],
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
      Text(value, style: textTheme.displayLarge),
      Text(unit, style: textTheme.displaySmall),
    ],
  );
}

Widget divider(BuildContext context, bool isPortrait) {
  return isPortrait
      ? Divider(color: Theme.of(context).colorScheme.outline, thickness: 1)
      : SizedBox(
          height: 48,
          child: VerticalDivider(
            color: Theme.of(context).colorScheme.outline,
            thickness: 1,
          ),
        );
}
