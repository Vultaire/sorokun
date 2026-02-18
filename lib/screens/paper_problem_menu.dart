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
              _buildStartButtons(startButtonType: .mitori),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartButtons({required StartButtonType startButtonType}) {
    late final String label;

    switch (startButtonType) {
      case .mitori:
        label = 'みとり算';
      case .wari:
        label = 'わり算';
      case .kake:
        label = 'かけ算';
      case .mitorian:
        label = 'みとり暗算';
      case .warian:
        label = 'わり暗算';
      case .kakean:
        label = 'かけ暗算';
    }

    return Row(
      children: [
        NavigationButton(
          label: Text('${kyuui.kyuuString}の$label'),
          onPressed: () {
            context.push(
              '/paper-problem',
              extra: {
                'selectedLevel': kyuui.mitoriAnzan,
                'isExam': isExam,
                'time': kyuui.mitoriAnzan.denomination.timeLimit,
                'appBarTitle': 'placeholder',
              },
            );
          },
        ),
      ],
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
