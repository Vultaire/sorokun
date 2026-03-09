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
  Kyuui _kyuui = .zsk10;
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: OrientationBuilder(
                    builder: (context, orientation) {
                      final isPortrait = orientation == Orientation.portrait;
                      final rows = [
                        [StartButtonType.mitori, StartButtonType.mitorian],
                        [StartButtonType.kake, StartButtonType.kakean],
                        [StartButtonType.wari, StartButtonType.warian],
                      ];
                      final visibleRows = rows
                          .where((pair) => pair.any((type) => _hasLevel(type)))
                          .toList();

                      final buttonGrid = Container(
                        padding: .all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainer,
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
                                      final startButtonSizeConstraint =
                                          isPortrait
                                          ? constraints.maxWidth / 2
                                          : constraints.maxHeight / 2;
                                      return Flex(
                                        direction: isPortrait
                                            ? Axis.horizontal
                                            : Axis.vertical,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: pair
                                            .map(
                                              (type) => StartButton(
                                                startButtonType: type,
                                                size: startButtonSizeConstraint,
                                                isPortrait: isPortrait,
                                                kyuui: _kyuui,
                                                isExam: _isExam,
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
                      );
                      final textStyle = Theme.of(context).textTheme;
                      final selectorStack = KyuuiSelectorStack(
                        primaryDenomination: KyuuiDenomination.zs,
                        secondaryDenomination: KyuuiDenomination.ns,
                        initialPrimaryIndex: _zsIndex,
                        initialSecondaryIndex: _nsIndex,
                        activeDenomination: _kyuuiDenomination,
                        onChanged: (denomination, index, kyuui) {
                          setState(() {
                            _kyuui = kyuui;
                            if (denomination == KyuuiDenomination.zs) {
                              _zsIndex = index;
                            } else {
                              _nsIndex = index;
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
                                  child: buttonGrid,
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
                                showSelectedIcon: false,
                                emptySelectionAllowed: false,
                                segments: <ButtonSegment<KyuuiDenomination>>[
                                  ButtonSegment(
                                    value: KyuuiDenomination.zs,
                                    label: Text(
                                      '全国珠算教育連盟',
                                      style: textStyle.titleMedium,
                                    ),
                                  ),
                                  ButtonSegment(
                                    value: KyuuiDenomination.ns,
                                    label: Text(
                                      '日本珠算連盟',
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
                                                KyuuiDenomination.zs
                                            ? _zsIndex
                                            : _nsIndex;
                                        _kyuui = newList[newIndex];
                                      });
                                    },
                              ),
                              Row(
                                mainAxisAlignment: .center,
                                crossAxisAlignment: .center,
                                children: [
                                  Text('検定モード', style: textStyle.titleLarge),
                                  Switch(
                                    value: _isExam,
                                    onChanged: (value) {
                                      setState(() {
                                        _isExam = value;
                                      });
                                    },
                                  ),
                                ],
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

class StartButton extends StatelessWidget {
  const StartButton({
    super.key,
    required this.startButtonType,
    required this.size,
    required this.isPortrait,
    required this.kyuui,
    required this.isExam,
  });

  final StartButtonType startButtonType;
  final double size;
  final bool isPortrait;
  final Kyuui kyuui;
  final bool isExam;

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final PaperProblemLevel? selectedLevel;
    late final String imagePath;
    Set<int>? letterCounts;
    Set<int>? houshou;
    Set<int>? jippou;

    switch (startButtonType) {
      case .mitori:
        label = 'みとり算';
        selectedLevel = kyuui.mitoriSoroban;
        imagePath = 'assets/mitori.png';
        letterCounts = selectedLevel?.letterCounts;
      case .wari:
        label = 'わり算';
        selectedLevel = kyuui.divSoroban;
        imagePath = 'assets/wari.png';
        houshou = selectedLevel?.houshouJippou;
      case .kake:
        label = 'かけ算';
        selectedLevel = kyuui.multSoroban;
        imagePath = 'assets/kake.png';
        jippou = selectedLevel?.houshouJippou;
      case .mitorian:
        label = 'みとり暗算';
        selectedLevel = kyuui.mitoriAnzan;
        imagePath = 'assets/mitorian.png';
        letterCounts = selectedLevel?.letterCounts;
      case .warian:
        label = 'わり暗算';
        selectedLevel = kyuui.divAnzan;
        imagePath = 'assets/warian.png';
        houshou = selectedLevel?.houshouJippou;
      case .kakean:
        label = 'かけ暗算';
        selectedLevel = kyuui.multAnzan;
        imagePath = 'assets/kakean.png';
        jippou = selectedLevel?.houshouJippou;
    }

    if (selectedLevel == null) return const SizedBox.shrink();

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: isPortrait ? size : size * 2,
        maxHeight: isPortrait ? size : size,
      ),
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.all(6),
            child: NavigationButton(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              label: Text(
                label,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              imageAbove: isPortrait,
              image: Align(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),
              onPressed: () {
                context.go(
                  '/paper-problem',
                  extra: {
                    'selectedLevel': selectedLevel,
                    'isExam': isExam,
                    'time': selectedLevel!.levelInfo.timeLimit,
                    'appBarTitle': '${kyuui.kyuuString}の$label',
                  },
                );
              },
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              icon: const Icon(Icons.info_outline, size: 28),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('${kyuui.kyuuString}の$label'),
                    content: InfoAlert(
                      selectedLevel: selectedLevel!,
                      letterCounts: letterCounts,
                      houshou: houshou,
                      jippou: jippou,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                    actionsAlignment: .center,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class InfoAlert extends StatelessWidget {
  const InfoAlert({
    super.key,
    required this.selectedLevel,
    required this.letterCounts,
    required this.houshou,
    required this.jippou,
  });

  final PaperProblemLevel selectedLevel;
  final Set<int>? letterCounts;
  final Set<int>? houshou;
  final Set<int>? jippou;

  String _rangeOrSingle(Set<int> values, String prefix, String suffix) {
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    return values.length == 1
        ? '$prefix$min$suffix'
        : '$prefix$min〜$max$suffix';
  }

  @override
  Widget build(BuildContext context) {
    final String denominationString =
        selectedLevel.levelInfo.denomination.denominationString;
    final Duration timeLimit = selectedLevel.levelInfo.timeLimit;
    final String timeLimitString = '${timeLimit.inMinutes}分';
    final int pointsPerProblem = selectedLevel.levelInfo.pointsPerProblem;
    final int problemCount = selectedLevel.problemCount;
    final int passThreshold =
        (selectedLevel.levelInfo.passThreshold * problemCount).ceil() *
        pointsPerProblem;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(denominationString),
        Text('制限時間：$timeLimitString'),
        Text('問題数：$problemCount題'),
        Text('一題$pointsPerProblem点 (${pointsPerProblem * problemCount}点満点)'),
        Text('合格点：$passThreshold点以上'),
        if (letterCounts != null)
          Text('一題あたり${_rangeOrSingle(letterCounts!, '', '字')}'),
        if (jippou != null) Text('実法あわせて${_rangeOrSingle(jippou!, '', '桁')}'),
        if (houshou != null) Text('法商あわせて${_rangeOrSingle(houshou!, '', '桁')}'),
      ],
    );
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

class KyuuiSelectorStack extends StatefulWidget {
  const KyuuiSelectorStack({
    super.key,
    required this.primaryDenomination,
    required this.secondaryDenomination,
    required this.activeDenomination,
    required this.onChanged,
    this.initialPrimaryIndex = 0,
    this.initialSecondaryIndex = 0,
  });

  final KyuuiDenomination primaryDenomination;
  final KyuuiDenomination secondaryDenomination;
  final KyuuiDenomination activeDenomination;
  final void Function(KyuuiDenomination denomination, int index, Kyuui kyuui)
  onChanged;
  final int initialPrimaryIndex;
  final int initialSecondaryIndex;

  @override
  State<KyuuiSelectorStack> createState() => _KyuuiSelectorStackState();
}

class _KyuuiSelectorStackState extends State<KyuuiSelectorStack> {
  late int _primaryIndex;
  late int _secondaryIndex;

  @override
  void initState() {
    super.initState();
    _primaryIndex = widget.initialPrimaryIndex;
    _secondaryIndex = widget.initialSecondaryIndex;
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: widget.activeDenomination == widget.primaryDenomination ? 0 : 1,
      children: [
        KyuuiSelector(
          kyuuiList: _buildKyuuiList(widget.primaryDenomination),
          currentIndex: _primaryIndex,
          onChanged: (index, kyuui) {
            setState(() => _primaryIndex = index);
            widget.onChanged(widget.primaryDenomination, index, kyuui);
          },
        ),
        KyuuiSelector(
          kyuuiList: _buildKyuuiList(widget.secondaryDenomination),
          currentIndex: _secondaryIndex,
          onChanged: (index, kyuui) {
            setState(() => _secondaryIndex = index);
            widget.onChanged(widget.secondaryDenomination, index, kyuui);
          },
        ),
      ],
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
