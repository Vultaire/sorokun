import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soroban_app/main.dart';

class ExitButton extends StatelessWidget {
  const ExitButton({
    super.key,
    required this.onShowResults,
    required this.isSingleProblem,
  });

  final VoidCallback onShowResults;
  final bool isSingleProblem;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded),
      onPressed: () async {
        if (isSingleProblem) {
          context.pop();
          return;
        }
        await showExitDialog(context, onSubmit: onShowResults);
      },
      color: Colors.white,
      iconSize: 22,
      padding: const EdgeInsets.all(16),
    );
  }
}
