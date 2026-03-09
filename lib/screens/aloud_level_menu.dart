import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soroban_app/models/level_definitions.dart';
import 'package:soroban_app/screens/components/navigation_button.dart';
import 'package:soroban_app/screens/paper_menu.dart';
import 'package:soroban_app/src/voicevox_paths.dart';

class AloudMenuPage extends StatefulWidget {
  const AloudMenuPage({super.key, required this.voicevoxPaths});
  final VoicevoxPaths voicevoxPaths;

  @override
  State<AloudMenuPage> createState() => _AloudMenuPageState();
}

class _AloudMenuPageState extends State<AloudMenuPage> {
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
                      final isPortrait = orientation == Orientation.portrait;
                      final indexedStack = IndexedStack(
                        index:
                            _kyuuiDenomination ==
                                KyuuiDenomination.zsAloudAndFlash
                            ? 0
                            : 1,
                        children: [
                          KyuuiSelector(
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
                          ),
                          KyuuiSelector(
                            kyuuiList: _buildKyuuiList(
                              KyuuiDenomination.kkFlash,
                            ),
                            currentIndex: _kkIndex,
                            onChanged: (index, kyuui) {
                              setState(() {
                                _kkIndex = index;
                                _kyuui = kyuui;
                              });
                            },
                          ),
                        ],
                      );
                      final textStyle = Theme.of(context).textTheme;
                      final Widget startButton = NavigationButton(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        onPressed: () {
                          context.push(
                            '/aloud-problem',
                            extra: {
                              'voicevoxPaths': widget.voicevoxPaths,
                              'isSingleProblem': false,
                              'selectedLevel': _kyuui.aloud,
                            },
                          );
                        },
                        label: Text(
                          'スタート',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
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
                                    ? SizedBox(height: 100, child: indexedStack)
                                    : Expanded(flex: 1, child: indexedStack),
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
