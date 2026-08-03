import 'package:flutter/material.dart';
import 'package:soroban_app/screens/components/navigation_button.dart';

class StartButton extends StatelessWidget {
  const StartButton({
    super.key,
    required this.onPressed,
    this.widthFactor = 0.8,
  });

  final VoidCallback onPressed;
  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        child: NavigationButton(
          color: Theme.of(context).colorScheme.primaryContainer,
          onPressed: onPressed,
          child: Text(
            'スタート',
            textAlign: .center,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ),
    );
  }
}
