// Modified by Vultaire on 2026-11-02.
// Fork: https://github.com/Vultaire/sorokun
import 'package:flutter/material.dart';
import 'package:soroban_app/l10n/generated/app_localizations.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({
    super.key,
    required this.showDoNotShowAgain,
    required this.onContinue,
  });

  final bool showDoNotShowAgain;
  final Future<void> Function(bool doNotShowAgain) onContinue;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _doNotShowAgain = false;
  bool _isContinuing = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: !widget.showDoNotShowAgain,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: [
                Expanded(
                  child: Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 820),
                          child: SizedBox(
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _LanguageBlock(
                                  language: l10n.welcomeJapaneseLanguageHeading,
                                  title: l10n.welcomeJapaneseTitle,
                                  intro: l10n.welcomeJapaneseIntro,
                                  disclaimerHeading:
                                      l10n.welcomeJapaneseDisclaimerHeading,
                                  disclaimer: l10n.welcomeJapaneseDisclaimer,
                                  closing: l10n.welcomeJapaneseClosing,
                                  textTheme: textTheme,
                                  accentColor: colorScheme.primary,
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 44),
                                  child: Divider(),
                                ),
                                _LanguageBlock(
                                  language: l10n.welcomeEnglishLanguageHeading,
                                  title: l10n.welcomeEnglishTitle,
                                  intro: l10n.welcomeEnglishIntro,
                                  disclaimerHeading:
                                      l10n.welcomeEnglishDisclaimerHeading,
                                  disclaimer: l10n.welcomeEnglishDisclaimer,
                                  closing: l10n.welcomeEnglishClosing,
                                  textTheme: textTheme,
                                  accentColor: colorScheme.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (widget.showDoNotShowAgain)
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 820),
                      child: CheckboxListTile(
                        value: _doNotShowAgain,
                        onChanged: (value) =>
                            setState(() => _doNotShowAgain = value ?? false),
                        title: Text(l10n.welcomeDoNotShowAgain),
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
                      onPressed: _isContinuing ? null : _continue,
                      child: Text(l10n.welcomeOk),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageBlock extends StatelessWidget {
  const _LanguageBlock({
    required this.language,
    required this.title,
    required this.intro,
    required this.disclaimerHeading,
    required this.disclaimer,
    required this.closing,
    required this.textTheme,
    required this.accentColor,
  });

  final String language;
  final String title;
  final String intro;
  final String disclaimerHeading;
  final String disclaimer;
  final String closing;
  final TextTheme textTheme;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          language,
          style: textTheme.labelLarge?.copyWith(
            color: accentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(intro, style: textTheme.bodyLarge),
        const SizedBox(height: 16),
        Text(
          disclaimerHeading,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(disclaimer, style: textTheme.bodyLarge),
        const SizedBox(height: 16),
        Text(closing, style: textTheme.bodyLarge),
      ],
    );
  }
}
