// Modified by Vultaire on 2026-11-02.
// Fork: https://github.com/Vultaire/sorokun
import 'package:flutter/material.dart';
import 'package:soroban_app/l10n/generated/app_localizations.dart';

dynamic organizationOption(
  BuildContext context, {
  required String name,
  String? subtitle,
}) {
  final l10n = AppLocalizations.of(context);
  if (Localizations.localeOf(context).languageCode == 'ja') return name;

  final textTheme = Theme.of(context).textTheme;
  if (subtitle == null) {
    return Text(name, style: textTheme.titleSmall, textAlign: TextAlign.center);
  }

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(name, style: textTheme.titleSmall, textAlign: TextAlign.center),
      Text(
        l10n.organizationSubtitleLine(subtitle),
        style: textTheme.bodySmall,
        textAlign: TextAlign.center,
      ),
    ],
  );
}
