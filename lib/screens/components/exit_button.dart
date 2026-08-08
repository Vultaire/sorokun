import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:soroban_app/main.dart';

class ExitButton extends StatelessWidget {
  const ExitButton({
    super.key,
    required this.homeRoute,
    required this.onShowResults,
    required this.isSingleProblem,
  });

  final String homeRoute;
  final VoidCallback onShowResults;
  final bool isSingleProblem;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Symbols.arrow_back_ios_new_rounded),
      onPressed: () async {
        if (isSingleProblem) {
          context.go(homeRoute);
          return;
        }
        await showExitDialog(
          context,
          homeRoute: homeRoute,
          onSubmit: onShowResults,
        );
      },
      color: Colors.white,
      iconSize: 22,
      padding: const EdgeInsets.all(16),
    );
  }
}
