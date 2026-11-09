// Modified by Vultaire on 2026-11-02.
// Fork: https://github.com/Vultaire/sorokun
import 'package:flutter/material.dart';
import 'package:soroban_app/l10n/generated/app_localizations.dart';

// This bilingual welcome is intentionally identical across UI locales, so its
// copy is hard-coded here instead of being duplicated in each ARB file. The
// Japanese wording is based on app_ja.arb; English wording is based on
// app_en.arb.
class _WelcomeCopy {
  const _WelcomeCopy({
    required this.language,
    required this.title,
    required this.intro,
    required this.disclaimerHeading,
    required this.disclaimer,
    required this.closing,
  });

  final String language;
  final String title;
  final String intro;
  final String disclaimerHeading;
  final String disclaimer;
  final String closing;
}

const _japaneseWelcomeCopy = _WelcomeCopy(
  language: '日本語',
  title: 'そろくん！のフォークをお試しいただき、ありがとうございます。',
  intro:
      'Chet Linさんが作ったオリジナル版は、iOSでそろばんを学ぶのにとても優れたアプリだと感じました。Webでも使えるようにし、日本語を話さないそろばん学習者にも使ってもらえるよう、英語の基本的なインターフェースを追加することを試みました。このフォークはその成果です。',
  disclaimerHeading: '団体との関係と級位について',
  disclaimer:
      'このフォークは独立した非公式の練習用アプリです。全国珠算教育連盟、日本珠算連盟、日本フラッシュ暗算協会の公式プログラムではなく、各団体との提携・協力関係もありません。また、公認・推奨も受けていません。オリジナル版もこれらの団体とは公式な関係ではなかったと認識しています。\n\n総合種目とフラッシュ暗算の検定モードで選べる級位は、該当する団体の制度をもとにしているようです。フラッシュ暗算のフリーモードは例外で、口数や桁数などを自由に設定して練習できます。これらの級位は、私自身のそろばん学習経験からはおおむね妥当と思われますが、各団体の最新の基準と一つひとつ照合したわけではありません。内容が不完全であったり、現在の検定要件と異なったりする可能性があり、一致を保証するものではありません。現在そろばん教室に通っている方は、ご自身のレベルに適した練習内容について先生にご相談ください。最新の検定要件は各団体にご確認ください。',
  closing:
      'このフォークでは、オリジナル版の読み上げ算を削除し、Web対応や英語インターフェースなどを追加しました。無料の練習用アプリとして提供しており、資格の認定や検定の合格を保証するものではありません。\n\nお楽しみいただければ幸いです。原作者のChet Linさん、素晴らしいアプリをありがとうございます。\n\n— ゴーインズ・ポール（ボルテーア）',
);

const _englishWelcomeCopy = _WelcomeCopy(
  language: 'English',
  title: 'Thank you for trying my fork of Sorokun!',
  intro:
      "I found Chet Lin's original Sorokun! to be an excellent study app for iOS. I wanted to experiment with bringing it to the web and adding a basic English interface for people studying soroban who do not speak Japanese. This fork is the result of that experiment.",
  disclaimerHeading: 'About affiliations and grade levels',
  disclaimer:
      "This fork is an independent, unofficial practice app. It is not an official program of Zenshuren, Nisshuren, or the Japan Flash Anzan Association, and it is not affiliated with or endorsed by any of them. To the best of my knowledge, the original Sorokun! was not officially affiliated with these organizations either.\n\nThe selectable grade levels in Soroban Practice and Flash Anzan Exam appear to be modeled on the relevant organizations' systems. Based on my experience studying soroban, they seem broadly accurate, but I have not checked each one against the organizations' current standards. They may be incomplete or out of date, and I cannot guarantee that they match current exam requirements. If you are currently taking soroban classes, please ask your teacher which practice materials are appropriate for your level. For current exam requirements, check with the relevant organization.",
  closing:
      'This fork removes the original read-aloud exercises and adds web support, a basic English interface, and other features. It is offered as a free study aid, not as a certification tool or a guarantee of exam readiness.\n\nI hope you enjoy it. To Chet Lin, the original author: thank you for an excellent program.\n\n— Paul Goins (Vultaire)',
);

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
                                  key: const ValueKey('welcome-japanese-copy'),
                                  language: _japaneseWelcomeCopy.language,
                                  title: _japaneseWelcomeCopy.title,
                                  intro: _japaneseWelcomeCopy.intro,
                                  disclaimerHeading:
                                      _japaneseWelcomeCopy.disclaimerHeading,
                                  disclaimer: _japaneseWelcomeCopy.disclaimer,
                                  closing: _japaneseWelcomeCopy.closing,
                                  textTheme: textTheme,
                                  accentColor: colorScheme.primary,
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 44),
                                  child: Divider(),
                                ),
                                _LanguageBlock(
                                  key: const ValueKey('welcome-english-copy'),
                                  language: _englishWelcomeCopy.language,
                                  title: _englishWelcomeCopy.title,
                                  intro: _englishWelcomeCopy.intro,
                                  disclaimerHeading:
                                      _englishWelcomeCopy.disclaimerHeading,
                                  disclaimer: _englishWelcomeCopy.disclaimer,
                                  closing: _englishWelcomeCopy.closing,
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
    super.key,
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
