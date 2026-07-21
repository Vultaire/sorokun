import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soroban_app/models/level_definitions.dart';
import 'package:soroban_app/screens/components/navigation_button.dart';
import 'package:soroban_app/screens/paper_menu.dart';
import 'package:soroban_app/src/voicevox_paths.dart';
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
        allowList: <String>{'kyuui', 'kyuuiDenomination', 'zsIndex'},
      ),
    );
    final kyuuiIndex = _prefs.getInt('kyuui');
    final denominationIndex = _prefs.getInt('kyuuiDenomination');
    final zsIndex = _prefs.getInt('zsIndex');
    if (zsIndex != null) {
      _zsIndex = zsIndex;
    }
    if (kyuuiIndex != null) {
      _kyuui = Kyuui.values[kyuuiIndex];
    }
    if (denominationIndex != null) {
      _kyuuiDenomination = KyuuiDenomination.values[denominationIndex];
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
    _prefs.setInt('kyuui', _kyuui.index);
    _prefs.setInt('kyuuiDenomination', _kyuuiDenomination.index);
    _prefs.setInt('zsIndex', _zsIndex);

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
          title: const Text('読み上げ算検定'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/home'),
          ),
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
                    vertical: 12,
                  ),
                  child: OrientationBuilder(
                    builder: (context, orientation) {
                      final isPortrait = orientation == Orientation.portrait;
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
                                    ? SizedBox(height: 100, child: selector)
                                    : Expanded(flex: 1, child: selector),
                                Expanded(
                                  flex: isPortrait ? 1 : 5,
                                  child: AloudInfoDialog(
                                    selectedLevel: _kyuui.aloud!,
                                    isPortrait: isPortrait,
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
  });
  final AloudLevel selectedLevel;
  final bool isPortrait;

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
    final infoTextStyle = textTheme.titleLarge;

    return Container(
      padding: const .all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: .circular(12),
      ),
      child: Column(
        mainAxisSize: .min,
        mainAxisAlignment: .spaceEvenly,
        crossAxisAlignment: .center,
        children: [
          FittedBox(
            child: Text(denominationString, style: textTheme.displaySmall),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const .symmetric(vertical: 16, horizontal: 12),
            width: isPortrait ? 300 : 800,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: .circular(12),
            ),
            child: Column(
              children: [
                Flex(
                  direction: isPortrait ? .vertical : .horizontal,
                  mainAxisAlignment: .spaceEvenly,
                  children: [
                    statCell(context, digitsString, '桁'),
                    divider(context, isPortrait),
                    statCell(context, '$kuchi', '口'),
                  ],
                ),
                DefaultTextStyle(
                  style: textTheme.displaySmall!,
                  child: isPortrait
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('速度: $moraPerSecond拍/秒'),
                            Text('間隔: $msPerInterval秒'),
                            Text(minusString),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: .spaceEvenly,
                          children: [
                            Text('速度: $moraPerSecond拍/秒'),
                            Text('間隔: $msPerInterval秒'),
                            Text(minusString),
                          ],
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          isPortrait
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('全$probCount問 各10点', style: infoTextStyle),
                    Text('合格点：$passThreshold点以上', style: infoTextStyle),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('全$probCount問 各10点', style: infoTextStyle),
                    Text('　・　', style: infoTextStyle),
                    Text('合格点：$passThreshold点以上', style: infoTextStyle),
                  ],
                ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
            child: NavigationButton(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              label: 'スタート',
              onPressed: () {
                context.push(
                  '/aloud-problem',
                  extra: {
                    'isSingleProblem': false,
                    'selectedLevel': selectedLevel,
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
