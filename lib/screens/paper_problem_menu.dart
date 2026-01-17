import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/divmult_difficulty.dart';
import '../models/mitori_difficulty.dart';

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
  Duration? time = Duration(minutes: 1);

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
                label: '$mitoriLevelDisplayStringのみとり算をはじめる',
                selectLabel: 'みとり算の級位を選ぶ',
                currentLevel: mitoriLevel,
                bottomSheet: MitoriBottomSheet(
                  mitoriLevel: mitoriLevel,
                  onLevelChanged: (newLevel, displayString) {
                    setState(() {
                      mitoriLevel = newLevel;
                      mitoriLevelDisplayString = displayString;
                    });
                  },
                ),
              ),
              _buildProblemTypeSection(
                label: '$multiplicationLevelDisplayStringのかけ算をはじめる',
                selectLabel: 'かけ算の級位を選ぶ',
                currentLevel: multiplicationLevel,
                bottomSheet: MultiplicationBottomSheet(
                  multiplicationLevel: multiplicationLevel,
                  onLevelChanged: (newLevel, displayString) {
                    setState(() {
                      multiplicationLevel = newLevel;
                      multiplicationLevelDisplayString = displayString;
                    });
                  },
                ),
              ),
              _buildProblemTypeSection(
                label: '$divisionLevelDisplayStringのわり算をはじめる',
                selectLabel: 'わり算の級位を選ぶ',
                currentLevel: divisionLevel,
                bottomSheet: DivisionBottomSheet(
                  divisionLevel: divisionLevel,
                  onLevelChanged: (newLevel, displayString) {
                    setState(() {
                      divisionLevel = newLevel;
                      divisionLevelDisplayString = displayString;
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
    required dynamic currentLevel,
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
          builder: (context) => Container(
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
  final Function(MitoriLevel, String) onLevelChanged;

  static const List<Map<String, dynamic>> levels = [
    {'level': MitoriLevel.k10a, 'label': '10級(A)'},
    {'level': MitoriLevel.k10b, 'label': '10級(B)'},
    {'level': MitoriLevel.k9, 'label': '9級'},
    {'level': MitoriLevel.k8, 'label': '8級'},
    {'level': MitoriLevel.k7, 'label': '7級'},
    {'level': MitoriLevel.k6, 'label': '6級'},
    {'level': MitoriLevel.k5, 'label': '5級'},
    {'level': MitoriLevel.k4, 'label': '4級'},
    {'level': MitoriLevel.k3, 'label': '3級'},
    {'level': MitoriLevel.k2, 'label': '2級'},
    {'level': MitoriLevel.k1, 'label': '1級'},
    {'level': MitoriLevel.dan, 'label': '段位'},
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
            children: levels.map((levelData) {
              return ElevatedButton(
                onPressed: () {
                  onLevelChanged(levelData['level'], levelData['label']);
                  Navigator.pop(context);
                },
                child: Text(levelData['label']),
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
  final Function(DivMultLevel, String) onLevelChanged;

  static const List<Map<String, dynamic>> levels = [
    {'level': DivMultLevel.mk9, 'label': '9級'},
    {'level': DivMultLevel.mk8, 'label': '8級'},
    {'level': DivMultLevel.mk7, 'label': '7級'},
    {'level': DivMultLevel.mk6, 'label': '6級'},
    {'level': DivMultLevel.mk5, 'label': '5級'},
    {'level': DivMultLevel.mk4, 'label': '4級'},
    {'level': DivMultLevel.mk3, 'label': '3級'},
    {'level': DivMultLevel.mk2, 'label': '2級'},
    {'level': DivMultLevel.mk1, 'label': '1級'},
    {'level': DivMultLevel.mdan, 'label': '段位'},
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
            children: levels.map((levelData) {
              return ElevatedButton(
                onPressed: () {
                  onLevelChanged(levelData['level'], levelData['label']);
                  Navigator.pop(context);
                },
                child: Text(levelData['label']),
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
  final Function(DivMultLevel, String) onLevelChanged;

  static const List<Map<String, dynamic>> levels = [
    {'level': DivMultLevel.dk8, 'label': '8級'},
    {'level': DivMultLevel.dk7, 'label': '7級'},
    {'level': DivMultLevel.dk6, 'label': '6級'},
    {'level': DivMultLevel.dk5, 'label': '5級'},
    {'level': DivMultLevel.dk4, 'label': '4級'},
    {'level': DivMultLevel.dk3, 'label': '3級'},
    {'level': DivMultLevel.dk2, 'label': '2級'},
    {'level': DivMultLevel.dk1, 'label': '1級'},
    {'level': DivMultLevel.ddan, 'label': '段位'},
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
            children: levels.map((levelData) {
              return ElevatedButton(
                onPressed: () {
                  onLevelChanged(levelData['level'], levelData['label']);
                  Navigator.pop(context);
                },
                child: Text(levelData['label']),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
