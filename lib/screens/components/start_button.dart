// Modified by Vultaire on 2026-11-01.
// Fork: https://github.com/Vultaire/sorokun
import 'package:flutter/material.dart';
import 'package:soroban_app/l10n/generated/app_localizations.dart';
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
            AppLocalizations.of(context).start,
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
