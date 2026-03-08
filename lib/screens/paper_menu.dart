import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soroban_app/screens/components/navigation_button.dart';
import '../models/level_definitions.dart';

class PaperMenuPage extends StatefulWidget {
  const PaperMenuPage({super.key});

  @override
  State<PaperMenuPage> createState() => _PaperMenuPageState();
}

class _PaperMenuPageState extends State<PaperMenuPage> {
  Kyuui _kyuui = .zsk9;
  bool _isExam = false;
  KyuuiDenomination _kyuuiDenomination = .zs;
  int _zsIndex = 0;
  int _nsIndex = 0;
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
          'kyuui',
          'isExam',
          'kyuuiDenomination',
          'zsIndex',
          'nsIndex',
        },
      ),
    );
    final kyuuiIndex = _prefs.getInt('kyuui');
    final isExam = _prefs.getBool('isExam');
    final denominationIndex = _prefs.getInt('kyuuiDenomination');
    final zsIndex = _prefs.getInt('zsIndex');
    final nsIndex = _prefs.getInt('nsIndex');
    if (zsIndex != null) {
      _zsIndex = zsIndex;
    }
    if (nsIndex != null) {
      _nsIndex = nsIndex;
    }
    if (kyuuiIndex != null) {
      _kyuui = Kyuui.values[kyuuiIndex];
    }
    if (isExam != null) {
      _isExam = isExam;
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
    denomination.kj3,
    denomination.k3,
    denomination.kj2,
    denomination.k2,
    denomination.kj1,
    denomination.k1,
    denomination.dan,
  ].whereType<Kyuui>().toList();

  bool _hasLevel(StartButtonType startButtonType) {
    return switch (startButtonType) {
      StartButtonType.mitori => _kyuui.mitoriSoroban != null,
      StartButtonType.wari => _kyuui.divSoroban != null,
      StartButtonType.kake => _kyuui.multSoroban != null,
      StartButtonType.mitorian => _kyuui.mitoriAnzan != null,
      StartButtonType.warian => _kyuui.divAnzan != null,
      StartButtonType.kakean => _kyuui.multAnzan != null,
    };
  }

  Widget _buildStartButton({
    required StartButtonType startButtonType,
    required double size,
  }) {
    late final String label;
    late final PaperProblemLevel? selectedLevel;
    late final String imagePath;

    switch (startButtonType) {
      case .mitori:
        label = 'みとり算';
        selectedLevel = _kyuui.mitoriSoroban;
        imagePath = 'assets/mitori.png';
      case .wari:
        label = 'わり算';
        selectedLevel = _kyuui.divSoroban;
        imagePath = 'assets/wari.png';
      case .kake:
        label = 'かけ算';
        selectedLevel = _kyuui.multSoroban;
        imagePath = 'assets/kake.png';
      case .mitorian:
        label = 'みとり暗算';
        selectedLevel = _kyuui.mitoriAnzan;
        imagePath = 'assets/mitorian.png';
      case .warian:
        label = 'わり暗算';
        selectedLevel = _kyuui.divAnzan;
        imagePath = 'assets/warian.png';
      case .kakean:
        label = 'かけ暗算';
        selectedLevel = _kyuui.multAnzan;
        imagePath = 'assets/kakean.png';
    }

    if (selectedLevel == null) {
      return SizedBox.shrink();
    }
    return SizedBox.square(
      dimension: size,
      child: Container(
        margin: EdgeInsets.all(12),
        child: NavigationButton(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          label: Text(label, style: Theme.of(context).textTheme.titleLarge),
          image: Align(
            alignment: Alignment.topCenter,
            child: FractionallySizedBox(
              heightFactor: 0.85,
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                colorBlendMode: BlendMode.srcIn,
              ),
            ),
          ),
          onPressed: () {
            context.go(
              '/paper-problem',
              extra: {
                'selectedLevel': selectedLevel,
                'isExam': _isExam,
                'time': selectedLevel!.levelInfo.timeLimit,
                'appBarTitle': '${_kyuui.kyuuString}の$label',
              },
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _prefs.setInt('kyuui', _kyuui.index);
    _prefs.setBool('isExam', _isExam);
    _prefs.setInt('kyuuiDenomination', _kyuuiDenomination.index);
    _prefs.setInt('zsIndex', _zsIndex);
    _prefs.setInt('nsIndex', _nsIndex);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('基本種目'),
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
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SegmentedButton<KyuuiDenomination>(
                        segments: const <ButtonSegment<KyuuiDenomination>>[
                          ButtonSegment(
                            value: KyuuiDenomination.zs,
                            label: Text('全国珠算教育連盟'),
                          ),
                          ButtonSegment(
                            value: KyuuiDenomination.ns,
                            label: Text('日本珠算連盟'),
                          ),
                        ],
                        selected: {_kyuuiDenomination},
                        onSelectionChanged:
                            (Set<KyuuiDenomination> newSelection) {
                              setState(() {
                                _kyuuiDenomination = newSelection.first;
                              });
                            },
                      ),
                      Expanded(
                        child: OrientationBuilder(
                          builder: (context, orientation) {
                            final isPortrait =
                                orientation == Orientation.portrait;
                            final rows = [
                              [
                                StartButtonType.mitori,
                                StartButtonType.mitorian,
                              ],
                              [StartButtonType.kake, StartButtonType.kakean],
                              [StartButtonType.wari, StartButtonType.warian],
                            ];
                            final visibleRows = rows
                                .where(
                                  (pair) => pair.any((type) => _hasLevel(type)),
                                )
                                .toList();
                            final indexedStack = IndexedStack(
                              index: _kyuuiDenomination == KyuuiDenomination.zs
                                  ? 0
                                  : 1,
                              children: [
                                KyuuiSelector(
                                  kyuuiList: _buildKyuuiList(
                                    KyuuiDenomination.zs,
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
                                    KyuuiDenomination.ns,
                                  ),
                                  currentIndex: _nsIndex,
                                  onChanged: (index, kyuui) {
                                    setState(() {
                                      _nsIndex = index;
                                      _kyuui = kyuui;
                                    });
                                  },
                                ),
                              ],
                            );
                            final buttonGrid = Column(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainer,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Flex(
                                      direction: isPortrait
                                          ? Axis.vertical
                                          : Axis.horizontal,
                                      children: visibleRows
                                          .map(
                                            (pair) => Expanded(
                                              child: LayoutBuilder(
                                                builder: (context, constraints) {
                                                  final size = isPortrait
                                                      ? constraints.maxWidth / 2
                                                      : constraints.maxHeight /
                                                            2;
                                                  return Flex(
                                                    direction: isPortrait
                                                        ? Axis.horizontal
                                                        : Axis.vertical,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: pair
                                                        .map(
                                                          (type) =>
                                                              _buildStartButton(
                                                                startButtonType:
                                                                    type,
                                                                size: size,
                                                              ),
                                                        )
                                                        .toList(),
                                                  );
                                                },
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                ),
                                Switch(
                                  value: _isExam,
                                  onChanged: (value) {
                                    setState(() {
                                      _isExam = value;
                                    });
                                  },
                                ),
                              ],
                            );
                            return Flex(
                              direction: isPortrait
                                  ? Axis.vertical
                                  : Axis.horizontal,
                              children: [
                                isPortrait
                                    ? SizedBox(height: 100, child: indexedStack)
                                    : Expanded(flex: 1, child: indexedStack),
                                Expanded(
                                  flex: isPortrait ? 1 : 5,
                                  child: buttonGrid,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
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

class KyuuiSelector extends StatelessWidget {
  const KyuuiSelector({
    super.key,
    required this.kyuuiList,
    required this.currentIndex,
    required this.onChanged,
  });

  final List<Kyuui> kyuuiList;
  final int currentIndex;
  final void Function(int index, Kyuui kyuui) onChanged;

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.orientationOf(context);
    return LayoutBuilder(
      builder: (context, constraints) => CarouselSlider.builder(
        itemCount: kyuuiList.length,
        options: CarouselOptions(
          height: orientation == .portrait ? 100 : constraints.biggest.height,
          viewportFraction: 0.4,
          enlargeCenterPage: true,
          enlargeFactor: 0.3,
          initialPage: currentIndex,
          scrollDirection: orientation == .portrait ? .horizontal : .vertical,
          onPageChanged: (index, reason) {
            onChanged(index, kyuuiList[index]);
          },
        ),
        itemBuilder: (BuildContext context, int index, int realIndex) {
          final isFocused = index == currentIndex;
          return Opacity(
            opacity: isFocused ? 1.0 : 0.5,
            child: Center(
              child: Text(
                kyuuiList[index].kyuuString,
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
          );
        },
      ),
    );
  }
}

enum StartButtonType { mitori, mitorian, wari, warian, kake, kakean }

class OpenLevelSelectButton extends StatelessWidget {
  const OpenLevelSelectButton({
    super.key,
    required this.label,
    required this.page,
  });

  final String label;
  final Widget page;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => SizedBox(
            height: MediaQuery.of(context).size.height * 0.9,
            child: page,
          ),
        );
      },
      child: Text(label),
    );
  }
}
