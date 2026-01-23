import 'package:flutter/material.dart';

import 'paper_problem.dart';

class PaperResultsScreen extends StatelessWidget {
  final List<String> allAnswers;
  final List<bool> answerBools;
  final List<TextFieldData> textFieldDataList;
  final Duration? elapsed;

  const PaperResultsScreen({
    super.key,
    required this.allAnswers,
    required this.answerBools,
    required this.textFieldDataList,
    this.elapsed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Total: ${allAnswers.length}'),
            Text('Correct: ${answerBools.where((b) => b).length}'),
            // Add more result details here
          ],
        ),
      ),
    );
  }
}
