import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soroban_app/models/level_definitions.dart';
import 'package:soroban_app/screens/paper_menu.dart';

class FlashFreeMenuPage extends StatefulWidget {
  const FlashFreeMenuPage({super.key});

  @override
  State<FlashFreeMenuPage> createState() => _FlashFreeMenuPageState();
}

class _FlashFreeMenuPageState extends State<FlashFreeMenuPage> {
  Kyuui _kyuui = .zsk9;
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
        allowList: <String>{'kyuui', 'kyuuiDenomination', 'zsIndex', 'kkIndex'},
      ),
    );
    final kyuuiIndex = _prefs.getInt('kyuui');
    final denominationIndex = _prefs.getInt('kyuuiDenomination');
    final zsIndex = _prefs.getInt('zsIndex');
    final kkIndex = _prefs.getInt('kkIndex');
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

  List<Kyuui> _buildKyuuiList(KyuuiDenomination denomination) => [
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
    _prefs.setInt('kyuui', _kyuui.index);
    _prefs.setInt('kyuuiDenomination', _kyuuiDenomination.index);
    _prefs.setInt('zsIndex', _zsIndex);
    _prefs.setInt('kkIndex', _kkIndex);

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
                                  child: Placeholder(),
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
                                onSelectionChanged:
                                    (Set<KyuuiDenomination> newSelection) {
                                      setState(() {
                                        _kyuuiDenomination = newSelection.first;
                                        final newList = _buildKyuuiList(
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
