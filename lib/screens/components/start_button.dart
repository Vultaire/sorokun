import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soroban_app/screens/components/navigation_button.dart';

class StartButton extends StatelessWidget {
  const StartButton({
    super.key,
    required this.selectedLevel,
    required this.character,
    this.widthFactor = 0.8,
  });

  final dynamic selectedLevel;
  final dynamic character;
  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        child: NavigationButton(
          color: Theme.of(context).colorScheme.primaryContainer,
          onPressed: () {
            context.push(
              '/aloud-problem',
              extra: {
                'isSingleProblem': false,
                'selectedLevel': selectedLevel,
                'character': character,
              },
            );
          },
          child: Center(
            child: Text(
              'スタート',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
