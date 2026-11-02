// Modified by Vultaire on 2026-11-02.
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
import 'package:soroban_app/screens/components/organization_option.dart';
import 'package:soroban_app/screens/components/grade_reference_info_button.dart';
import 'package:soroban_app/screens/welcome_screen.dart';
import 'package:soroban_app/main.dart' as app;

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

  group('welcome screen preference', () {
    test('unchecked dismissal lasts for this launch only', () async {
      SharedPreferences.setMockInitialValues({});
      final controller = AppController(preferredLocales: const []);
      await controller.ready;

      expect(controller.shouldShowWelcomeScreen, isTrue);
      await controller.completeWelcome(doNotShowAgain: false);
      expect(controller.shouldShowWelcomeScreen, isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('welcome_screen_suppressed'), isNull);
      controller.dispose();

      final nextLaunch = AppController(preferredLocales: const []);
      await nextLaunch.ready;
      expect(nextLaunch.shouldShowWelcomeScreen, isTrue);
      nextLaunch.dispose();
    });

    test('checked dismissal persists across launches', () async {
      SharedPreferences.setMockInitialValues({});
      final controller = AppController(preferredLocales: const []);
      await controller.ready;
      await controller.completeWelcome(doNotShowAgain: true);
      expect(controller.shouldShowWelcomeScreen, isFalse);
      controller.dispose();

      final nextLaunch = AppController(preferredLocales: const []);
      await nextLaunch.ready;
      expect(nextLaunch.shouldShowWelcomeScreen, isFalse);
      nextLaunch.dispose();
    });
  });

  testWidgets('welcome screen presents Japanese before English', (
    WidgetTester tester,
  ) async {
    bool? doNotShowAgain;
    await tester.pumpWidget(
      MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: WelcomeScreen(
          showDoNotShowAgain: true,
          onContinue: (value) async => doNotShowAgain = value,
        ),
      ),
    );

    expect(find.text('ようこそ、そろくん！'), findsOneWidget);
    expect(find.text('Welcome to Sorokun!'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('日本語')).dy,
      lessThan(tester.getTopLeft(find.text('English')).dy),
    );
    expect(
      tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
      isFalse,
    );

    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(doNotShowAgain, isTrue);
  });

  testWidgets('startup welcome can be reopened from Credits', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final controller = AppController(
      preferredLocales: const [Locale('en', 'US')],
    );
    await controller.ready;

    await tester.pumpWidget(app.AbacusApp(appController: controller));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to Sorokun!'), findsOneWidget);
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    await tester.tap(find.text('OK'));
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    expect(find.text('Choose a subject'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('welcome_screen_suppressed'), isTrue);

    await tester.tap(find.text('Credits'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    final reopenButton = find.text('Show welcome screen again');
    final creditsList = find.byType(Scrollable).first;
    for (var i = 0; i < 8 && reopenButton.evaluate().isEmpty; i++) {
      await tester.drag(
        creditsList,
        const Offset(0, -240),
        warnIfMissed: false,
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.ensureVisible(reopenButton);
    await tester.tap(reopenButton);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    expect(find.text('Welcome to Sorokun!'), findsOneWidget);
    expect(find.byType(CheckboxListTile), findsNothing);
    await tester.tap(find.text('OK'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(find.text('Show welcome screen again'), findsOneWidget);
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

  testWidgets('English home branding retains the original logo artwork', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'ui_language': 'english'});
    final controller = AppController(
      preferredLocales: const [Locale('en', 'US')],
    );
    await controller.ready;

    await tester.pumpWidget(_localizedApp(controller, const HomePage()));
    await tester.pump();

    bool hasAsset(String path) => tester
        .widgetList<Image>(
          find.byWidgetPredicate(
            (widget) =>
                widget is Image &&
                widget.image is AssetImage &&
                (widget.image as AssetImage).assetName == path,
          ),
        )
        .isNotEmpty;
    expect(hasAsset('assets/sorokun_white.png'), isTrue);
    expect(hasAsset('assets/sorokun_color.png'), isTrue);
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
      find.text('このフォークの改変は、Vultaire の指示のもと、LLM を用いたエージェント型開発で行われました。'),
      findsOneWidget,
    );
    expect(
      find.text('日本語・English インターフェースのローカライズを2026-11-02に追加しました。'),
      findsOneWidget,
    );
    expect(
      find.text('英語インターフェースの翻訳にはLLMを使用しています。日本語が原文です。誤訳のご指摘を歓迎します。'),
      findsOneWidget,
    );
    expect(
      find.text(
        '本フォークのそろくん！は独立した非公式の練習用アプリです。全国珠算教育連盟、日本珠算連盟、日本フラッシュ暗算協会の公式プログラムではなく、各団体との提携関係はなく、各団体から公認・推奨を受けたものでもありません。アプリ内の級位・段位等は練習用の目安であり、各団体の最新の基準や検定要件と異なる場合があります。最新の要件は各団体にご確認ください。',
      ),
      findsOneWidget,
    );
  });

  testWidgets('grade-reference info dialog follows the selected locale', (
    WidgetTester tester,
  ) async {
    Widget infoApp(Locale locale) => MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(
        appBar: AppBar(actions: const [GradeReferenceInfoButton()]),
      ),
    );

    await tester.pumpWidget(infoApp(const Locale('en')));
    await tester.tap(find.byTooltip('About grade references'));
    await tester.pumpAndSettle();

    expect(find.text('About grade references'), findsOneWidget);
    expect(
      find.text(
        'This fork of Sorokun! is an independent, unofficial practice app. It is not an official program of Zenshuren, Nisshuren, or the Japan Flash Anzan Association, and it has no affiliation with or endorsement from these organizations. Grade and level labels are provided for practice and may differ from their current official standards or examination requirements. Please confirm current requirements with the relevant organization.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    await tester.pumpWidget(infoApp(const Locale('ja')));
    await tester.tap(find.byTooltip('級位・段位の表示について'));
    await tester.pumpAndSettle();

    expect(find.text('級位・段位の表示について'), findsOneWidget);
    expect(
      find.text(
        '本フォークのそろくん！は独立した非公式の練習用アプリです。全国珠算教育連盟、日本珠算連盟、日本フラッシュ暗算協会の公式プログラムではなく、各団体との提携関係はなく、各団体から公認・推奨を受けたものでもありません。アプリ内の級位・段位等は練習用の目安であり、各団体の最新の基準や検定要件と異なる場合があります。最新の要件は各団体にご確認ください。',
      ),
      findsOneWidget,
    );
    expect(find.text('閉じる'), findsOneWidget);
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
                Text(l10n.appTitle),
                Text(Kyuui.nskj3.localizedLabel(l10n)),
                Text(Kyuui.zsd1.localizedLabel(l10n)),
                Text(Denomination.zenshuren.localizedName(l10n)),
                Text(RankLabel.preShodan.localizedName(l10n)),
                Text(l10n.homeCombinedLine1),
                Text(l10n.homeCombinedLine2),
                Text(l10n.combinedSubjectsTitle),
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
        'Sorokun!',
        'Pre-3 kyu',
        '1 dan',
        'Zenshuren',
        'Pre-1 dan',
        'Soroban',
        'Practice',
        'Soroban Practice',
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
        'そろくん！',
        '準3級',
        '初段',
        '全国珠算教育連盟',
        '準初段',
        '総合',
        '種目',
        '総合種目',
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

  testWidgets('organization selectors show official English subtitles only', (
    WidgetTester tester,
  ) async {
    Widget organizationSamples(Locale locale) => MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context);
          Widget asWidget(dynamic option) =>
              option is Widget ? option : Text(option.toString());

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              asWidget(
                organizationOption(
                  context,
                  name: l10n.selectorZenshuren,
                  subtitle: l10n.zenshurenOrganizationSubtitle,
                ),
              ),
              asWidget(
                organizationOption(
                  context,
                  name: l10n.selectorNisshuren,
                  subtitle: l10n.nisshurenOrganizationSubtitle,
                ),
              ),
              asWidget(
                organizationOption(context, name: l10n.selectorFlashAnzan),
              ),
            ],
          );
        },
      ),
    );

    await tester.pumpWidget(organizationSamples(const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text('Zenshuren'), findsOneWidget);
    expect(
      find.text('(The League for Soroban\nEducation of Japan)'),
      findsOneWidget,
    );
    expect(find.text('Nisshuren'), findsOneWidget);
    expect(
      find.text('(The League of Japan\nAbacus Associations)'),
      findsOneWidget,
    );
    expect(find.text('Japan Flash Anzan Association'), findsOneWidget);
    expect(find.text('(Flash Anzan grades)'), findsNothing);

    await tester.pumpWidget(organizationSamples(const Locale('ja')));
    await tester.pumpAndSettle();

    expect(find.text('全珠連'), findsOneWidget);
    expect(find.text('日珠連'), findsOneWidget);
    expect(find.text('協会'), findsOneWidget);
    expect(find.text('（全国珠算教育連盟）'), findsNothing);
    expect(find.text('（日本珠算連盟）'), findsNothing);
  });
}
