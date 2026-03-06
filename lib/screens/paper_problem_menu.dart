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
  int _currentIndex = 0;
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
          'currentIndex',
        },
      ),
    );
    final kyuuiIndex = _prefs.getInt('kyuui');
    final isExam = _prefs.getBool('isExam');
    final denominationIndex = _prefs.getInt('kyuuiDenomination');
    final currentIndex = _prefs.getInt('currentIndex');
    if (kyuuiIndex != null) _kyuui = Kyuui.values[kyuuiIndex];
    if (isExam != null) _isExam = isExam;
    if (denominationIndex != null)
      _kyuuiDenomination = KyuuiDenomination.values[denominationIndex];
    if (currentIndex != null) _currentIndex = currentIndex;
  }

  @override
  void dispose() {
    _prefs.setInt('kyuui', _kyuui.index);
    _prefs.setBool('isExam', _isExam);
    _prefs.setInt('kyuuiDenomination', _kyuuiDenomination.index);
    _prefs.setInt('currentIndex', _currentIndex);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Kyuui> kyuuiList = [
      _kyuuiDenomination.k10,
      _kyuuiDenomination.k9,
      _kyuuiDenomination.k8,
      _kyuuiDenomination.k7,
      _kyuuiDenomination.k6,
      _kyuuiDenomination.k5,
      _kyuuiDenomination.k4,
      _kyuuiDenomination.kj3,
      _kyuuiDenomination.k3,
      _kyuuiDenomination.kj2,
      _kyuuiDenomination.k2,
      _kyuuiDenomination.kj1,
      _kyuuiDenomination.k1,
      _kyuuiDenomination.dan,
    ].whereType<Kyuui>().toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('基本種目'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: FutureBuilder(
        future: _prefsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return SizedBox.shrink();
          } else {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Switch(
                      value: _isExam,
                      onChanged: (value) {
                        setState(() {
                          _isExam = value;
                        });
                      },
                    ),
                    KyuuiSelector(
                      kyuuiList: kyuuiList,
                      currentIndex: _currentIndex,
                      onChanged: (index, kyuui) {
                        setState(() {
                          _currentIndex = index;
                          _kyuui = kyuui;
                        });
                      },
                    ),

                    Expanded(
                      child: OrientationBuilder(
                        builder: (context, orientation) {
                          return Flex(
                            direction: orientation == Orientation.portrait
                                ? Axis.vertical
                                : Axis.horizontal,
                            children: [
                              Expanded(
                                child: Flex(
                                  direction: orientation == Orientation.portrait
                                      ? Axis.horizontal
                                      : Axis.vertical,
                                  children: [
                                    _buildStartButton(startButtonType: .mitori),
                                    _buildStartButton(
                                      startButtonType: .mitorian,
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Flex(
                                  direction: orientation == Orientation.portrait
                                      ? Axis.horizontal
                                      : Axis.vertical,
                                  children: [
                                    _buildStartButton(startButtonType: .kake),
                                    _buildStartButton(startButtonType: .kakean),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Flex(
                                  direction: orientation == Orientation.portrait
                                      ? Axis.horizontal
                                      : Axis.vertical,
                                  children: [
                                    _buildStartButton(startButtonType: .wari),
                                    _buildStartButton(startButtonType: .warian),
                                  ],
                                ),
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
    );
  }

  Widget _buildStartButton({required StartButtonType startButtonType}) {
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

    return Expanded(
      child: Container(
        margin: EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.onSurface,
            width: 4,
          ),
          borderRadius: BorderRadius.all(.circular(12)),
        ),
        child: NavigationButton(
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
    return CarouselSlider.builder(
      itemCount: kyuuiList.length,
      options: CarouselOptions(
        height: 100,
        viewportFraction: 0.4,
        enlargeCenterPage: true,
        enlargeFactor: 0.4,
        initialPage: currentIndex,
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
