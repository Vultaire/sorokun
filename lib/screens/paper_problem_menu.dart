import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/level_definitions.dart';

class PaperConfPage extends StatefulWidget {
  const PaperConfPage({super.key});

  @override
  State<PaperConfPage> createState() => _PaperConfPageState();
}

class _PaperConfPageState extends State<PaperConfPage> {
  DivMultLevel multiplicationLevel = DivMultLevel.mk6;
  DivMultLevel divisionLevel = DivMultLevel.dk6;
  MitoriLevel mitoriLevel = MitoriLevel.k6;
  String multiplicationLevelDisplayString = '';
  String divisionLevelDisplayString = '';
  String mitoriLevelDisplayString = '';
  bool isExam = false;
  Duration? time = Duration(seconds: 3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              _buildProblemTypeSection(
                label: '${mitoriLevel.displayString}をはじめる',
                selectLabel: 'みとり算の級位を選ぶ',
                currentLevel: mitoriLevel,
                bottomSheet: MitoriBottomSheet(
                  mitoriLevel: mitoriLevel,
                  onLevelChanged: (newLevel) {
                    setState(() {
                      mitoriLevel = newLevel;
                      mitoriLevelDisplayString = newLevel.displayString;
                    });
                  },
                ),
              ),
              _buildProblemTypeSection(
                label: '${multiplicationLevel.displayString}をはじめる',
                selectLabel: 'かけ算の級位を選ぶ',
                currentLevel: multiplicationLevel,
                bottomSheet: MultiplicationBottomSheet(
                  multiplicationLevel: multiplicationLevel,
                  onLevelChanged: (newLevel) {
                    setState(() {
                      multiplicationLevel = newLevel;
                      multiplicationLevelDisplayString = newLevel.displayString;
                    });
                  },
                ),
              ),
              _buildProblemTypeSection(
                label: '${divisionLevel.displayString}をはじめる',
                selectLabel: 'わり算の級位を選ぶ',
                currentLevel: divisionLevel,
                bottomSheet: DivisionBottomSheet(
                  divisionLevel: divisionLevel,
                  onLevelChanged: (newLevel) {
                    setState(() {
                      divisionLevel = newLevel;
                      divisionLevelDisplayString = newLevel.displayString;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProblemTypeSection({
    required String label,
    required String selectLabel,
    required ProblemLevel currentLevel,
    required Widget bottomSheet,
  }) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            context.push(
              '/paper-problem',
              extra: {
                'selectedLevel': currentLevel,
                'isExam': isExam,
                'time': time,
                'appBarTitle': currentLevel.displayString,
              },
            );
          },
          child: Text(label),
        ),
        OpenLevelSelectButton(label: selectLabel, page: bottomSheet),
      ],
    );
  }
}

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

class MitoriBottomSheet extends StatelessWidget {
  const MitoriBottomSheet({
    super.key,
    required this.mitoriLevel,
    required this.onLevelChanged,
  });

  final MitoriLevel mitoriLevel;
  final Function(MitoriLevel) onLevelChanged;

  static const List<MitoriLevel> levels = [
    MitoriLevel.k10a,
    MitoriLevel.k10b,
    MitoriLevel.k9,
    MitoriLevel.k8,
    MitoriLevel.k7,
    MitoriLevel.k6,
    MitoriLevel.k5,
    MitoriLevel.k4,
    MitoriLevel.k3,
    MitoriLevel.k2,
    MitoriLevel.k1,
    MitoriLevel.dan,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: levels.map((level) {
              return ElevatedButton(
                onPressed: () {
                  onLevelChanged(level);
                  Navigator.pop(context);
                },
                child: Text(level.displayString),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class MultiplicationBottomSheet extends StatelessWidget {
  const MultiplicationBottomSheet({
    super.key,
    required this.multiplicationLevel,
    required this.onLevelChanged,
  });

  final DivMultLevel multiplicationLevel;
  final Function(DivMultLevel) onLevelChanged;

  static const List<DivMultLevel> levels = [
    DivMultLevel.mk9,
    DivMultLevel.mk8,
    DivMultLevel.mk7,
    DivMultLevel.mk6,
    DivMultLevel.mk5,
    DivMultLevel.mk4,
    DivMultLevel.mk3,
    DivMultLevel.mk2,
    DivMultLevel.mk1,
    DivMultLevel.mdan,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: levels.map((level) {
              return ElevatedButton(
                onPressed: () {
                  onLevelChanged(level);
                  Navigator.pop(context);
                },
                child: Text(level.displayString),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class DivisionBottomSheet extends StatelessWidget {
  const DivisionBottomSheet({
    super.key,
    required this.divisionLevel,
    required this.onLevelChanged,
  });

  final DivMultLevel divisionLevel;
  final Function(DivMultLevel) onLevelChanged;

  static const List<DivMultLevel> levels = [
    DivMultLevel.dk8,
    DivMultLevel.dk7,
    DivMultLevel.dk6,
    DivMultLevel.dk5,
    DivMultLevel.dk4,
    DivMultLevel.dk3,
    DivMultLevel.dk2,
    DivMultLevel.dk1,
    DivMultLevel.ddan,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: levels.map((level) {
              return ElevatedButton(
                onPressed: () {
                  onLevelChanged(level);
                  Navigator.pop(context);
                },
                child: Text(level.displayString),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
