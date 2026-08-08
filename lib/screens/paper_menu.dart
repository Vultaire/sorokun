import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soroban_app/screens/components/appbar.dart';
import 'package:soroban_app/screens/components/labeled_sliding_segment.dart';
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
          'paper_kyuui',
          'paper_isExam',
          'paper_kyuuiDenomination',
          'paper_zsIndex',
          'paper_nsIndex',
        },
      ),
    );
    final kyuuiIndex = _prefs.getInt('paper_kyuui');
    final isExam = _prefs.getBool('paper_isExam');
    final denominationIndex = _prefs.getInt('paper_kyuuiDenomination');
    final zsIndex = _prefs.getInt('paper_zsIndex');
    final nsIndex = _prefs.getInt('paper_nsIndex');
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
    _prefs.setInt('paper_kyuui', _kyuui.index);
    _prefs.setBool('paper_isExam', _isExam);
    _prefs.setInt('paper_kyuuiDenomination', _kyuuiDenomination.index);
    _prefs.setInt('paper_zsIndex', _zsIndex);
    _prefs.setInt('paper_nsIndex', _nsIndex);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: '総合種目', context: context),
      body: SafeArea(
        child: FutureBuilder(
          future: _prefsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: OrientationBuilder(
                    builder: (context, orientation) {
                      final isPortrait = orientation == Orientation.portrait;
                      final rows = [
                        [StartButtonType.mitori, StartButtonType.mitorian],
                        [StartButtonType.kake, StartButtonType.kakean],
                        [StartButtonType.wari, StartButtonType.warian],
                      ];

                      final buttonGrid = LayoutBuilder(
                        builder: (context, gridConstraints) {
                          final shortestSide = MediaQuery.sizeOf(
                            context,
                          ).shortestSide;
                          final isLargeScreen = shortestSide >= 600;

                          final padding = isLargeScreen ? 20.0 : 8.0;
                          final rowSpacing = isLargeScreen ? 28.0 : 8.0;
                          final itemSpacing = isLargeScreen ? 28.0 : 8.0;

                          final maxHeight = gridConstraints.maxHeight.isFinite
                              ? gridConstraints.maxHeight.clamp(0, 600)
                              : 600.0;
                          final availableWidth =
                              gridConstraints.maxWidth - padding * 2;
                          final availableHeight = maxHeight - padding * 2;
                          final itemsPerRow = rows.isNotEmpty
                              ? rows.first.length
                              : 1;
                          final buttonSize = isPortrait
                              ? (availableWidth -
                                        itemSpacing * (itemsPerRow - 1)) /
                                    itemsPerRow
                              : (availableHeight -
                                        itemSpacing * (itemsPerRow - 1)) /
                                    itemsPerRow;
                          return ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 600),
                            child: Container(
                              padding: EdgeInsets.all(padding),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Flex(
                                direction: isPortrait
                                    ? Axis.vertical
                                    : Axis.horizontal,
                                spacing: rowSpacing,
                                children: rows.map((pair) {
                                  return Expanded(
                                    child: Flex(
                                      direction: isPortrait
                                          ? Axis.horizontal
                                          : Axis.vertical,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      spacing: itemSpacing,
                                      children: pair.map((type) {
                                        return _GridButton(
                                          type: type,
                                          size: buttonSize,
                                          isPortrait: isPortrait,
                                          kyuui: _kyuui,
                                          isExam: _isExam,
                                          hasLevel: _hasLevel(type),
                                        );
                                      }).toList(),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        },
                      );
                      final selectorStack = KyuuiSelectorStack(
                        primaryDenomination: KyuuiDenomination.zs,
                        secondaryDenomination: KyuuiDenomination.ns,
                        initialPrimaryIndex: _zsIndex,
                        initialSecondaryIndex: _nsIndex,
                        kyuuiListBuilder: _buildPaperKyuuiList,
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
                      final denominationSelector =
                          LabeledSlidingSegmentedControl<KyuuiDenomination>(
                            groupValue: _kyuuiDenomination,
                            options: const [
                              (KyuuiDenomination.zs, '全珠連'),
                              (KyuuiDenomination.ns, '日珠連'),
                            ],
                            onValueChanged: (value) {
                              setState(() {
                                _kyuuiDenomination = value;
                                final newList = _buildPaperKyuuiList(value);
                                final newIndex = value == KyuuiDenomination.zs
                                    ? _zsIndex
                                    : _nsIndex;
                                _kyuui = newList[newIndex];
                              });
                            },
                          );

                      final modeSelector = LabeledSlidingSegmentedControl<bool>(
                        groupValue: _isExam,
                        options: const [(false, '練習'), (true, '検定')],
                        onValueChanged: (value) {
                          setState(() {
                            _isExam = value;
                          });
                        },
                      );

                      return isPortrait
                          ? Column(
                              crossAxisAlignment: .stretch,
                              children: [
                                denominationSelector,
                                SizedBox(height: 80, child: selectorStack),
                                modeSelector,
                                SizedBox(height: 6),
                                Expanded(child: buttonGrid),
                                const SizedBox(height: 12),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: .center,
                              children: [
                                Expanded(flex: 1, child: selectorStack),
                                Expanded(
                                  flex: 6,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: denominationSelector,
                                          ),
                                          SizedBox(width: 24),
                                          Expanded(
                                            flex: 2,
                                            child: modeSelector,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Expanded(
                                        child: Center(child: buttonGrid),
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

class _GridButton extends StatelessWidget {
  const _GridButton({
    required this.type,
    required this.size,
    required this.isPortrait,
    required this.kyuui,
    required this.isExam,
    required this.hasLevel,
  });

  final StartButtonType type;
  final double size;
  final bool isPortrait;
  final Kyuui kyuui;
  final bool isExam;
  final bool hasLevel;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: hasLevel ? 1.0 : 0.35,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: IgnorePointer(
        ignoring: !hasLevel,
        child: PaperStartButton(
          startButtonType: type,
          size: size,
          isPortrait: isPortrait,
          kyuui: kyuui,
          isExam: isExam,
        ),
      ),
    );
  }
}

class PaperStartButton extends StatelessWidget {
  const PaperStartButton({
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

    final bool hasLevel = selectedLevel != null;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: isPortrait ? size : size * 2,
        maxHeight: size,
      ),
      child: NavigationButton(
        color: Theme.of(context).colorScheme.primaryContainer,
        margin: EdgeInsets.all(4),
        onPressed: hasLevel
            ? () {
                context.go(
                  '/paper-problem',
                  extra: {
                    'selectedLevel': selectedLevel,
                    'isExam': isExam,
                    'examDisplayString': '${kyuui.kyuuString}の$label',
                  },
                );
              }
            : () {},
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: isPortrait ? 3 : 5,
                    child: Align(
                      child: Image.asset(
                        imagePath,
                        fit: .contain,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        colorBlendMode: BlendMode.srcIn,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: isPortrait ? 1 : 2,
                    child: FittedBox(
                      fit: .scaleDown,
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.displayMedium!
                            .copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IgnorePointer(
                ignoring: !hasLevel,
                child: AnimatedOpacity(
                  opacity: hasLevel ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: AnimatedScale(
                    scale: hasLevel ? 1.0 : 0.6,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutBack,
                    child: IconButton(
                      icon: Icon(Symbols.info_rounded, size: 28, weight: 1200),
                      padding: .zero,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      onPressed: hasLevel
                          ? () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('${kyuui.kyuuString}の$label'),
                                  content: PaperInfoDialog(
                                    selectedLevel: selectedLevel!,
                                    letterCounts: letterCounts,
                                    houshou: houshou,
                                    jippou: jippou,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                  actionsAlignment: .center,
                                ),
                              );
                            }
                          : null,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaperInfoDialog extends StatelessWidget {
  const PaperInfoDialog({
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
        (selectedLevel.levelInfo.passThreshold * problemCount).round() *
        pointsPerProblem;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(denominationString),
        Text('制限時間：$timeLimitString'),
        Text('問題数：$problemCount題'),
        Text('各$pointsPerProblem点 (${pointsPerProblem * problemCount}点満点)'),
        Text('合格点：$passThreshold点以上'),
        if (letterCounts != null)
          Text('一題あたり${_rangeOrSingle(letterCounts!, '', '字')}'),
        if (jippou != null) Text('実法あわせて${_rangeOrSingle(jippou!, '', '桁')}'),
        if (houshou != null) Text('法商あわせて${_rangeOrSingle(houshou!, '', '桁')}'),
      ],
    );
  }
}

List<Kyuui> _buildPaperKyuuiList(KyuuiDenomination denomination) => [
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
    required this.kyuuiListBuilder,
  });

  final KyuuiDenomination primaryDenomination;
  final KyuuiDenomination secondaryDenomination;
  final KyuuiDenomination activeDenomination;
  final void Function(KyuuiDenomination denomination, int index, Kyuui kyuui)
  onChanged;
  final int initialPrimaryIndex;
  final int initialSecondaryIndex;
  final List<Kyuui> Function(KyuuiDenomination) kyuuiListBuilder;

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
          kyuuiList: widget.kyuuiListBuilder(widget.primaryDenomination),
          currentIndex: _primaryIndex,
          onChanged: (index, kyuui) {
            setState(() => _primaryIndex = index);
            widget.onChanged(widget.primaryDenomination, index, kyuui);
          },
        ),
        KyuuiSelector(
          kyuuiList: widget.kyuuiListBuilder(widget.secondaryDenomination),
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

class KyuuiSelector extends StatefulWidget {
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
  State<KyuuiSelector> createState() => _KyuuiSelectorState();
}

class _KyuuiSelectorState extends State<KyuuiSelector> {
  final CarouselSliderController _controller = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.orientationOf(context) == .portrait;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            CarouselSlider.builder(
              carouselController: _controller,
              itemCount: widget.kyuuiList.length,
              options: CarouselOptions(
                height: isPortrait ? 80 : constraints.biggest.height,
                viewportFraction: 0.3,
                enlargeCenterPage: true,
                enlargeFactor: 0.3,
                initialPage: widget.currentIndex,
                scrollDirection: isPortrait ? .horizontal : .vertical,
                onPageChanged: (index, reason) {
                  widget.onChanged(index, widget.kyuuiList[index]);
                },
              ),
              itemBuilder: (BuildContext context, int index, int realIndex) {
                final isFocused = index == widget.currentIndex;
                return Opacity(
                  opacity: isFocused ? 1.0 : 0.5,
                  child: Center(
                    child: Text(
                      widget.kyuuiList[index].kyuuString,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                  ),
                );
              },
            ),
            Positioned.fill(
              child: Flex(
                direction: isPortrait ? Axis.horizontal : Axis.vertical,
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => _controller.previousPage(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutExpo,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => _controller.nextPage(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutExpo,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

enum StartButtonType { mitori, mitorian, wari, warian, kake, kakean }
