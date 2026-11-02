// Modified by Vultaire on 2026-11-02.
// Fork: https://github.com/Vultaire/sorokun
import 'package:flutter/material.dart';
import 'package:soroban_app/l10n/generated/app_localizations.dart';

class GradeReferenceInfoButton extends StatelessWidget {
  const GradeReferenceInfoButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return IconButton(
      tooltip: l10n.gradeReferenceTitle,
      icon: const Icon(Icons.info_outline_rounded),
      onPressed: () {
        showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(l10n.gradeReferenceTitle),
            content: SingleChildScrollView(
              child: Text(l10n.gradeReferenceDisclosure),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(l10n.close),
              ),
            ],
          ),
        );
      },
    );
  }
}
