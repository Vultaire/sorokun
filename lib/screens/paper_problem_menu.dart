import 'package:flutter/material.dart';
import 'package:soroban_app/problem_generation/generation_spec.dart';

class PaperConfPage extends StatefulWidget {
  const PaperConfPage({super.key});

  @override
  State<PaperConfPage> createState() => _PaperConfPageState();
}

class _PaperConfPageState extends State<PaperConfPage> {
  final MultiplicationSpec savedMultiplicationDifficulty;
  final DivMultSpec savedDivisionDifficulty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: .start,
            crossAxisAlignment: .stretch,
            children: [
              ElevatedButton(
                onPressed: () {},
                child: const Text('Placeholder'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
