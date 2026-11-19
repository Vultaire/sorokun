// Modified by Vultaire on 2026-11-02.
// Fork: https://github.com/Vultaire/sorokun
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soroban_app/l10n/generated/app_localizations.dart';
import 'package:soroban_app/models/level_definitions.dart';
import 'package:soroban_app/models/level_localizations.dart';
import 'package:soroban_app/screens/home_page.dart';
import 'package:soroban_app/screens/settings.dart';
import 'package:soroban_app/screens/credits.dart';
import 'package:soroban_app/screens/components/labeled_sliding_segment.dart';
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

bool _containsKanji(String text) => text.runes.any((codePoint) {
  return (codePoint >= 0x3400 && codePoint <= 0x4dbf) ||
      (codePoint >= 0x4e00 && codePoint <= 0x9fff) ||
      (codePoint >= 0xf900 && codePoint <= 0xfaff) ||
      (codePoint >= 0x20000 && codePoint <= 0x323af) ||
      codePoint == 0x3005 || // 々
      codePoint == 0x3007 || // 〇
      codePoint == 0x303b || // 〻
      codePoint == 0x3006; // 〆
});

void _expectStableLanguageOptionLabels(WidgetTester tester) {
  // These self-names stay fixed even when the selected UI language changes.
  expect(find.text('日本語'), findsOneWidget);
  expect(find.text('にほんご'), findsOneWidget);
  expect(find.text('English'), findsOneWidget);
  expect(find.text('Kana'), findsNothing);
  expect(find.text('かな'), findsNothing);
  expect(find.text('えいご'), findsNothing);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('initial language resolution', () {
    test('defaults to Japanese until a language has been saved', () {
      expect(resolveInitialLanguage(), AppLanguage.japanese);
    });

    test('unsupported explicit locales resolve to English', () {
      expect(resolveAppLocale(const Locale('ja', 'JP')), const Locale('ja'));
      expect(resolveAppLocale(const Locale('en', 'US')), const Locale('en'));
      expect(resolveAppLocale(const Locale('fr', 'FR')), const Locale('en'));
      expect(resolveAppLocale(null), const Locale('en'));
    });

    test('Kana script is distinct while plain Japanese stays standard', () {
      const kanaLocale = Locale.fromSubtags(
        languageCode: 'ja',
        scriptCode: 'Kana',
      );

      expect(resolveAppLocale(kanaLocale), kanaLocale);
      expect(resolveAppLocale(const Locale('ja')), const Locale('ja'));
      expect(resolveInitialLanguage(), AppLanguage.japanese);
    });

    test('localization delegate supports the distinct Kana locale', () async {
      const kanaLocale = Locale.fromSubtags(
        languageCode: 'ja',
        scriptCode: 'Kana',
      );
      expect(AppLocalizations.supportedLocales, contains(kanaLocale));
      expect(AppLocalizations.delegate.isSupported(kanaLocale), isTrue);

      final kana = await AppLocalizations.delegate.load(kanaLocale);
      final japanese = await AppLocalizations.delegate.load(const Locale('ja'));
      final english = await AppLocalizations.delegate.load(const Locale('en'));

      expect(kana.localeName, 'ja_Kana');
      expect(kana.appTitle, japanese.appTitle);
      expect(kana.japaneseLanguage, 'にほんご');
      expect(kana.kanaJapaneseLanguage, 'かな');
      expect(kana.englishLanguage, 'えいご');
      expect(kana.localizationAssistanceDisclosure, contains('AI'));
      expect(kana.languageSelectionTitle, 'げんご');
      expect(kana.languageSelectionConfirm, 'けってい');
      expect(kana.startupDisclaimerOk, 'りょうかい');
      expect(english.startupDisclaimerDoNotShowAgain, 'Do not show this again');
      expect(japanese.startupDisclaimerDoNotShowAgain, '次回から表示しない');
      expect(kana.startupDisclaimerDoNotShowAgain, 'つぎからひょうじしない');
      expect(
        japanese.startupDisclaimerParagraph2,
        contains('全国珠算教育連盟、日本珠算連盟、日本フラッシュ暗算協会'),
      );
      expect(
        japanese.startupDisclaimerParagraph2,
        isNot(contains('The League')),
      );
      expect(
        kana.startupDisclaimerParagraph2,
        contains('全国珠算教育連盟（ぜんしゅれん）、日本珠算連盟（にっしゅれん）、日本フラッシュ暗算協会（あんざんきょうかい）'),
      );
      expect(kana.startupDisclaimerParagraph2, isNot(contains('The League')));
      expect(japanese.localeName, 'ja');
      expect(japanese.kanaJapaneseLanguage, 'かな');
      expect(japanese.localizationAssistanceDisclosure, contains('LLM'));
      expect(japanese.languageSelectionTitle, '言語');
      expect(japanese.languageSelectionConfirm, '決定');
      expect(japanese.startupDisclaimerOk, '了解');
      expect(japanese.startupDisclaimerParagraph1, contains('『そろくん！』'));
      expect(
        japanese.startupDisclaimerParagraph1,
        contains('ゴーインズ・ポール（Paul Goins）'),
      );
      expect(english.localeName, 'en');
      expect(english.appTitle, 'Sorokun!');
      expect(english.kanaJapaneseLanguage, 'Kana');
      expect(
        english.localizationAssistanceDisclosure,
        contains('LLM assistance'),
      );
      expect(english.languageSelectionTitle, 'Language');
      expect(english.languageSelectionConfirm, 'OK');
      expect(english.startupDisclaimerOk, 'OK');
      expect(kana.startupDisclaimerParagraph1, contains('『そろくん！』'));
      expect(
        kana.startupDisclaimerParagraph1,
        contains('ゴーインズ・ポール（Paul Goins）'),
      );
      expect(
        english.welcomeTitle,
        'Thank you for trying my version of Sorokun!',
      );
      expect(
        english.welcomeIntro,
        endsWith('This customized version is the result of that experiment.'),
      );
      expect(japanese.welcomeTitle, contains('私のバージョン'));
      expect(japanese.welcomeThanks, contains('Chet Lin'));
      expect(kana.welcomeTitle, contains('わたしのバージョン'));
      expect(kana.welcomeChanges, contains('よみあげざん'));
      expect(kana.welcomeDoNotShowAgain, 'つぎからはひょうじしない');
      for (final localization in [english, japanese, kana]) {
        expect(localization.forkModificationNotice, contains('\n\n• '));
      }
      expect(
        english.forkModificationNotice,
        contains('Last updated: 2026-11-09.'),
      );
      expect(japanese.forkModificationNotice, contains('最終更新日: 2026-11-09。'));
      expect(kana.forkModificationNotice, contains('さいしゅうこうしんび: 2026-11-09。'));
    });

    test('a saved language overrides the device locale', () {
      expect(
        resolveInitialLanguage(savedLanguage: 'english'),
        AppLanguage.english,
      );
      expect(
        resolveInitialLanguage(savedLanguage: 'japanese'),
        AppLanguage.japanese,
      );
      expect(
        resolveInitialLanguage(savedLanguage: 'not-a-language'),
        AppLanguage.japanese,
      );
    });
  });

  group('welcome screen preference', () {
    test('unchecked dismissal lasts for this launch only', () async {
      SharedPreferences.setMockInitialValues({});
      final controller = AppController();
      await controller.ready;

      expect(controller.shouldShowWelcomeScreen, isTrue);
      await controller.completeWelcome(doNotShowAgain: false);
      expect(controller.shouldShowWelcomeScreen, isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('welcome_screen_suppressed'), isNull);
      controller.dispose();

      final nextLaunch = AppController();
      await nextLaunch.ready;
      expect(nextLaunch.shouldShowWelcomeScreen, isTrue);
      nextLaunch.dispose();
    });

    test('checked dismissal persists across launches', () async {
      SharedPreferences.setMockInitialValues({});
      final controller = AppController();
      await controller.ready;
      await controller.completeWelcome(doNotShowAgain: true);
      expect(controller.shouldShowWelcomeScreen, isFalse);
      controller.dispose();

      final nextLaunch = AppController();
      await nextLaunch.ready;
      expect(nextLaunch.shouldShowWelcomeScreen, isFalse);
      nextLaunch.dispose();
    });
  });

  group('startup disclaimer preference', () {
    test('unchecked dismissal lasts for this launch only', () async {
      SharedPreferences.setMockInitialValues({'ui_language': 'english'});
      final controller = AppController();
      await controller.ready;

      expect(controller.shouldShowStartupDisclaimer, isTrue);
      await controller.completeStartupDisclaimer(doNotShowAgain: false);
      expect(controller.shouldShowStartupDisclaimer, isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('startup_disclaimer_suppressed'), isNull);
      controller.dispose();

      final nextLaunch = AppController();
      await nextLaunch.ready;
      expect(nextLaunch.shouldShowStartupDisclaimer, isTrue);
      nextLaunch.dispose();
    });

    test('checked dismissal suppresses future launches', () async {
      SharedPreferences.setMockInitialValues({'ui_language': 'english'});
      final controller = AppController();
      await controller.ready;
      await controller.completeStartupDisclaimer(doNotShowAgain: true);
      expect(controller.shouldShowStartupDisclaimer, isFalse);
      controller.dispose();

      final nextLaunch = AppController();
      await nextLaunch.ready;
      expect(nextLaunch.shouldShowStartupDisclaimer, isFalse);
      nextLaunch.dispose();
    });
  });

  test('switching and persistence support all three languages', () async {
    const kanaLocale = Locale.fromSubtags(
      languageCode: 'ja',
      scriptCode: 'Kana',
    );
    final cases = [
      (AppLanguage.japanese, const Locale('ja')),
      (AppLanguage.japaneseKana, kanaLocale),
      (AppLanguage.english, const Locale('en')),
    ];

    for (final (language, locale) in cases) {
      SharedPreferences.setMockInitialValues({});
      final controller = AppController();
      await controller.ready;

      await controller.setLanguage(language);
      expect(controller.language, language);
      expect(controller.locale, locale);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('ui_language'), language.name);
      controller.dispose();

      final restoredController = AppController();
      await restoredController.ready;
      expect(restoredController.language, language);
      expect(restoredController.locale, locale);
      restoredController.dispose();
    }
  });

  test('Kana ARB has no kanji except for the formal disclaimer names', () {
    final translations =
        jsonDecode(File('lib/l10n/app_ja_Kana.arb').readAsStringSync())
            as Map<String, dynamic>;
    const formalAssociationNamesInKana = [
      '全国珠算教育連盟（ぜんしゅれん）',
      '日本珠算連盟（にっしゅれん）',
      '日本フラッシュ暗算協会（あんざんきょうかい）',
    ];
    final strings = translations.entries
        .where((entry) => !entry.key.startsWith('@') && entry.value is String)
        .toList();

    expect(strings, isNotEmpty);
    for (final entry in strings) {
      var text = entry.value as String;
      if (entry.key == 'startupDisclaimerParagraph2') {
        for (final associationName in formalAssociationNamesInKana) {
          expect(text, contains(associationName));
          text = text.replaceAll(associationName, '');
        }
      }
      expect(_containsKanji(text), isFalse, reason: entry.key);
    }
  });

  test('welcome copy is localized in each locale ARB file', () {
    const localeFiles = ['app_en.arb', 'app_ja.arb', 'app_ja_Kana.arb'];
    const welcomeCopyKeys = [
      'welcomeTitle',
      'welcomeIntro',
      'welcomeChanges',
      'welcomeThanks',
      'welcomeSignature',
      'welcomeDoNotShowAgain',
      'welcomeReplayButton',
    ];

    for (final localeFile in localeFiles) {
      final translations =
          jsonDecode(File('lib/l10n/$localeFile').readAsStringSync())
              as Map<String, dynamic>;
      for (final key in welcomeCopyKeys) {
        expect(translations, contains(key), reason: localeFile);
      }
    }
  });

  testWidgets('welcome screen follows the selected UI locale', (
    WidgetTester tester,
  ) async {
    const locales = [
      Locale('en'),
      Locale('ja'),
      Locale.fromSubtags(languageCode: 'ja', scriptCode: 'Kana'),
    ];
    for (final locale in locales) {
      await tester.pumpWidget(
        MaterialApp(
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: WelcomeScreen(
            showDoNotShowAgain: true,
            onContinue: (_) async {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final l10n = await AppLocalizations.delegate.load(locale);
      for (final copy in [
        l10n.welcomeTitle,
        l10n.welcomeIntro,
        l10n.welcomeChanges,
        l10n.welcomeThanks,
        l10n.welcomeSignature,
        l10n.welcomeDoNotShowAgain,
      ]) {
        expect(find.text(copy), findsOneWidget, reason: 'UI locale: $locale');
      }
      expect(find.byType(CheckboxListTile), findsOneWidget);
      expect(
        tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
        isFalse,
      );
      for (final otherLocale in locales.where((other) => other != locale)) {
        final otherCopy = await AppLocalizations.delegate.load(otherLocale);
        expect(find.text(otherCopy.welcomeTitle), findsNothing);
      }
    }
  });

  testWidgets('welcome checkbox label is localized', (
    WidgetTester tester,
  ) async {
    bool? doNotShowAgain;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ja'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: WelcomeScreen(
          showDoNotShowAgain: true,
          onContinue: (value) async => doNotShowAgain = value,
        ),
      ),
    );

    expect(find.text('次回から表示しない'), findsOneWidget);
    expect(find.text('そろくん！をもとにした私のバージョンをお試しいただき、ありがとうございます。'), findsOneWidget);
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

  testWidgets('first-run language and disclaimer precede the welcome screen', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final controller = AppController();
    await controller.ready;

    await tester.pumpWidget(app.AbacusApp(appController: controller));
    await tester.pumpAndSettle();

    expect(controller.language, AppLanguage.japanese);
    expect(controller.hasSelectedLanguage, isFalse);
    expect(find.text('言語'), findsOneWidget);
    expect(find.text('決定'), findsOneWidget);
    final languageConfirmButton = find.byKey(
      const ValueKey('language-selection-confirm-button'),
    );
    expect(tester.getSize(languageConfirmButton).height, greaterThan(56));
    expect(
      tester.getSize(find.text('決定')).height,
      greaterThanOrEqualTo(tester.getSize(find.text('日本語')).height),
    );

    await tester.tap(find.text('にほんご'));
    await tester.pumpAndSettle();
    expect(find.text('げんご'), findsOneWidget);
    expect(controller.hasSelectedLanguage, isFalse);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('Language'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('ui_language'), isNull);

    await tester.tap(
      find.byKey(const ValueKey('language-selection-confirm-button')),
    );
    await tester.pumpAndSettle();
    expect(controller.language, AppLanguage.english);
    expect(controller.hasSelectedLanguage, isTrue);
    expect(find.text('About this app'), findsOneWidget);
    expect(
      find.text(
        'This is an independent derivative work based on Sorokun by Chet Lin. It was created and is maintained by Paul Goins.',
      ),
      findsOneWidget,
    );
    expect(
      find.text('Thank you for trying my version of Sorokun!'),
      findsNothing,
    );
    expect(
      tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
      isFalse,
    );
    expect(prefs.getBool('startup_disclaimer_suppressed'), isNull);
    expect(prefs.getString('ui_language'), 'english');

    await tester.tap(
      find.byKey(const ValueKey('startup-disclaimer-ok-button')),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Thank you for trying my version of Sorokun!'),
      findsOneWidget,
    );
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    await tester.tap(find.text('OK'));
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    expect(find.text('Choose a subject'), findsOneWidget);
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
    await tester.pumpAndSettle();
    await tester.tap(reopenButton);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    expect(
      find.text('Thank you for trying my version of Sorokun!'),
      findsOneWidget,
    );
    expect(find.byType(CheckboxListTile), findsNothing);
    await tester.tap(find.text('OK'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(find.text('Show welcome screen again'), findsOneWidget);
  });

  testWidgets('startup disclaimer is shown on every app launch', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'ui_language': 'english',
      'welcome_screen_suppressed': true,
    });

    for (var launch = 0; launch < 2; launch++) {
      final controller = AppController();
      await controller.ready;
      expect(controller.hasSelectedLanguage, isTrue);
      expect(controller.shouldShowStartupDisclaimer, isTrue);

      await tester.pumpWidget(app.AbacusApp(appController: controller));
      await tester.pumpAndSettle();
      expect(find.text('About this app'), findsOneWidget);
      expect(find.text('Choose a subject'), findsNothing);
      expect(
        tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
        isFalse,
      );

      await tester.tap(
        find.byKey(const ValueKey('startup-disclaimer-ok-button')),
      );
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();
      expect(controller.shouldShowStartupDisclaimer, isFalse);
      expect(find.text('Choose a subject'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('checked disclaimer choice hides it on later launches', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'ui_language': 'english',
      'welcome_screen_suppressed': true,
    });

    final firstLaunch = AppController();
    await firstLaunch.ready;
    await tester.pumpWidget(app.AbacusApp(appController: firstLaunch));
    await tester.pumpAndSettle();
    expect(find.text('About this app'), findsOneWidget);

    final checkbox = find.byKey(
      const ValueKey('startup-disclaimer-do-not-show-again'),
    );
    await tester.tap(checkbox);
    await tester.pump();
    expect(tester.widget<CheckboxListTile>(checkbox).value, isTrue);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('startup_disclaimer_suppressed'), isNull);

    await tester.tap(
      find.byKey(const ValueKey('startup-disclaimer-ok-button')),
    );
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(prefs.getBool('startup_disclaimer_suppressed'), isTrue);
    expect(find.text('Choose a subject'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());

    final nextLaunch = AppController();
    await nextLaunch.ready;
    expect(nextLaunch.shouldShowStartupDisclaimer, isFalse);
    await tester.pumpWidget(app.AbacusApp(appController: nextLaunch));
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(find.text('About this app'), findsNothing);
    expect(find.text('Choose a subject'), findsOneWidget);
  });

  testWidgets('home page presents the available practice modes', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'ui_language': 'japanese'});
    final controller = AppController();
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
    final controller = AppController();
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

  testWidgets('Credits show the modification summary as a dated bullet list', (
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
    expect(find.textContaining('最終更新日: 2026-11-09。'), findsOneWidget);
    expect(find.textContaining('• 読み上げ算と VOICEVOX を削除しました。'), findsOneWidget);
    expect(find.textContaining('• ハンズフリー暗算を追加しました。'), findsOneWidget);
    expect(
      find.text('このフォークの改変は、Vultaire の指示のもと、LLM を用いたエージェント型開発で行われました。'),
      findsOneWidget,
    );
    expect(
      find.text('一部のインターフェースのローカライズにLLMを利用しています。翻訳に誤りがあれば、ご指摘ください。'),
      findsOneWidget,
    );
    final gradeDisclosure = find.text(
      '本フォークのそろくん！は独立した非公式の練習用アプリです。全国珠算教育連盟、日本珠算連盟、日本フラッシュ暗算協会の公式プログラムではなく、各団体との提携関係はなく、各団体から公認・推奨を受けたものでもありません。アプリ内の級位・段位等は練習用の目安であり、各団体の最新の基準や検定要件と異なる場合があります。最新の要件は各団体にご確認ください。',
    );
    for (
      var attempt = 0;
      attempt < 8 && gradeDisclosure.evaluate().isEmpty;
      attempt++
    ) {
      await tester.drag(
        find.byType(ListView),
        const Offset(0, -240),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
    }
    expect(gradeDisclosure, findsOneWidget);
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
    final controller = AppController();
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

    final restoredController = AppController();
    await restoredController.ready;
    expect(restoredController.language, AppLanguage.english);
    expect(restoredController.locale, const Locale('en'));

    controller.dispose();
    restoredController.dispose();
  });

  testWidgets('desktop settings switch among all three language options', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({});
    final controller = AppController();
    await controller.ready;

    await tester.pumpWidget(
      _localizedApp(controller, const ColorSchemeSettingsPage()),
    );
    await tester.pumpAndSettle();

    final selector = find.byKey(const ValueKey('settings-language-selector'));
    expect(selector, findsOneWidget);
    expect(
      tester.widget(selector),
      isA<LabeledSlidingSegmentedControl<AppLanguage>>(),
    );
    var languageControl = tester
        .widget<LabeledSlidingSegmentedControl<AppLanguage>>(selector);
    expect(languageControl.groupValue, AppLanguage.japanese);
    expect(languageControl.options.map((option) => option.$1), [
      AppLanguage.japanese,
      AppLanguage.japaneseKana,
      AppLanguage.english,
    ]);
    _expectStableLanguageOptionLabels(tester);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('にほんご'));
    await tester.pumpAndSettle();
    expect(controller.language, AppLanguage.japaneseKana);
    expect(
      controller.locale,
      const Locale.fromSubtags(languageCode: 'ja', scriptCode: 'Kana'),
    );
    var prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('ui_language'), 'japaneseKana');
    languageControl = tester
        .widget<LabeledSlidingSegmentedControl<AppLanguage>>(selector);
    expect(languageControl.groupValue, AppLanguage.japaneseKana);
    _expectStableLanguageOptionLabels(tester);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(controller.language, AppLanguage.english);
    expect(controller.locale, const Locale('en'));
    prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('ui_language'), 'english');
    _expectStableLanguageOptionLabels(tester);

    await tester.tap(find.text('日本語'));
    await tester.pumpAndSettle();
    expect(controller.language, AppLanguage.japanese);
    expect(controller.locale, const Locale('ja'));
    prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('ui_language'), 'japanese');
    _expectStableLanguageOptionLabels(tester);
    expect(tester.takeException(), isNull);

    controller.dispose();
  });

  testWidgets('narrow settings use a compact three-choice language control', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({});
    final controller = AppController();
    await controller.ready;

    await tester.pumpWidget(
      _localizedApp(controller, const ColorSchemeSettingsPage()),
    );
    await tester.pumpAndSettle();

    final selector = find.byKey(const ValueKey('settings-language-selector'));
    expect(selector, findsOneWidget);
    final languageControl = tester
        .widget<LabeledSlidingSegmentedControl<AppLanguage>>(selector);
    expect(languageControl.groupValue, AppLanguage.japanese);
    expect(languageControl.proportionalWidth, isTrue);
    expect(languageControl.horizontalPadding, 4);
    expect(languageControl.labelStyle?.fontSize, isNotNull);
    expect(languageControl.options.map((option) => option.$1), [
      AppLanguage.japanese,
      AppLanguage.japaneseKana,
      AppLanguage.english,
    ]);
    _expectStableLanguageOptionLabels(tester);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('にほんご'));
    await tester.pumpAndSettle();
    expect(controller.language, AppLanguage.japaneseKana);
    _expectStableLanguageOptionLabels(tester);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('ui_language'), 'japaneseKana');
    expect(tester.takeException(), isNull);

    controller.dispose();
  });

  testWidgets('Kana language segments fit a tablet-width settings screen', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(768, 1024);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({'ui_language': 'japaneseKana'});
    final controller = AppController();
    await controller.ready;

    await tester.pumpWidget(
      _localizedApp(controller, const ColorSchemeSettingsPage()),
    );
    await tester.pumpAndSettle();

    final selector = find.byKey(const ValueKey('settings-language-selector'));
    expect(
      tester.widget(selector),
      isA<LabeledSlidingSegmentedControl<AppLanguage>>(),
    );
    final languageControl = tester
        .widget<LabeledSlidingSegmentedControl<AppLanguage>>(selector);
    expect(languageControl.options.map((option) => option.$1), [
      AppLanguage.japanese,
      AppLanguage.japaneseKana,
      AppLanguage.english,
    ]);
    _expectStableLanguageOptionLabels(tester);
    expect(tester.takeException(), isNull);

    controller.dispose();
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
