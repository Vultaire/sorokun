import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soroban_app/screens/components/navigation_button.dart';
import '../models/level_definitions.dart';

class PaperMenuPage extends StatefulWidget {
  const PaperMenuPage({super.key});

  @override
  State<PaperMenuPage> createState() => _PaperMenuPageState();
}

class _PaperMenuPageState extends State<PaperMenuPage> {
  Kyuui kyuui = .nsk1;
  bool isExam = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Switch(
                value: isExam,
                onChanged: (value) {
                  setState(() {
                    isExam = value;
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
                        Flex(
                          direction: orientation == Orientation.portrait
                              ? Axis.horizontal
                              : Axis.vertical,
                          children: [
                            _buildStartButton(startButtonType: .mitori),
                            _buildStartButton(startButtonType: .mitorian),
                          ],
                        ),
                        Flex(
                          direction: orientation == Orientation.portrait
                              ? Axis.horizontal
                              : Axis.vertical,
                          children: [
                            _buildStartButton(startButtonType: .kake),
                            _buildStartButton(startButtonType: .kakean),
                          ],
                        ),
                        Flex(
                          direction: orientation == Orientation.portrait
                              ? Axis.horizontal
                              : Axis.vertical,
                          children: [
                            _buildStartButton(startButtonType: .wari),
                            _buildStartButton(startButtonType: .warian),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartButton({required StartButtonType startButtonType}) {
    late final String label;
    late final PaperProblemLevel? selectedLevel;

    switch (startButtonType) {
      case .mitori:
        label = 'みとり算';
        selectedLevel = kyuui.mitoriSoroban;
      case .wari:
        label = 'わり算';
        selectedLevel = kyuui.divSoroban;
      case .kake:
        label = 'かけ算';
        selectedLevel = kyuui.multSoroban;
      case .mitorian:
        label = 'みとり暗算';
        selectedLevel = kyuui.mitoriAnzan;
      case .warian:
        label = 'わり暗算';
        selectedLevel = kyuui.divAnzan;
      case .kakean:
        label = 'かけ暗算';
        selectedLevel = kyuui.multAnzan;
    }

    if (selectedLevel == null) {
      return SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.onSurface),
      ),
      child: NavigationButton(
        label: Text(label),
        onPressed: () {
          context.push(
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
