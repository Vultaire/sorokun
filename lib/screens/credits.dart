// Modified by Vultaire on 2026-11-01.
// Fork: https://github.com/Vultaire/sorokun
import 'package:flutter/material.dart';
import 'package:soroban_app/l10n/generated/app_localizations.dart';
import 'package:soroban_app/screens/components/appbar.dart';
import 'package:url_launcher/url_launcher.dart';

class CreditsPage extends StatelessWidget {
  const CreditsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: CustomAppBar(title: l10n.credits, context: context),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _CreditSection(
              title: l10n.creditsDevelopment,
              entries: [
                _CreditEntry(role: l10n.developerRole, name: 'Chet Lin'),
              ],
            ),
            Text(l10n.originalSourceIntro, style: textTheme.titleMedium),
            InkWell(
              onTap: () => _launchUrl('https://github.com/konomu/sorokun'),
              child: Text(
                'https://github.com/konomu/sorokun',
                style: textTheme.titleMedium?.copyWith(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            Text(l10n.forkSourceIntro, style: textTheme.titleMedium),
            InkWell(
              onTap: () => _launchUrl('https://github.com/Vultaire/sorokun'),
              child: Text(
                'https://github.com/Vultaire/sorokun',
                style: textTheme.titleMedium?.copyWith(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            Text(l10n.forkModificationNotice, style: textTheme.titleMedium),
            if (l10n.localeName == 'en') ...[
              const SizedBox(height: 8),
              Text(
                l10n.forkDevelopmentDisclosure,
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(l10n.localizationUpdateNotice, style: textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                l10n.englishTranslationDisclosure,
                style: textTheme.titleMedium,
              ),
            ],
            const SizedBox(height: 24),
            _CreditSection(
              title: l10n.fontCredits,
              entries: [
                _CreditEntry(role: l10n.abacusBeadFont, name: '小黒珠算教室　代表　小黒　元'),
                _CreditEntry(role: l10n.sorobanNumeralFont, name: 'Chet Lin'),
              ],
            ),
            const SizedBox(height: 24),
            _CreditSection(
              title: l10n.license,
              entries: [
                _CreditEntry(
                  role: l10n.license,
                  name: 'GNU General Public License v3.0',
                  onTap: () => _launchUrl(
                    'https://github.com/Vultaire/sorokun/blob/main/LICENSE.txt',
                  ),
                ),
              ],
            ),
            Text(l10n.noWarrantyLicenseNotice, style: textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

class _CreditSection extends StatelessWidget {
  const _CreditSection({required this.title, required this.entries});

  final String title;
  final List<_CreditEntry> entries;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Divider(),
        ...entries,
      ],
    );
  }
}

Future<void> _launchUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _CreditEntry extends StatelessWidget {
  const _CreditEntry({required this.role, required this.name, this.onTap});

  final String role;
  final String name;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final roleWidth = MediaQuery.sizeOf(context).width < 500 ? 110.0 : 175.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            SizedBox(
              width: roleWidth,
              child: Text(
                role,
                style: textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: textTheme.bodyLarge?.copyWith(
                  color: onTap != null ? Colors.blue : null,
                  decoration: onTap != null ? TextDecoration.underline : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
