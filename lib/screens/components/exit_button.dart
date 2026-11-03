// Modified by Vultaire on 2026-11-01.
// Fork: https://github.com/Vultaire/sorokun
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soroban_app/l10n/generated/app_localizations.dart';
import 'package:soroban_app/main.dart';

class ExitButton extends StatelessWidget {
  const ExitButton({
    super.key,
    required this.onShowResults,
    required this.isSingleProblem,
    this.onExit,
  });

  final VoidCallback onShowResults;
  final bool isSingleProblem;
  final VoidCallback? onExit;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded),
      tooltip: AppLocalizations.of(context).back,
      onPressed: () async {
        if (isSingleProblem) {
          onExit?.call();
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
