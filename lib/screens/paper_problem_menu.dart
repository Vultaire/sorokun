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
  final DivMultLevel multiplicationLevel = DivMultLevel.mk6;
  final DivMultLevel divisionLevel = DivMultLevel.ddan;
  final MitoriLevel mitoriLevel = MitoriLevel.k6;

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
                onPressed: () {
                  context.push('/paper-problem', extra: divisionLevel);
                },
                child: const Text('Start Mitori'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
