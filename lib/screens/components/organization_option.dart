// Modified by Vultaire on 2026-11-01.
// Fork: https://github.com/Vultaire/sorokun
import 'package:flutter/material.dart';
import 'package:soroban_app/l10n/generated/app_localizations.dart';

dynamic organizationOption(
  BuildContext context, {
  required String name,
  required String gloss,
}) {
  final l10n = AppLocalizations.of(context);
  if (Localizations.localeOf(context).languageCode == 'ja') return name;

  final textTheme = Theme.of(context).textTheme;
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(name, style: textTheme.titleSmall, textAlign: TextAlign.center),
      Text(
        l10n.organizationGlossLine(gloss),
        style: textTheme.bodySmall,
        textAlign: TextAlign.center,
      ),
    ],
  );
}
