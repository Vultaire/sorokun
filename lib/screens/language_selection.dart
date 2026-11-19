import 'package:flutter/material.dart';
import 'package:soroban_app/l10n/generated/app_localizations.dart';
import 'package:soroban_app/screens/components/labeled_sliding_segment.dart';
import 'package:soroban_app/screens/settings.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key, required this.onConfirm});

  final Future<void> Function() onConfirm;

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  bool _isConfirming = false;

  Future<void> _confirm() async {
    setState(() => _isConfirming = true);
    try {
      await widget.onConfirm();
    } finally {
      if (mounted) setState(() => _isConfirming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = InheritedAppController.of(context);
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    const languageOptions = [
      // Keep these self-names stable, as on the settings screen.
      (AppLanguage.japanese, '日本語'),
      (AppLanguage.japaneseKana, 'にほんご'),
      (AppLanguage.english, 'English'),
    ];

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 640;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.languageSelectionTitle,
                          textAlign: TextAlign.center,
                          style: textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 20),
                        LabeledSlidingSegmentedControl<AppLanguage>(
                          key: const ValueKey('initial-language-selector'),
                          groupValue: controller.language,
                          options: languageOptions,
                          onValueChanged: controller.previewLanguage,
                          proportionalWidth: true,
                          horizontalPadding: compact ? 4 : 16,
                          verticalPadding: compact ? 8 : 16,
                          labelStyle: compact ? textTheme.titleMedium : null,
                        ),
                        const SizedBox(height: 28),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 360),
                          child: SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              key: const ValueKey(
                                'language-selection-confirm-button',
                              ),
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(64),
                                textStyle: compact
                                    ? textTheme.titleMedium
                                    : textTheme.headlineSmall,
                              ),
                              onPressed: _isConfirming ? null : _confirm,
                              child: Text(l10n.languageSelectionConfirm),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
