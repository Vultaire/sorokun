import 'package:flutter/material.dart';
import 'package:soroban_app/l10n/generated/app_localizations.dart';

class StartupDisclaimerScreen extends StatefulWidget {
  const StartupDisclaimerScreen({super.key, required this.onContinue});

  final Future<void> Function(bool doNotShowAgain) onContinue;

  @override
  State<StartupDisclaimerScreen> createState() =>
      _StartupDisclaimerScreenState();
}

class _StartupDisclaimerScreenState extends State<StartupDisclaimerScreen> {
  bool _doNotShowAgain = false;
  bool _isContinuing = false;

  Future<void> _continue() async {
    setState(() => _isContinuing = true);
    try {
      await widget.onContinue(_doNotShowAgain);
    } finally {
      if (mounted) setState(() => _isContinuing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  l10n.startupDisclaimerTitle,
                  textAlign: TextAlign.center,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Scrollbar(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 820),
                        child: SizedBox(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.startupDisclaimerParagraph1,
                                style: textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                l10n.startupDisclaimerParagraph2,
                                style: textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: CheckboxListTile(
                    key: const ValueKey('startup-disclaimer-do-not-show-again'),
                    value: _doNotShowAgain,
                    onChanged: (value) =>
                        setState(() => _doNotShowAgain = value ?? false),
                    title: Text(l10n.startupDisclaimerDoNotShowAgain),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    key: const ValueKey('startup-disclaimer-ok-button'),
                    onPressed: _isContinuing ? null : _continue,
                    child: Text(l10n.startupDisclaimerOk),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
