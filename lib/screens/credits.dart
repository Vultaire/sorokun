// Modified by Vultaire on 2026-11-01.
// Fork: https://github.com/Vultaire/sorokun
import 'package:flutter/material.dart';
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
            Text('元のそろくんのソースコードはこちらで公開されています：', style: textTheme.titleMedium),
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
            Text('このフォークのソースコード：', style: textTheme.titleMedium),
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
            Text(
              '原作: Chet Lin。Vultaire による改変版です（2026-11-01）。読み上げ算と VOICEVOX を削除し、Web ビルド対応を行いました。',
              style: textTheme.titleMedium,
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
              title: 'ライセンス',
              entries: [
                _CreditEntry(
                  role: 'ライセンス',
                  name: 'GNU General Public License v3.0',
                  onTap: () => _launchUrl(
                    'https://github.com/Vultaire/sorokun/blob/main/LICENSE.txt',
                  ),
                ),
              ],
            ),
            Text(
              '本ソフトウェアは無保証です。GPL v3.0 の条件に従って再配布・改変できます。ライセンス全文は上記リンクから確認できます。',
              style: textTheme.titleMedium,
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
