// Modified by Vultaire on 2026-11-01.
// Fork: https://github.com/Vultaire/sorokun
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soroban_app/l10n/generated/app_localizations.dart';
import 'package:soroban_app/models/level_definitions.dart';
import 'package:soroban_app/models/level_localizations.dart';
import 'package:soroban_app/screens/home_page.dart';
import 'package:soroban_app/screens/settings.dart';
import 'package:soroban_app/screens/credits.dart';

Widget _localizedApp(AppController controller, Widget home) {
  return AnimatedBuilder(
    animation: controller,
    builder: (context, _) => MaterialApp(
      locale: controller.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: InheritedAppController(controller: controller, child: home),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('initial language resolution', () {
    test('uses the first preferred locale only', () {
      expect(
        resolveInitialLanguage(const [Locale('ja', 'JP'), Locale('en', 'US')]),
        AppLanguage.japanese,
      );
      expect(
        resolveInitialLanguage(const [Locale('en', 'US'), Locale('ja', 'JP')]),
        AppLanguage.english,
      );
      expect(
        resolveInitialLanguage(const [Locale('fr', 'FR'), Locale('ja', 'JP')]),
        AppLanguage.english,
      );
      expect(resolveInitialLanguage(const []), AppLanguage.english);
    });

    test('unsupported explicit locales resolve to English', () {
      expect(resolveAppLocale(const Locale('ja', 'JP')), const Locale('ja'));
      expect(resolveAppLocale(const Locale('en', 'US')), const Locale('en'));
      expect(resolveAppLocale(const Locale('fr', 'FR')), const Locale('en'));
      expect(resolveAppLocale(null), const Locale('en'));
    });

    test('a saved language overrides the device locale', () {
      expect(
        resolveInitialLanguage(const [
          Locale('ja', 'JP'),
        ], savedLanguage: 'english'),
        AppLanguage.english,
      );
      expect(
        resolveInitialLanguage(const [
          Locale('en', 'US'),
        ], savedLanguage: 'japanese'),
        AppLanguage.japanese,
      );
    });
  });

  testWidgets('home page presents the available practice modes', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'ui_language': 'japanese'});
    final controller = AppController(
      preferredLocales: const [Locale('en', 'US')],
    );
    await controller.ready;

    await tester.pumpWidget(_localizedApp(controller, const HomePage()));
    await tester.pump();

    expect(find.text('種目を選ぶ'), findsOneWidget);
    expect(find.text('検定'), findsOneWidget);
    expect(find.text('フリー'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('English home branding uses the language-neutral app name', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'ui_language': 'english'});
    final controller = AppController(
      preferredLocales: const [Locale('en', 'US')],
    );
    await controller.ready;

    await tester.pumpWidget(_localizedApp(controller, const HomePage()));
    await tester.pump();

    expect(find.text('Sorokun'), findsOneWidget);
    expect(find.text('そろくん！'), findsNothing);
    controller.dispose();
  });

  testWidgets('Credits retain the original Japanese copy', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ja'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const CreditsPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('元のそろくんのソースコードはこちらで公開されています：'), findsOneWidget);
    expect(find.text('このフォークのソースコード：'), findsOneWidget);
    expect(
      find.text(
        'このフォークの改変は、Vultaire の指示のもと、LLM を用いたエージェント型開発で行われました。',
      ),
      findsOneWidget,
    );
    expect(
      find.text('日本語・English インターフェースのローカライズを2026-11-02に追加しました。'),
      findsOneWidget,
    );
    expect(
      find.text(
        '英語インターフェースの翻訳にはLLMを使用しています。日本語が原文です。誤訳のご指摘を歓迎します。',
      ),
      findsOneWidget,
    );
  });

  testWidgets('settings switches locale immediately and persists the choice', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final controller = AppController(
      preferredLocales: const [Locale('ja', 'JP'), Locale('en', 'US')],
    );
    await controller.ready;

    await tester.pumpWidget(
      _localizedApp(controller, const ColorSchemeSettingsPage()),
    );
    await tester.pumpAndSettle();

    expect(controller.language, AppLanguage.japanese);
    expect(find.text('言語 / Language'), findsOneWidget);
    expect(find.text('日本語'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('テンキーの配置'), findsOneWidget);

    await tester.tap(find.text('日本語'));
    await tester.pumpAndSettle();
    await controller.setLanguage(AppLanguage.japanese);
    var prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('ui_language'), 'japanese');

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(controller.language, AppLanguage.english);
    expect(controller.locale, const Locale('en'));
    expect(find.text('Keypad position'), findsOneWidget);
    expect(find.text('アプリ設定'), findsNothing);
    prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('ui_language'), 'english');

    final restoredController = AppController(
      preferredLocales: const [Locale('ja', 'JP')],
    );
    await restoredController.ready;
    expect(restoredController.language, AppLanguage.english);
    expect(restoredController.locale, const Locale('en'));

    controller.dispose();
    restoredController.dispose();
  });

  testWidgets('representative model grade labels follow the active locale', (
    WidgetTester tester,
  ) async {
    Widget localizedGradeSamples(Locale locale) => MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context);
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(Kyuui.zsk10.localizedLabel(l10n)),
                Text(Kyuui.nskj3.localizedLabel(l10n)),
                Text(Kyuui.zsd1.localizedLabel(l10n)),
                Text(Denomination.zenshuren.localizedName(l10n)),
                Text(RankLabel.preShodan.localizedName(l10n)),
                Text(l10n.homeFlashLine1),
                Text(l10n.originalSourceIntro),
                Text(l10n.selectorZenshuren),
                Text(l10n.organizationZenshuren),
                Text(l10n.pointsEach(10, 100)),
                Text(l10n.roundingDecimalNotice),
                Text(l10n.roundingIntegerNotice),
                Text(l10n.problemCount(1)),
                Text(l10n.problemCount(2)),
                Text(l10n.timeLimit(1)),
                Text(l10n.timeLimit(7)),
                Text('1${l10n.digitsUnit(1)}'),
                Text('2${l10n.digitsUnit(2)}'),
                Text('1${l10n.kuchiUnit(1)}'),
                Text('2${l10n.kuchiUnit(2)}'),
              ],
            ),
          );
        },
      ),
    );

    await tester.pumpWidget(localizedGradeSamples(const Locale('en')));
    await tester.pumpAndSettle();
    expect(
      tester.widgetList<Text>(find.byType(Text)).map((text) => text.data),
      [
        '10 kyu',
        'Pre-3 kyu',
        '1 dan',
        'Zenshuren',
        'Pre-1 dan',
        'Flash',
        'Original Sorokun source code:',
        'Zenshuren',
        'Zenshuren',
        '10 points each (max 100 points)',
        'Note: Round to the nearest hundredth.',
        'Note: Round to the nearest whole number.',
        '1 problem',
        '2 problems',
        'Time limit: 1 minute',
        'Time limit: 7 minutes',
        '1 digit',
        '2 digits',
        '1 number',
        '2 numbers',
      ],
    );

    await tester.pumpWidget(localizedGradeSamples(const Locale('ja')));
    await tester.pumpAndSettle();
    expect(
      tester.widgetList<Text>(find.byType(Text)).map((text) => text.data),
      [
        '10級',
        '準3級',
        '初段',
        '全国珠算教育連盟',
        '準初段',
        'ﾌﾗｯｼｭ',
        '元のそろくんのソースコードはこちらで公開されています：',
        '全珠連',
        '全国珠算教育連盟',
        '各10点 (100点満点)',
        '（注意） 小数第3位未満四捨五入。',
        '（注意） 整数位未満四捨五入。',
        '問題数：1題',
        '問題数：2題',
        '制限時間：1分',
        '制限時間：7分',
        '1桁',
        '2桁',
        '1口',
        '2口',
      ],
    );
  });
}
