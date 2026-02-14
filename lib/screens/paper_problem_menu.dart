import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/level_definitions.dart';

class PaperMenuPage extends StatefulWidget {
  const PaperMenuPage({super.key});

  @override
  State<PaperMenuPage> createState() => _PaperMenuPageState();
}

class _PaperMenuPageState extends State<PaperMenuPage> {
  DivMultLevel multiplicationLevel = DivMultLevel.zsmk6;
  DivMultLevel divisionLevel = DivMultLevel.zsdk6;
  MitoriLevel mitoriLevel = MitoriLevel.zsk6;
  String multiplicationLevelDisplayString = '';
  String divisionLevelDisplayString = '';
  String mitoriLevelDisplayString = '';
  bool isExam = false;
  Duration? time = MitoriLevel.zsk6.timeLimit;

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
                      time = newLevel.timeLimit;
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
                      time = newLevel.timeLimit;
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
                      time = newLevel.timeLimit;
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
    required PaperProblemLevel currentLevel,
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

  static const List<MitoriLevel> zslevels = [
    MitoriLevel.zsk10a,
    MitoriLevel.zsk10b,
    MitoriLevel.zsk9,
    MitoriLevel.zsk8,
    MitoriLevel.zsk7,
    MitoriLevel.zsk6,
    MitoriLevel.zsk5,
    MitoriLevel.zsk4,
    MitoriLevel.zsk3,
    MitoriLevel.zsk2,
    MitoriLevel.zsk1,
    MitoriLevel.zsdan,
  ];

  static const List<MitoriLevel> nslevels = [
    MitoriLevel.nsk9,
    MitoriLevel.nsk8,
    MitoriLevel.nsk7,
    MitoriLevel.nsk6,
    MitoriLevel.nsk5,
    MitoriLevel.nsk4,
    MitoriLevel.nsk3,
    MitoriLevel.nskj2,
    MitoriLevel.nsk2,
    MitoriLevel.nskj1,
    MitoriLevel.nsk1,
    MitoriLevel.nsdan,
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
            children: nslevels.map((level) {
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

  static const List<DivMultLevel> zslevels = [
    DivMultLevel.zsmk9,
    DivMultLevel.zsmk8,
    DivMultLevel.zsmk7,
    DivMultLevel.zsmk6,
    DivMultLevel.zsmk5,
    DivMultLevel.zsmk4,
    DivMultLevel.zsmk3,
    DivMultLevel.zsmk2,
    DivMultLevel.zsmk1,
    DivMultLevel.zsmdan,
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
            children: zslevels.map((level) {
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

  static const List<DivMultLevel> zslevels = [
    DivMultLevel.zsdk8,
    DivMultLevel.zsdk7,
    DivMultLevel.zsdk6,
    DivMultLevel.zsdk5,
    DivMultLevel.zsdk4,
    DivMultLevel.zsdk3,
    DivMultLevel.zsdk2,
    DivMultLevel.zsdk1,
    DivMultLevel.zsddan,
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
            children: zslevels.map((level) {
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
