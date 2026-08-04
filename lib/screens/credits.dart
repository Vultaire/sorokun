import 'package:flutter/material.dart';
import 'package:soroban_app/models/singer_config.dart';
import 'package:soroban_app/screens/components/appbar.dart';
import 'package:url_launcher/url_launcher.dart';

class CreditsPage extends StatelessWidget {
  const CreditsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: CustomAppBar(title: 'クレジット', context: context),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _CreditSection(
              title: '開発',
              entries: const [_CreditEntry(role: 'デベロッパー', name: 'Chet Lin')],
            ),
            Text(
              'そろくんはオープンソースで、ソースコードはこちらで公開しています：',
              style: textTheme.titleMedium,
            ),
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
            Text('貢献したいと思ってくださった方は、どなたでも歓迎します。', style: textTheme.titleMedium),
            const SizedBox(height: 24),
            _CreditSection(
              title: 'サウンド素材',
              entries: const [
                _CreditEntry(role: '効果音', name: 'Sound Asset Source Name'),
                _CreditEntry(role: 'BGM', name: 'BGM Source Name'),
              ],
            ),
            const SizedBox(height: 24),
            _CreditSection(
              title: 'フォント',
              entries: const [
                _CreditEntry(role: 'そろばん玉のフォント', name: '小黒珠算教室　代表　小黒　元'),
                _CreditEntry(role: '珠算の数字のフォント', name: 'Chet Lin'),
              ],
            ),
            const SizedBox(height: 24),
            _CreditSection(
              title: '音声合成',
              entries: [
                _CreditEntry(
                  role: 'VOICEVOX CORE',
                  name: 'VOICEVOX Github Contributor のみなさん',
                  onTap: () =>
                      _launchUrl('https://github.com/VOICEVOX/voicevox_core'),
                ),
                ...buildVoicevoxCreditEntries(),
              ],
            ),
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

List<_CreditEntry> buildVoicevoxCreditEntries({
  List<Character> characters = Character.values,
}) {
  return characters.map((character) {
    final name = '${character.displayString}${character.creditText ?? ''}';
    return _CreditEntry(role: 'VOICEVOX', name: name);
  }).toList();
}

class _CreditEntry extends StatelessWidget {
  const _CreditEntry({required this.role, required this.name, this.onTap});

  final String role;
  final String name;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            SizedBox(
              width: 110,
              child: Text(
                role,
                style: textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              ),
            ),
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
